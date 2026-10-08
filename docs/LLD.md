# Farm2Factory: Low-Level Design (LLD)

| | |
|---|---|
| Version | 0.2 (draft) |
| Stack | Dart, Flutter, Firebase Auth, Cloud Firestore, Firebase Storage, Emulator / Device |
| Related | `PRD.md`, `HLD.md` |

Implementation detail: Firestore structure, security rules, rate math, offline handling, Flutter modules, tests. Build the MVP parts first.

---

## 1. Conventions

- **Money in paise** (integer): Rs 42.50 is `4250`.
- **Quantity in tenths of a litre** (integer): 12.5 L is `125`.
- **Fat and SNF times 100** (integer): 4.2 % is `420`.
- Integers avoid floating-point rounding errors in bills.
- Dates for queries are strings `yyyy-MM-dd` in India time (`collectedOn`). Timestamps are Firestore `Timestamp`.
- Field names are camelCase. Collection names are camelCase.
- Every business document carries `dairyId` (or sits under `dairies/{dairyId}`).
- Business documents are never deleted.

Codes:
- Farmer `F-<center>-<number>` (example `F-BHN-0123`), collector `C-<center>-<number>`, lot `LOT-<yyyymmdd>-<shift>-<tanker>`.

---

## 2. Firestore structure

```
users/{uid}
dairies/{dairyId}
  centers/{centerId}
  rateCharts/{chartId}
  collections/{entryId}                 entryId = <farmerCode>_<yyyyMMdd>_<AM|PM>
    edits/{version}                     history of corrections (append only)
  tankers/{tankerId}
  lots/{lotId}
  qcTests/{testId}
  payouts/{payoutId}                    payoutId = <farmerUid>_<fromYyyyMMdd>_<toYyyyMMdd>
  disputes/{disputeId}
users/{uid}/notifications/{notificationId}
```

### 2.1 Example documents

**users/{uid}** (the uid is the Firebase Auth uid)
```json
{
  "dairyId": "dairy1",
  "role": "farmer",                 // admin | supervisor | collector | qc | farmer
  "code": "F-BHN-0123",
  "name": "Ram Singh",
  "phone": "98xxxxxx12",
  "centerId": "BHN",
  "village": "Bhainsa",
  "animalType": "buffalo",
  "vehicleNo": null,                // collectors only
  "language": "hi",
  "active": true,
  "createdAt": "<serverTimestamp>"
}
```

**dairies/{d}/centers/{centerId}**
```json
{ "code": "BHN", "name": "Bhainsa Center", "village": "Bhainsa", "district": "...", "state": "...", "lat": 26.9, "lng": 75.8 }
```

**dairies/{d}/rateCharts/{chartId}** (immutable once created; a rate change is a new chart)
```json
{
  "name": "Standard 2026",
  "method": "chart",                       // chart | formula
  "effectiveFrom": "2026-10-01",
  "rows": [
    { "fatMin": 350, "fatMax": 399, "snfMin": 800, "snfMax": 849, "ratePaise": 3600 },
    { "fatMin": 400, "fatMax": 449, "snfMin": 800, "snfMax": 849, "ratePaise": 4000 }
  ],
  "fatRatePaisePerPoint": null,            // formula method
  "snfRatePaisePerPoint": null,
  "createdBy": "<uid>", "createdAt": "<serverTimestamp>"
}
```

**dairies/{d}/collections/{entryId}**
```json
{
  "farmerId": "<farmer uid>", "farmerCode": "F-BHN-0123",
  "centerId": "BHN", "collectorId": "<collector uid>",
  "collectedOn": "2026-10-03", "shift": "AM",
  "quantityL10": 125, "fat100": 420, "snf100": 835,
  "rateChartId": "chart1", "ratePaise": 4000, "amountPaise": 50000,
  "version": 1,
  "deviceTime": "<Timestamp from phone>",
  "serverTime": "<serverTimestamp>",
  "updatedAt": null, "updatedBy": null,
  "lotId": null
}
```

**dairies/{d}/collections/{entryId}/edits/{version}**
```json
{
  "versionFrom": 1, "versionTo": 2,
  "old": { "quantityL10": 120, "fat100": 410, "snf100": 835, "ratePaise": 3900, "amountPaise": 46800 },
  "new": { "quantityL10": 125, "fat100": 420, "snf100": 835, "ratePaise": 4000, "amountPaise": 50000 },
  "reason": "Wrong reading entered",
  "editedBy": "<uid>", "editedAt": "<serverTimestamp>"
}
```

**users/{uid}/notifications/{id}**
```json
{ "type": "entry_corrected", "title": "Entry changed", "body": "03 Oct AM: 120 L to 125 L", "entryId": "...", "createdAt": "<serverTimestamp>", "readAt": null }
```

### 2.2 Later-phase documents

```
tankers/{id}   { vehicleNo, driverName }
lots/{id}      { lotCode, tankerId, receivedOn, shift, totalL10, status: received|accepted|rejected }
qcTests/{id}   { lotId, fat100, snf100, adulterationFound, grade: A|B|C|Rejected, testedBy, testedAt, notes, photoPath }
payouts/{id}   { farmerId, periodFrom, periodTo, totalL10, totalPaise, status: unpaid|paid, mode, paidAt, reference, billPath }
disputes/{id}  { entryId, raisedBy, reason, status: open|resolved|rejected, resolutionNote, resolvedBy, createdAt, resolvedAt }
```

### 2.3 Indexes (`firestore.indexes.json`)

| Collection | Fields | Used for |
|---|---|---|
| collections | `farmerId` asc, `collectedOn` desc | Farmer's records |
| collections | `centerId` asc, `collectedOn` desc | Collector's and center's records |
| collections | `centerId` asc, `collectedOn` asc, `shift` asc | Daily center report |
| collections | `lotId` asc | Lot trace |
| payouts | `farmerId` asc, `periodTo` desc | Payment history |

---

## 3. Security Rules

### 3.1 Firestore (`firestore.rules`)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    function signedIn() { return request.auth != null; }
    function me() {
      return get(/databases/$(database)/documents/users/$(request.auth.uid)).data;
    }
    function role() { return me().role; }
    function sameDairy(d) { return signedIn() && me().dairyId == d && me().active == true; }
    function isStaffReader() { return role() in ['admin', 'supervisor', 'qc']; }

    // USERS
    match /users/{uid} {
      allow read: if signedIn() && (
        uid == request.auth.uid
        || (role() in ['admin', 'supervisor'] && resource.data.dairyId == me().dairyId)
        || (role() == 'collector' && resource.data.role == 'farmer'
            && resource.data.centerId == me().centerId));
      allow create: if signedIn() && request.resource.data.dairyId == me().dairyId && (
        role() == 'admin'
        || (role() == 'collector' && request.resource.data.role == 'farmer'
            && request.resource.data.centerId == me().centerId));
      allow update: if signedIn() && role() == 'admin'
        && resource.data.dairyId == me().dairyId;
      allow delete: if false;

      match /notifications/{nid} {
        allow read: if signedIn() && uid == request.auth.uid;
        allow update: if signedIn() && uid == request.auth.uid
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['readAt']);
        allow create: if signedIn() && role() in ['admin', 'supervisor', 'collector'];
        allow delete: if false;
      }
    }

    match /dairies/{d} {
      allow read: if sameDairy(d);

      match /centers/{c} {
        allow read: if sameDairy(d);
        allow write: if sameDairy(d) && role() == 'admin';
      }

      // RATE CHARTS: created once, never edited
      match /rateCharts/{chartId} {
        allow read: if sameDairy(d);
        allow create: if sameDairy(d) && role() == 'admin';
        allow update, delete: if false;
      }

      // COLLECTION ENTRIES
      match /collections/{entryId} {
        allow read: if sameDairy(d) && (
          (role() == 'farmer' && resource.data.farmerId == request.auth.uid)
          || (role() == 'collector' && resource.data.centerId == me().centerId)
          || isStaffReader());

        allow create: if sameDairy(d) && role() == 'collector'
          && request.resource.data.collectorId == request.auth.uid
          && request.resource.data.centerId == me().centerId
          && request.resource.data.version == 1
          && request.resource.data.quantityL10 is int
          && request.resource.data.quantityL10 >= 5 && request.resource.data.quantityL10 <= 2000
          && request.resource.data.fat100 is int
          && request.resource.data.fat100 >= 100 && request.resource.data.fat100 <= 1200
          && request.resource.data.snf100 is int
          && request.resource.data.snf100 >= 500 && request.resource.data.snf100 <= 1200
          && request.resource.data.ratePaise is int && request.resource.data.ratePaise > 0
          && request.resource.data.amountPaise is int && request.resource.data.amountPaise > 0
          && request.resource.data.serverTime == request.time;

        // Correction: version + 1, only value fields change,
        // and a matching edits/<version> document must be written in the same batch.
        allow update: if sameDairy(d) && role() in ['collector', 'supervisor']
          && request.resource.data.version == resource.data.version + 1
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly(
               ['quantityL10','fat100','snf100','rateChartId','ratePaise','amountPaise',
                'version','updatedAt','updatedBy'])
          && request.resource.data.updatedBy == request.auth.uid
          && existsAfter(/databases/$(database)/documents/dairies/$(d)/collections/$(entryId)/edits/$(string(request.resource.data.version)));

        // Lot assignment by staff (separate small rule, lotId only)
        allow update: if sameDairy(d) && role() in ['supervisor', 'qc', 'admin']
          && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['lotId']);

        allow delete: if false;

        match /edits/{version} {
          allow read: if sameDairy(d) && (
            isStaffReader() || role() == 'collector'
            || (role() == 'farmer' && get(/databases/$(database)/documents/dairies/$(d)/collections/$(entryId)).data.farmerId == request.auth.uid));
          allow create: if sameDairy(d) && role() in ['collector', 'supervisor']
            && request.resource.data.editedBy == request.auth.uid
            && request.resource.data.reason is string && request.resource.data.reason.size() >= 3;
          allow update, delete: if false;
        }
      }

      match /lots/{id}      { allow read: if sameDairy(d); allow write: if sameDairy(d) && role() in ['supervisor','qc','admin']; }
      match /tankers/{id}   { allow read: if sameDairy(d); allow write: if sameDairy(d) && role() == 'admin'; }
      match /qcTests/{id}   { allow read: if sameDairy(d) && isStaffReader();
                              allow create: if sameDairy(d) && role() in ['qc','supervisor'];
                              allow update, delete: if false; }
      match /payouts/{id}   { allow read: if sameDairy(d) && (isStaffReader()
                                || (role() == 'farmer' && resource.data.farmerId == request.auth.uid));
                              allow write: if sameDairy(d) && role() in ['admin','supervisor']; }
      match /disputes/{id}  { allow read, create: if sameDairy(d);
                              allow update: if sameDairy(d) && role() in ['supervisor','admin'];
                              allow delete: if false; }
    }
  }
}
```

Notes:
- The simplified farmer `read` rules work with queries only if the query filters by `farmerId` (or `centerId`), so always include that filter.
- The two `update` rules are alternatives; Firestore allows the write if either one passes.
- Rules cannot calculate `amountPaise` reliably; the device calculates it (section 5). Add Cloud Functions later if server recalculation is needed.
- Each rule that calls `get()` counts as an extra read. It is acceptable at this scale.

### 3.2 Storage (`storage.rules`)

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    function me() { return firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data; }

    // Bills: dairies/<dairyId>/bills/<farmerUid>/<period>.pdf
    match /dairies/{d}/bills/{farmerUid}/{file} {
      allow read: if request.auth != null && me().dairyId == d
        && (request.auth.uid == farmerUid || me().role in ['admin','supervisor']);
      allow write: if request.auth != null && me().dairyId == d && me().role in ['admin','supervisor'];
    }
    // Exports and QC photos
    match /dairies/{d}/exports/{file=**} {
      allow read, write: if request.auth != null && me().dairyId == d && me().role in ['admin','supervisor'];
    }
    match /dairies/{d}/qc/{lotId}/{file} {
      allow read: if request.auth != null && me().dairyId == d;
      allow write: if request.auth != null && me().dairyId == d && me().role in ['qc','supervisor']
        && request.resource.size < 3 * 1024 * 1024
        && request.resource.contentType.matches('image/.*');
    }
  }
}
```

---

## 4. Authentication details

- **Login:** the user types an ID (for example `F-BHN-0123`) and PIN. The app converts the ID to an internal email like `f-bhn-0123@farm2factory.app` and calls `signInWithEmailAndPassword`. The user never sees the email.
- **PIN length:** Firebase Auth requires at least 6 characters, so farmers use a 6-digit PIN. Staff use 8 or more characters.
- **Role routing:** after login, the app reads `users/{uid}` and sends the user to the collector, farmer, admin or QC home.
- **Creating accounts** (admin or collector): calling `createUserWithEmailAndPassword` on the main Firebase app would log the creator out. Use a **second Firebase app instance**:

```dart
Future<String> createAuthUser(String email, String pin) async {
  final secondary = await Firebase.initializeApp(
    name: 'secondary', options: Firebase.app().options);
  final auth = FirebaseAuth.instanceFor(app: secondary);
  final cred = await auth.createUserWithEmailAndPassword(email: email, password: pin);
  await auth.signOut();
  return cred.user!.uid;           // then the main app writes users/{uid}
}
```
- Then the main app (logged in as the creator) writes `users/{uid}`. Rules allow this because the creator is admin or the farmer's collector.
- **PIN reset by admin** is not possible from the client with this stack (resetting another user's password needs the Admin SDK). MVP workaround: Firebase password reset email to the internal address is useless for farmers, so the admin recreates the account with a new ID suffix, or use phone OTP login later. Record this as an open issue; Cloud Functions solve it.
- **Deactivating a user:** set `active: false` in `users/{uid}`. Rules require `active == true`.

---

## 5. Rate calculation (integer math)

```dart
class RateCalculator {
  /// Returns rate in paise per litre.
  int ratePaise(RateChart chart, int fat100, int snf100) {
    if (chart.method == 'chart') {
      final row = chart.rows.firstWhere(
        (r) => fat100 >= r.fatMin && fat100 <= r.fatMax &&
               snf100 >= r.snfMin && snf100 <= r.snfMax,
        orElse: () => throw RateNotFound(fat100, snf100));
      return row.ratePaise;
    }
    // formula: paise per fat point and per SNF point (1.00 = 100)
    final raw = fat100 * chart.fatRatePaisePerPoint + snf100 * chart.snfRatePaisePerPoint;
    return (raw + 50) ~/ 100;                       // round half up
  }

  /// quantityL10 is litres x 10, so divide by 10 with rounding.
  int amountPaise(int quantityL10, int ratePaise) =>
      (quantityL10 * ratePaise + 5) ~/ 10;
}
```

Rules:
- Pick the chart with the latest `effectiveFrom <= collectedOn`.
- Validate a new chart before saving: no overlapping ranges, no gaps in the ranges the dairy uses.
- The entry stores `rateChartId`, `ratePaise` and `amountPaise` (a snapshot), so later chart changes never alter old entries.
- Display values: divide by 10 (litres), 100 (fat, SNF, rupees).
- Validation limits (configurable per dairy): quantity 0.5 to 200 L; fat 1.0 to 12.0; SNF 5.0 to 12.0. The rules use the same limits.

---

## 6. Offline implementation

### 6.1 Settings (at app start)
```dart
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

### 6.2 Create an entry (do not await while offline)
```dart
Future<void> addEntry(NewEntry e) {
  final id = '${e.farmerCode}_${e.collectedOn.replaceAll('-', '')}_${e.shift}';
  final ref = _db.doc('dairies/$dairyId/collections/$id');
  final data = {
    'farmerId': e.farmerUid, 'farmerCode': e.farmerCode,
    'centerId': centerId, 'collectorId': uid,
    'collectedOn': e.collectedOn, 'shift': e.shift,
    'quantityL10': e.quantityL10, 'fat100': e.fat100, 'snf100': e.snf100,
    'rateChartId': chart.id, 'ratePaise': rate, 'amountPaise': amount,
    'version': 1,
    'deviceTime': Timestamp.now(),
    'serverTime': FieldValue.serverTimestamp(),
    'updatedAt': null, 'updatedBy': null, 'lotId': null,
  };
  // Do NOT await: completes only after the server confirms.
  ref.set(data).catchError((err) => _reportRejected(id, err));
  return Future.value();   // UI continues immediately
}
```

A repeated set on an existing ID is treated as an update and is rejected by the rules (version must increase), which prevents duplicates and overwrites.

### 6.3 Pending-sync indicator
```dart
Stream<QuerySnapshot> todayEntries() => _db
    .collection('dairies/$dairyId/collections')
    .where('centerId', isEqualTo: centerId)
    .where('collectedOn', isEqualTo: today)
    .snapshots(includeMetadataChanges: true);

// pending count = docs where doc.metadata.hasPendingWrites == true
```

### 6.4 Master data sync ("Sync now")
- While online, read `users` (farmers of the center) and `rateCharts` with `Source.server` so they are stored in the cache.
- Store the last sync time locally and show it on the collector home screen.
- Offline farmer search uses `GetOptions(source: Source.cache)`.

### 6.5 Correction (online only)
```dart
Future<void> correctEntry(Entry old, Correction c) async {
  // 1. fresh version from the server
  final snap = await entryRef.get(const GetOptions(source: Source.server));
  final v = snap['version'] as int;
  if (v != old.version) throw StaleVersion(snap.data()!);

  final batch = _db.batch();
  batch.update(entryRef, {
    'quantityL10': c.quantityL10, 'fat100': c.fat100, 'snf100': c.snf100,
    'rateChartId': chart.id, 'ratePaise': c.ratePaise, 'amountPaise': c.amountPaise,
    'version': v + 1,
    'updatedAt': FieldValue.serverTimestamp(), 'updatedBy': uid,
  });
  batch.set(entryRef.collection('edits').doc('${v + 1}'), {
    'versionFrom': v, 'versionTo': v + 1,
    'old': old.values, 'new': c.values, 'reason': c.reason,
    'editedBy': uid, 'editedAt': FieldValue.serverTimestamp(),
  });
  batch.set(_db.collection('users/${old.farmerId}/notifications').doc(), {
    'type': 'entry_corrected', 'title': 'Entry changed',
    'body': '${old.dateLabel} ${old.shift}: ${old.litres} L to ${c.litres} L',
    'entryId': old.id, 'createdAt': FieldValue.serverTimestamp(), 'readAt': null,
  });
  await batch.commit();
}
```

### 6.6 Close shift (reconciliation)
- Online only. The app counts entries and sums litres from its local list, then runs a server query (`count()` and `sum()` aggregate queries, or a plain query with `Source.server`) for the same center, date and shift.
- If they differ, show the missing entries and keep them for retry.
- Save the result in `dairies/{d}/shiftClosures/{center}_{date}_{shift}` (optional, create-only).

### 6.7 Failure cases
| Case | Behaviour |
|---|---|
| Rule rejects a queued create (duplicate or invalid) | `catchError` reports it; entry shows "failed". It is kept in a local failed list for the collector to review |
| App killed before sync | Pending write remains in the cache and is sent next time online |
| Cache cleared or app uninstalled with pending writes | Entries are lost: warn collectors to sync before reinstalling, and use Close shift daily |
| Token expired offline | Writes are sent after the token refreshes when online |

---

## 7. Queries (designed around the screens)

| Screen | Query |
|---|---|
| Farmer, today | `collections` where `farmerId == uid` and `collectedOn == today` |
| Farmer, 10 days / month | same, `collectedOn >= from` and `<= to`, order desc, limit 80 |
| Collector, today | `collections` where `centerId == c` and `collectedOn == today` |
| Daily center report | `centerId == c`, `collectedOn == day`, order by `shift` |
| Month bill for one farmer | `farmerId == f`, date range; sum `amountPaise` and `quantityL10` in the app |
| Dashboard (admin) | one-day range per center; use aggregate `sum()`/`average()` queries where supported |
| Lot trace | `collections` where `lotId == lot` |
| Payment history | `payouts` where `farmerId == f`, order by `periodTo` desc, limit 6 |

Never read whole collections. Always add a date range and a limit.

---

## 8. Storage layout

```
dairies/{dairyId}/bills/{farmerUid}/{yyyy-MM or from_to}.pdf
dairies/{dairyId}/exports/{yyyy-MM}/{center}_report.xlsx
dairies/{dairyId}/qc/{lotId}/{photo}.jpg
users/{uid}/avatar.jpg (optional)
```

Bill PDF contents: farmer name and code, period, date rows (shift, litres, fat, SNF, rate, amount), totals, average fat/SNF, generation time.

---

## 9. Flutter module structure

```
flutter_application_1/        (rename to farm2factory)
├─ lib/
│  ├─ main.dart               Firebase init, Firestore settings, runApp
│  ├─ app.dart                theme, router, localization
│  ├─ firebase_options.dart   generated by flutterfire configure
│  ├─ core/
│  │  ├─ theme/  l10n/ (app_en.arb, app_hi.arb)  utils/ (date, money, formatters)  widgets/
│  ├─ data/
│  │  ├─ firebase/            firestore paths, converters, auth client, secondary-app helper
│  │  └─ repositories/        auth_repo, user_repo, rate_repo, collection_repo,
│  │                          notification_repo, lot_repo, bill_repo
│  ├─ domain/
│  │  ├─ models/              AppUser, Center, RateChart, Entry, Edit, Lot, Payout
│  │  └─ services/            rate_calculator.dart, validators.dart
│  └─ features/
│     ├─ auth/                login, role router
│     ├─ collector/           home, add_entry, farmers_list, entries, sync_status, close_shift
│     ├─ farmer/              home, records, payments, notifications
│     ├─ admin/               dashboard, users, rate_chart, reports
│     └─ qc/                  lots, add_test
├─ test/                      unit and widget tests
├─ firebase.json  firestore.rules  firestore.indexes.json  storage.rules
└─ rules-tests/               Node tests for rules (emulator)
```

Rules for the code:
- Screens use repositories through Riverpod providers; they never import Firebase directly.
- `RateCalculator` and validators are pure Dart and unit-tested.
- Firestore paths live in one file.

Repository interfaces (sketch):
```dart
abstract class CollectionRepository {
  Future<void> addEntry(NewEntry input);                       // offline-capable
  Future<void> correctEntry(Entry old, Correction c);          // online only
  Stream<List<Entry>> watchFarmer(String farmerUid, String from, String to);
  Stream<List<Entry>> watchCenterDay(String centerId, String day);
  Stream<int> watchPendingCount(String centerId, String day);
}
```

---

## 10. Screens (MVP)

| Role | Screen | Key elements |
|---|---|---|
| All | Login | ID, PIN, language toggle |
| Collector | Home | Today's AM/PM totals, Add Entry, Farmers List, Pending Sync, Sync now, Close shift |
| Collector | Add Entry | Farmer search, quantity, fat, SNF, live rate and amount, Save |
| Collector | Entries | Today's list with pending marks; tap to correct (online) |
| Farmer | Home | Farmer card, tabs Today / 10 Days / Month, totals |
| Farmer | Records | Table: date, shift, quantity, fat, rate, amount, entry time |
| Farmer | Notifications | Entry-corrected alerts |
| Admin | Rate chart | Add chart, rows, effective date, overlap check |
| Admin | Users | Create collector or farmer |

---

## 11. State machines

- **Entry:** `created (pending write)` to `synced` to `corrected (version n)`. No delete. Rejected: `failed` to reviewed by the collector.
- **Lot:** `received` to `accepted` or `rejected`.
- **Payout:** `unpaid` to `paid` (mode, reference, date).
- **Dispute:** `open` to `resolved` or `rejected`.

---

## 12. Error handling

| Case | Behaviour |
|---|---|
| No internet | Save to cache; show "waiting to sync" |
| Duplicate farmer, date and shift | Warn before saving ("already recorded"); open the existing entry for correction |
| Value out of range | Confirm with the collector; rules still enforce hard limits |
| No rate for fat/SNF | Block save: "Rate chart missing for this reading" |
| Stale version on correction | Show latest values; ask to redo |
| Permission denied | Show a plain message, log locally |
| Phone clock wrong | Compare `deviceTime` and `serverTime`; flag a gap over 10 minutes |
| Sync failure after long time | Collector sees pending count; "Close shift" shows differences |

---

## 13. Testing plan

| Level | What | Tools |
|---|---|---|
| Unit | Rate calculator, rounding, validators | `flutter_test` |
| Rules | Farmer cannot read others; collector limited to center; no deletes; create-only; correction needs `edits` doc; duplicates rejected | Firebase Emulator + `@firebase/rules-unit-testing` |
| Widget | Add Entry form, farmer records | `flutter_test` |
| Integration | Airplane-mode shift then sync; correction flow | `integration_test` with emulators |
| Device | Low-end Android phone, slow network | Manual |
| UAT | Real operator and supervisor at pilot | Checklist |

Acceptance examples:
- Collector records 50 entries in airplane mode; after reconnecting there are 50 on the server, zero duplicates, and Close shift matches.
- Farmer A cannot read Farmer B's entries (query returns permission denied).
- Correct an entry: version is 2, `edits/2` exists, the farmer has a notification.
- New rate chart effective tomorrow: today's entries keep their old rates.

---

## 14. Local setup commands

```bash
# install tools once
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# in the project folder
firebase login
firebase init firestore storage emulators      # choose Auth, Firestore, Storage emulators
flutterfire configure                          # pick your Firebase project and platforms
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage \
  flutter_riverpod go_router intl pdf printing excel connectivity_plus

# run emulators, then the app
firebase emulators:start
flutter run
```

Point the app at the emulators in debug mode (Android emulator uses `10.0.2.2` for the host machine):
```dart
if (kDebugMode) {
  FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
  await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
  await FirebaseStorage.instance.useStorageEmulator('10.0.2.2', 9199);
}
```
(Use your computer's LAN IP instead of `10.0.2.2` on a real phone.)

---

## 15. Build order

1. Firebase project, `flutterfire configure`, emulator suite running.
2. Auth with ID-to-email login and role router; first admin created by hand in the emulator.
3. Rules for `users`, plus rules tests.
4. Rate chart screen and `RateCalculator` with unit tests.
5. Add Entry with offline cache, pending indicator, "Sync now".
6. Farmer records screen.
7. Correction flow, `edits` history and notifications.
8. Close shift reconciliation.
9. Admin screens, bills (PDF to Storage), Excel export.
10. QC, lots and trace.
11. Pilot hardening: crash reporting, budget alerts, backups (scheduled Firestore export if on a paid plan).
