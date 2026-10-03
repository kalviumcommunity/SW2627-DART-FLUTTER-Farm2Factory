# Farm2Factory: Low-Level Design (LLD)

| | |
|---|---|
| Version | 0.1 (draft) |
| Related | `PRD.md`, `HLD.md` |

The LLD gives implementation detail: schema, rules, algorithms, module structure and tests. Start with the MVP tables; the rest can wait for later phases.

---

## 1. Conventions

- IDs: `uuid` primary keys (generated on device for offline records).
- Times: `timestamptz` in UTC; displayed in local time (IST).
- Money: `numeric(12,2)`. Quantity: `numeric(8,1)`. Fat/SNF: `numeric(4,2)`.
- Tables: snake_case, plural. Columns: snake_case.
- Every business table has `created_at`, and `dairy_id` for access control.
- Business data is never hard-deleted.

Human-readable codes:
- Farmer: `F-<center>-<number>` (example `F-BHN-0123`)
- Collector: `C-<center>-<number>`
- Lot: `LOT-<yyyymmdd>-<shift>-<tanker>`

---

## 2. Database schema (MVP first)

```sql
-- ENUMS
create type user_role as enum ('admin','supervisor','collector','qc','farmer');
create type shift_type as enum ('AM','PM');
create type sync_status as enum ('pending','synced','failed');

-- ORGANISATION
create table dairies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz not null default now()
);

create table centers (
  id uuid primary key default gen_random_uuid(),
  dairy_id uuid not null references dairies(id),
  code text not null,
  name text not null,
  village text, district text, state text,
  lat numeric(9,6), lng numeric(9,6),
  unique (dairy_id, code)
);

-- USERS (linked to Supabase auth.users)
create table profiles (
  id uuid primary key references auth.users(id),
  dairy_id uuid not null references dairies(id),
  role user_role not null,
  full_name text not null,
  phone text,
  language text not null default 'hi',
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table farmers (
  id uuid primary key default gen_random_uuid(),
  dairy_id uuid not null references dairies(id),
  center_id uuid not null references centers(id),
  profile_id uuid unique references profiles(id),
  farmer_code text not null,
  village text,
  animal_type text,                 -- cow / buffalo / mixed
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  unique (dairy_id, farmer_code)
);

create table collectors (
  id uuid primary key default gen_random_uuid(),
  dairy_id uuid not null references dairies(id),
  center_id uuid references centers(id),
  profile_id uuid unique not null references profiles(id),
  collector_code text not null,
  vehicle_no text,
  unique (dairy_id, collector_code)
);

-- RATES
create table rate_charts (
  id uuid primary key default gen_random_uuid(),
  dairy_id uuid not null references dairies(id),
  name text not null,
  method text not null check (method in ('chart','formula')),
  fat_rate numeric(8,3),            -- formula method: price per fat point
  snf_rate numeric(8,3),            -- formula method: price per SNF point
  effective_from date not null,
  created_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

create table rate_chart_rows (
  id uuid primary key default gen_random_uuid(),
  chart_id uuid not null references rate_charts(id) on delete cascade,
  fat_min numeric(4,2) not null, fat_max numeric(4,2) not null,
  snf_min numeric(4,2) not null, snf_max numeric(4,2) not null,
  rate_per_litre numeric(8,2) not null,
  check (fat_min <= fat_max and snf_min <= snf_max)
);

-- COLLECTIONS (current state)
create table collections (
  id uuid primary key,                          -- generated on device
  dairy_id uuid not null references dairies(id),
  center_id uuid not null references centers(id),
  farmer_id uuid not null references farmers(id),
  collector_id uuid not null references collectors(id),
  collected_on date not null,
  shift shift_type not null,
  quantity_l numeric(8,1) not null check (quantity_l > 0),
  fat numeric(4,2) not null check (fat between 0 and 15),
  snf numeric(4,2) not null check (snf between 0 and 15),
  rate_chart_id uuid not null references rate_charts(id),
  rate_per_litre numeric(8,2) not null,         -- snapshot
  amount numeric(12,2) not null,                -- snapshot
  version int not null default 1,
  device_time timestamptz not null,
  server_time timestamptz not null default now(),
  lot_id uuid,                                  -- set when assigned to a lot
  unique (farmer_id, collected_on, shift)       -- one entry per farmer per shift
);
create index on collections (farmer_id, collected_on desc);
create index on collections (center_id, collected_on desc);

-- AUDIT OF CORRECTIONS (append only)
create table collection_edits (
  id uuid primary key default gen_random_uuid(),
  collection_id uuid not null references collections(id),
  version_from int not null, version_to int not null,
  old_values jsonb not null, new_values jsonb not null,
  reason text not null,
  edited_by uuid not null references profiles(id),
  edited_at timestamptz not null default now()
);

-- NOTIFICATIONS
create table notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references profiles(id),
  type text not null,                           -- entry_corrected, payout, warning
  title text not null, body text not null,
  payload jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);
```

### Phase 2 tables (Next and Later)

```sql
create table tankers (
  id uuid primary key default gen_random_uuid(),
  dairy_id uuid not null references dairies(id),
  vehicle_no text not null, driver_name text
);

create table lots (
  id uuid primary key default gen_random_uuid(),
  dairy_id uuid not null references dairies(id),
  lot_code text not null unique,
  tanker_id uuid references tankers(id),
  received_on date not null, shift shift_type not null,
  total_litres numeric(10,1),
  status text not null default 'received'       -- received / accepted / rejected
);
alter table collections add foreign key (lot_id) references lots(id);

create table qc_tests (
  id uuid primary key default gen_random_uuid(),
  lot_id uuid not null references lots(id),
  fat numeric(4,2), snf numeric(4,2),
  adulteration_found boolean not null default false,
  grade text check (grade in ('A','B','C','Rejected')),
  tested_by uuid not null references profiles(id),
  tested_at timestamptz not null default now(),
  notes text
);

create table payouts (
  id uuid primary key default gen_random_uuid(),
  farmer_id uuid not null references farmers(id),
  period_from date not null, period_to date not null,
  total_litres numeric(10,1) not null,
  total_amount numeric(12,2) not null,
  status text not null default 'unpaid',        -- unpaid / paid
  mode text, paid_at timestamptz, reference text,
  unique (farmer_id, period_from, period_to)
);

create table disputes (
  id uuid primary key default gen_random_uuid(),
  collection_id uuid not null references collections(id),
  raised_by uuid not null references profiles(id),
  reason text not null,
  status text not null default 'open',          -- open / resolved / rejected
  resolution_note text, resolved_by uuid references profiles(id),
  created_at timestamptz not null default now(), resolved_at timestamptz
);

create table audit_log (
  id bigint generated always as identity primary key,
  actor uuid, action text not null, entity text not null, entity_id text,
  details jsonb, at timestamptz not null default now()
);
```

---

## 3. Access control (Row Level Security)

```sql
alter table collections enable row level security;

-- helper functions
create function auth_role() returns user_role language sql stable as
  $$ select role from profiles where id = auth.uid() $$;
create function auth_dairy() returns uuid language sql stable as
  $$ select dairy_id from profiles where id = auth.uid() $$;

-- farmer reads only own rows
create policy farmer_read on collections for select
  using (auth_role() = 'farmer' and farmer_id in
         (select id from farmers where profile_id = auth.uid()));

-- collector reads and inserts for own center
create policy collector_read on collections for select
  using (auth_role() = 'collector' and center_id in
         (select center_id from collectors where profile_id = auth.uid()));
create policy collector_insert on collections for insert
  with check (auth_role() = 'collector' and center_id in
         (select center_id from collectors where profile_id = auth.uid()));

-- supervisor/admin read whole dairy
create policy mgmt_read on collections for select
  using (auth_role() in ('supervisor','admin') and dairy_id = auth_dairy());

-- NO update or delete policies: changes only through correct_collection()
```

Apply the same pattern to every table (farmers, lots, qc_tests, payouts and so on). Write a test for each policy.

---

## 4. Server functions (RPC)

| Function | Input | Rules |
|---|---|---|
| `create_user(role, name, phone, center_id)` | admin/collector call | Creates auth user + profile + farmer/collector row; returns code and temporary PIN |
| `upsert_collection(payload)` | collector | Validates ranges; recomputes rate and amount server-side; idempotent by `id`; rejects duplicate farmer+date+shift with a clear error |
| `correct_collection(id, new_qty, new_fat, new_snf, reason, expected_version)` | collector (same day) / supervisor | Checks `version = expected_version`, writes `collection_edits`, updates row, increments version, creates notification |
| `get_changes(since timestamptz)` | any | Returns rows changed after cursor (filtered by RLS) |
| `generate_bill(farmer_id or center_id, from, to)` | admin | Sums stored amounts; creates payout rows; returns PDF link |
| `reject_lot(lot_id, reason)` | supervisor/qc | Sets lot status, returns affected farmers |
| `trace_lot(lot_id)` | supervisor | Lot to collections to farmers and collectors |

---

## 5. Rate calculation algorithm

```
function calculateRate(chart, fat, snf):
    if chart.method == 'chart':
        row = chart.rows.first(r => fat >= r.fat_min && fat <= r.fat_max
                                 && snf >= r.snf_min && snf <= r.snf_max)
        if row == null: throw RateNotFound(fat, snf)
        return row.rate_per_litre
    else:  // formula
        return round(fat * chart.fat_rate + snf * chart.snf_rate, 2)

amount = round(quantity_l * rate_per_litre, 2)
```

Rules:
- Pick the chart with the latest `effective_from <= collected_on` for the dairy.
- The client calculates for display; the **server recalculates** and its value is stored.
- Round half up to 2 decimals. Use a decimal type, not floating point, in Dart (`decimal` package) and Postgres (`numeric`).
- Validate charts at save time: no overlapping ranges, no gaps.

Validation limits (configurable per dairy): quantity 0.5 to 200 L; fat 1.0 to 12.0; SNF 5.0 to 12.0.

---

## 6. Sync design (client)

### Local tables (Drift)

```
local_collections   (same columns as collections + sync_status, last_error, tries)
outbox              (id, entity, entity_id, action, payload_json, created_at, tries, last_error)
cache_farmers       (id, code, name, village, center_id)
cache_rate_charts   (chart + rows)
sync_state          (key, value)         -- last_cursor
```

### Push algorithm

```
on connectivity restored OR every 60 s while online:
    items = outbox ORDER BY created_at LIMIT 50
    for item in items:
        try:
            call rpc(item.action, item.payload)       // idempotent
            mark local row synced; delete outbox item
        catch NetworkError:  stop loop            // try later
        catch ValidationError(e):
            mark item failed, store e; notify user to fix
        catch ConflictError (version mismatch):
            pull latest row; mark item needs-review
    use exponential backoff: 5s, 15s, 60s, 5m
```

### Pull algorithm

```
cursor = sync_state.last_cursor
rows = rpc get_changes(cursor)
upsert into local tables in one transaction
sync_state.last_cursor = max(rows.server_time)
```

Rules:
- Save local write and outbox row in **one transaction**.
- Never delete an outbox item before a confirmed server response.
- Show pending count in the UI. Show failed items with a "retry" and "export" action.

---

## 7. Flutter module structure

```
app/lib/
├─ main.dart
├─ app.dart                      MaterialApp, theme, router, l10n
├─ core/
│  ├─ config/                    env, constants
│  ├─ theme/                     light, dark, text scale
│  ├─ l10n/                      app_en.arb, app_hi.arb
│  ├─ utils/                     decimal helpers, date helpers, validators
│  └─ widgets/                   shared buttons, empty states, sync banner
├─ data/
│  ├─ local/                     drift database, DAOs, tables
│  ├─ remote/                    supabase client, RPC wrappers
│  ├─ repositories/              collection_repo, farmer_repo, rate_repo, ...
│  └─ sync/                      outbox_service, sync_engine, connectivity
├─ domain/
│  ├─ models/                    Collection, Farmer, RateChart, ...
│  └─ services/                  rate_calculator, validators
└─ features/
   ├─ auth/                      login screen, auth controller, role router
   ├─ collector/                 home, add_entry, farmers_list, entries, sync_status
   ├─ farmer/                    home, records, payments, profile
   ├─ admin/                     dashboard, collectors, farmers, rate_chart, reports
   ├─ qc/                        lots, add_test
   └─ notifications/             inbox
```

Rules:
- Screens never call Supabase directly; they call repositories through Riverpod providers.
- Repositories read and write the **local** database first; the sync engine handles the server.
- Keep `rate_calculator` pure and unit-tested.

### Key interfaces (sketch)

```dart
abstract class CollectionRepository {
  Future<void> addEntry(NewCollection input);          // local save + outbox
  Future<void> correctEntry(String id, Correction c);  // online or queued
  Stream<List<Collection>> watchForFarmer(String farmerId, DateRange range);
  Stream<List<Collection>> watchToday(String centerId);
  Stream<int> watchPendingCount();
}

class RateCalculator {
  RateResult calculate(RateChart chart, Decimal fat, Decimal snf, Decimal qty);
}
```

---

## 8. Screens (MVP)

| Role | Screen | Key elements |
|---|---|---|
| All | Login | ID, PIN, language toggle |
| Collector | Home | Today's AM/PM totals, Add Entry, Farmers List, Pending Sync |
| Collector | Add Entry | Farmer search, quantity, fat, SNF, live rate and amount, Save |
| Collector | Entries | Today's list, tap to correct (reason required) |
| Farmer | Home | Farmer ID card, tabs Today / 10 Days / Month, totals |
| Farmer | Records | Table: date, quantity, fat, rate, amount, time |
| Farmer | Notifications | Entry-corrected alerts |
| Admin | Rate chart | Add chart, rows, effective date, validation errors |
| Admin | Users | Create collector or farmer, reset PIN |

---

## 9. State machines

**Collection entry**
`created (local, pending)` -> `synced` -> `corrected (version n)` -> ... (no delete).
Failed sync: `pending` -> `failed` -> (fix) -> `pending`.

**Lot**
`received` -> `accepted` | `rejected`.

**Payout**
`unpaid` -> `paid` (with mode, reference, time).

**Dispute**
`open` -> `resolved` | `rejected`.

---

## 10. Error handling

| Case | Behaviour |
|---|---|
| No internet | Save locally; show pending banner |
| Duplicate farmer + shift + date | Warn; open the existing entry for correction |
| Value out of range | Ask for confirmation; log the override |
| No rate for fat/SNF | Block save; message "Rate chart missing for this reading" |
| Stale version on correction | Show latest values; ask to redo |
| Token expired offline | Keep local data; ask to log in when online; do not lose outbox |
| Phone clock wrong | Store device_time and server_time; flag gap above 10 minutes |
| App crash mid-save | Local transaction ensures all-or-nothing |

---

## 11. Testing plan

| Level | What | Tools |
|---|---|---|
| Unit | Rate calculator, validators, decimal rounding | `flutter_test` |
| Unit | Outbox and sync logic with fake remote | `mocktail` |
| Database | RLS policies: farmer cannot read others; collector cannot read other centers; no update or delete | SQL tests (pgTAP) |
| Widget | Add Entry form, farmer list | `flutter_test` |
| Integration | Airplane-mode shift, then sync, no duplicates | `integration_test` |
| Device | Low-end Android phone, slow network | Manual |
| UAT | Real operator and supervisor at pilot | Checklist |

**Acceptance test examples**
- Collector records 50 entries offline, goes online: 50 entries on server, zero duplicates.
- Farmer A logs in: query for Farmer B's rows returns nothing.
- Correct an entry: edit log row exists, version is 2, farmer gets a notification.
- Change rate chart effective tomorrow: today's entries keep old rates.

---

## 12. Reports

- **Daily center report:** litres per shift, average fat/SNF, entry count.
- **10-day / monthly bill per farmer:** date rows, totals, average fat/SNF, amount. PDF with farmer code and period.
- **Excel export:** same data as flat rows.
- Generated on device for single farmers; by server function for bulk.

---

## 13. Build order (maps to roadmap)

1. Schema + RLS + seed data for one dairy, one center, three farmers.
2. Auth and role router.
3. Rate chart screen and `RateCalculator` with unit tests.
4. Local DB, Add Entry (offline), outbox, sync engine.
5. Farmer records screen and pull sync.
6. Correction flow and notification.
7. Admin dashboard, bills, exports.
8. QC, lots, trace.
9. Pilot hardening: logging, crash reporting, backups.
