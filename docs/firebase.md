# Firebase Architecture & Setup

## Overview
This document outlines the complete Firebase architecture, Cloud Firestore schema, Firebase Storage buckets, composite index configurations, and security rules for the Farm2Factory Dairy Cooperative digital milk collection and plant management system.

---

## 1. Setup Instructions (Flutter)
1. Firebase Core, Auth, Cloud Firestore, and Firebase Storage dependencies are declared in `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^4.15.2
     firebase_auth: ^6.7.0
     cloud_firestore: ^6.10.0
     firebase_storage: ^13.6.1
   ```
2. Configuration files:
   - `android/app/google-services.json`
   - `lib/firebase_options.dart` (generated via FlutterFire CLI)
3. In `main.dart`, initialize Firebase before running the application:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```

---

## 2. Collections & Schema

### `users`
Stores application user accounts and role-based profiles.
- `uid` (String, Document ID): Matches Firebase Auth UID.
- `name` (String): Full name.
- `email` (String): User's system login email.
- `role` (String): `'admin'`, `'supervisor'`, `'qc'`, `'collector'`, `'farmer'`.
- `phone` (String, optional): Mobile number.
- `center` (String, optional): Assigned collection center name.
- `customId` (String, optional): Business identifier (e.g., `F001`, `C-BHN-001`, `ADM-001`).
- `dairyId` (String, optional): Cooperative plant ID (`dairy1`).
- `createdAt` (Timestamp): Server timestamp of registration.

#### Subcollection: `users/{uid}/notifications/{nid}`
In-app user notifications inbox (PRD F9, LLD Section 2.1).
- `id` (String): Notification identifier.
- `userId` (String): Recipient user identifier.
- `type` (String): `'entryCorrected'`, `'disputeUpdate'`, `'payoutReady'`, `'qcAlert'`, `'general'`.
- `title` (String): Alert title.
- `body` (String): Human-readable notification description.
- `referenceId` (String, optional): Associated entity ID (e.g., `ENT-001`, `DSP-001`, `REC-001`).
- `createdAt` (Timestamp): Server creation timestamp.
- `readAt` (Timestamp, optional): Timestamp when user acknowledged the notification.
- `isRead` (Boolean): Read flag.

---

### `farmers`
Directory of registered dairy farmers supplying milk to cooperative centers.
- `id` (String, Document ID): Unique farmer ID (e.g., `F001`).
- `name` (String): Farmer's full name.
- `phone` (String): Mobile number.
- `village` (String): Village location.
- `center` (String): Associated collection center.
- `collectorId` (String): Primary collection operator ID.
- `status` (String): `'Active'` or `'Inactive'`.
- `aadhaarNumber` (String, optional): Verification identifier.
- `createdAt` (Timestamp): Registration timestamp.

---

### `milk_entries`
Stores individual farmer milk collection records for Morning and Evening shifts.
- `id` (String, Document ID): Unique entry ID (e.g., `ENT-001` or `<farmerCode>_<yyyyMMdd>_<shift>`).
- `farmerId` (String): Reference to the farmer.
- `farmerName` (String): Denormalized farmer name for display speed.
- `farmerCode` (String): Farmer identifier code.
- `collectorId` (String): Associated collection center operator ID.
- `centerId` (String): Center name/ID (e.g., `Jaipur Center`).
- `shift` (String): `'Morning (AM)'` or `'Evening (PM)'`.
- `date` (Timestamp): Collection date and time.
- `milkType` (String): `'cow'` or `'buffalo'`.
- `quantityLitres` (Number): Litres supplied (e.g., `12.5`).
- `fatPercentage` (Number): Fat percentage (e.g., `4.2`).
- `snfPercentage` (Number): Solid-Not-Fat percentage (e.g., `8.5`).
- `temperature` (Number): Chilled milk temperature in °C (e.g., `4.0`).
- `qualityStatus` (String): `'ACCEPTED'` or `'REJECTED'`.
- `qualityGrade` (String): Quality category (`'Premium'`, `'Grade A'`, `'Good'`, `'Sub-standard'`).
- `rejectionReason` (String, optional): Explanation if quality thresholds failed.
- `ratePerLitre` (Number): Calculated payout rate per litre.
- `totalAmount` (Number): Total monetary payout (`quantity * rate`).
- `batchId` (String, optional): Assigned batch ID when packaged into a tanker dispatch batch.
- `version` (Number): Document version counter for audited corrections (default `1`).
- `updatedAt` (Timestamp, optional): Last audit modification timestamp.
- `updatedBy` (String, optional): User ID of the supervisor/collector who audited the entry.

#### Subcollection: `milk_entries/{entryId}/edits/{version}`
Immutable, append-only audit trail of corrections (PRD F5, LLD Section 2.1).
- `versionFrom` (Number): Prior version counter.
- `versionTo` (Number): Resulting version counter.
- `old` (Map): Snapshot of prior readings (`quantityLitres`, `fatPercentage`, `snfPercentage`, `ratePerLitre`, `totalAmount`).
- `new` (Map): Snapshot of audited readings.
- `reason` (String): Required reason for correction.
- `editedBy` (String): User UID or staff ID who performed the edit.
- `editedAt` (Timestamp): Server timestamp of the modification.

---

### `batches`
Aggregates multiple individual collections into a dispatch batch/tanker for transportation to the factory.
- `id` (String, Document ID): Batch identifier (e.g., `BATCH-JaipurCenter-20261025-AM`).
- `centerId` (String): Originating collection center.
- `centerName` (String): Human-readable center name.
- `shift` (String): `'Morning (AM)'` or `'Evening (PM)'`.
- `milkType` (String): `'cow'`, `'buffalo'`, or `'mixed'`.
- `date` (Timestamp): Dispatch date.
- `totalLitres` (Number): Sum of all contributing collection volumes.
- `averageFat` (Number): Weighted average Fat percentage across all collections.
- `averageSnf` (Number): Weighted average SNF percentage across all collections.
- `averageTemperature` (Number): Average temperature of the batched milk.
- `status` (String): `'PENDING'`, `'IN_TRANSIT'`, `'ACCEPTED'`, or `'REJECTED'`.
- `rejectionReason` (String, optional): Stored when the dairy factory lab rejects the batch.
- `tankerNumber` (String, optional): Road tanker license plate (e.g., `RJ-14-GA-4501`).
- `driverName` (String, optional): Transport driver name.
- `entryIds` (Array of Strings): List of `milk_entries` document IDs included in this batch.
- `farmerIds` (Array of Strings): Unique farmer IDs who supplied milk for this batch.
- `createdAt` (Timestamp): Batch creation timestamp.
- `testedAt` (Timestamp, optional): Factory laboratory inspection timestamp.
- `testedBy` (String, optional): Quality inspector identifier.

---

### `rate_charts`
Defines base dairy pricing formulas and fat/SNF rate coefficients per milk type.
- `id` (String, Document ID): Rate chart identifier (e.g., `RC-COW-2026-OCT`).
- `title` (String): Human-readable title.
- `milkType` (String): `'cow'`, `'buffalo'`, or `'mixed'`.
- `fatRate` (Number): Rate coefficient per 1% Fat (e.g., `6.80`).
- `snfRate` (Number): Rate coefficient per 1% SNF (e.g., `2.20`).
- `baseRate` (Number): Base floor rate.
- `minFat` (Number): Minimum acceptable Fat threshold (e.g., `3.2`).
- `minSnf` (Number): Minimum acceptable SNF threshold (e.g., `8.3`).
- `effectiveFrom` (Timestamp): Effective start date.
- `isActive` (Boolean): Active status flag.

---

### `disputes`
Stores formal dispute tickets raised by farmers or collection centers contesting quantity, FAT, or SNF readings.
- `id` (String, Document ID): Dispute identifier (e.g., `DSP-20261026-001`).
- `entryId` (String): ID of the contested `milk_entries` collection record.
- `farmerId` (String): Reference to the farmer.
- `farmerName` (String): Farmer's name.
- `farmerPhone` (String): Contact phone number.
- `centerId` (String): Collection center identifier.
- `collectorId` (String): Collection operator ID.
- `collectionDate` (Timestamp/String): Date and time of the disputed collection.
- `shift` (String): `'Morning (AM)'` or `'Evening (PM)'`.
- `disputeType` (String): `'Quantity Discrepancy'`, `'Fat Percentage Discrepancy'`, `'SNF Reading Dispute'`, `'Rate Calculation Error'`.
- `reason` (String): Detailed justification and evidence from the farmer.
- `recordedQuantity` (Number): Litres recorded at center.
- `claimedQuantity` (Number, optional): Litres claimed by farmer.
- `recordedFat` (Number): FAT % recorded at center.
- `claimedFat` (Number, optional): FAT % claimed by farmer.
- `recordedSnf` (Number): SNF % recorded at center.
- `claimedSnf` (Number, optional): SNF % claimed by farmer.
- `recordedAmount` (Number): Gross payment calculated originally.
- `status` (String): `'OPEN'`, `'UNDER_REVIEW'`, `'RESOLVED'`, `'REJECTED'`.
- `resolutionNote` (String, optional): Supervisor audit notes and justification.
- `adjustedAmount` (Number): Financial credit or debit applied to farmer's payout reconciliation.
- `resolvedBy` (String, optional): Name of the dairy auditor/supervisor.
- `createdAt` (Timestamp): Timestamp when dispute was opened.
- `resolvedAt` (Timestamp, optional): Timestamp when dispute was resolved/rejected.

---

### `payouts`
Stores digital reconciliation and disbursal records for billing cycles (10-day or monthly).
- `statementId` (String, Document ID): Unique reconciliation statement ID (e.g., `REC-202610-C1-F001`).
- `farmerId` (String): Associated farmer.
- `farmerName` (String): Farmer name.
- `billingCycle` (String): e.g., `'01-10 Oct 2026'`.
- `totalLitres` (Number): Reconciled total milk volume.
- `averageFat` (Number): Weighted cycle average Fat %.
- `averageSnf` (Number): Weighted cycle average SNF %.
- `grossAmount` (Number): Base milk earnings.
- `qualityIncentive` (Number): Premium quality bonus.
- `disputeAdjustment` (Number): Net credit adjustments approved via dispute resolution.
- `netPayable` (Number): Final monetary disbursal.
- `status` (String): `'PAID'`, `'PENDING'`, or `'DISPUTED'`.
- `paidAt` (String/Timestamp): Date settled.
- `paymentMethod` (String): e.g., `'Bank NEFT/RTGS'`, `'UPI'`, `'Cash'`.
- `transactionReference` (String): Bank NEFT/UTR reference code.

---

## 3. Security Rules (`firestore.rules`)
Production-grade security rules enforce role-based access control (RBAC) across all collections:
- **Farmers**: Can only read their own collection slips, dispute tickets, payouts, and notifications. Cannot delete any documents.
- **Collectors**: Can record collection entries for farmers in their center, view center summaries, and initiate audited corrections with mandatory reason notes.
- **Supervisors & QC**: Can review/resolve disputes with payout credits, conduct QC inspections on batches, and assign collections to transport tankers.
- **Admins**: Can configure rate charts, register new centers/collectors, and trigger bulk billing statements.
- **Immutability Guarantee**: Business collections and edit logs are append-only; hard deletions are forbidden (`allow delete: if false`).

---

## 4. Storage Rules (`storage.rules`)
Firebase Storage paths are guarded to guarantee tenant privacy:
- `/slips/{farmerId}/{file}`: Farmers can access their own digital slips; staff can generate/view slips.
- `/bills/{farmerId}/{file}`: Farmer-specific billing statements and payment receipts.
- `/exports/{file}`: Cooperative-level Excel and PDF summaries accessible by administrative staff.
- `/qc/{lotId}/{file}`: Factory laboratory test photos and adulteration evidence (images restricted to < 5MB).

---

## 5. Composite Database Indexes (`firestore.indexes.json`)
Pre-configured composite indexes prevent query errors when filtering and ordering simultaneously:
- `milk_entries` (farmerId ASC, date DESC)
- `milk_entries` (centerId ASC, date DESC)
- `milk_entries` (qualityStatus ASC, date DESC)
- `milk_entries` (batchId ASC, date DESC)
- `milk_entries` (date ASC, shift ASC)
- `disputes` (farmerId ASC, createdAt DESC)
- `disputes` (centerId ASC, createdAt DESC)
- `disputes` (status ASC, createdAt DESC)
- `batches` (centerId ASC, createdAt DESC)
- `batches` (status ASC, createdAt DESC)
- `farmers` (center ASC, name ASC)
- `payouts` (farmerId ASC, periodTo DESC)
- `rate_charts` (isActive ASC, effectiveFrom DESC)

---

## 6. Offline Synchronization & Shift Close Engine
Implemented in `SyncService`:
- Automatically queues writes to Firestore's local cache during offline center operations.
- **Shift Close Reconciliation**: Compares the collector's on-device collection counts and litres with the cloud server database at shift end, immediately surfacing any un-synced collections or variances before closing the center.

---

## 7. Database Seeding & Mock Data
A complete seeder is provided in `lib/services/database_seeder.dart` and can be executed via:
```bash
dart run scripts/seed_database.dart
```
This provisions all 8 collections with realistic test data across 4 centers for automated testing, local emulators, or production initialization.
