# Farm2Factory: Product Requirements Document (PRD)

| | |
|---|---|
| Version | 0.1 (draft) |
| Status | For review with one operator and one supervisor |
| Owner | (your name) |

---

## 1. Overview and problem

Farm2Factory is a mobile and web system for dairy cooperatives. It replaces paper records of milk quantity and quality at collection centers with one digital, offline-capable record shared by farmers, collectors and the dairy.

**Problem:** A cooperative collects milk from hundreds of farmers every morning and evening, but quantity and quality readings (fat, SNF) are written on paper. Month-end reconciliation takes several days, disputes over readings are frequent, and quality shortfalls are found late, so rejected batches cannot be traced back to their source.

**Impact:** Staff lose days every month on manual bill calculation, farmers distrust the numbers, and the dairy cannot quickly find which supply caused a rejected batch.

**Who it is for:** (1) Dairy / plant administration, (2) collectors / center operators, (3) farmers.

---

## 2. Goals and success metrics

| # | Goal | Target |
|---|---|---|
| G1 | Month-end bill closing time | Under 2 hours (from several days) |
| G2 | Disputes over readings | Down 70% within 3 months of pilot |
| G3 | Trace a rejected tanker/lot to its farmers | Under 1 minute |
| G4 | Time to record one farmer's entry | Under 20 seconds |
| G5 | Offline entries synced without manual help | 99% or more |
| G6 | Farmers who check their records in the app weekly | 60% or more of pilot farmers |

**Not in scope (MVP):** payment gateway and online payouts, hardware/analyzer integration, languages beyond Hindi and English, multi-dairy (multi-tenant) billing, ML or forecasting.

---

## 3. Users and roles

| Role | Needs to do | Main difficulty |
|---|---|---|
| Farmer | See daily quantity, fat, SNF, rate, amount, entry timestamps, edit alerts, payment history | May have low literacy and basic phone; needs simple screens in Hindi |
| Collector / center operator | Record each farmer's milk fast, see totals, send data to dairy | Busy queue at the center; poor internet; wants zero typing errors |
| Plant QC worker | Record QC tests on tanker/lot, grade it, flag bad supply | Needs to link a test to the right tanker and farmers |
| Supervisor (dairy manager) | See daily totals per collector, average quality, warn collectors on poor quality | Needs one overview, not raw lists |
| Admin | Create centers, collectors, farmers; set rate charts; export reports | Must keep IDs and rates correct |

IDs: roles are assigned by admin only. There is **no public sign-up**.

---

## 4. User stories

**Auth and accounts**
1. As an admin, I can create collectors, farmers and centers so that only real people get access.
2. As a user, I can log in with my ID and PIN (or phone OTP) so that I see only what my role allows.
3. As a user, I can switch language (Hindi/English) and day/night mode so that the app is comfortable for me.

**Collection entry**
4. As a collector, I can record milk quantity, fat and SNF for a farmer in under 20 seconds so that the queue keeps moving.
5. As a collector, I can record entries with no internet so that work never stops.
6. As a collector, I see the calculated rate and amount immediately so that I can tell the farmer.
7. As a collector, I can see pending sync entries so that I know nothing is lost.
8. As a collector, I can correct a wrong entry with a reason so that mistakes are fixed without hiding history.
9. As a collector, I can see today's total per shift so that I can cross-check with the tanker.

**Farmer view**
10. As a farmer, I can see today's quantity, fat, SNF and rate so that I can check I was paid fairly.
11. As a farmer, I can see my last 10 days and this month's total so that I know my expected bill.
12. As a farmer, I can see the timestamp of each entry so that no one can change it silently.
13. As a farmer, I get a notification if an entry is corrected (old value to new value, time) so that I trust the record.
14. As a farmer, I can see payment history for the last 6 months so that I can verify payouts.

**Supervisor / admin**
15. As a supervisor, I can see daily litres, average fat/SNF and grade mix per collector so that I know supply quality.
16. As a supervisor, I can warn a collector about poor-quality supply from the app so that issues are fixed early.
17. As an admin, I can configure the rate chart with an effective date so that rate changes never alter past bills.
18. As an admin, I can generate a 10-day or monthly bill per farmer as PDF so that month-end takes hours not days.
19. As an admin, I can export records as PDF/Excel so that I can keep long-term archives.

**QC and traceability**
20. As QC staff, I can record a test (fat, SNF, adulteration check, grade) against a tanker/lot so that quality is recorded at the plant.
21. As a supervisor, I can open a rejected lot and see all farmers who contributed so that I can trace the source in under a minute.

**Disputes**
22. As a farmer, I can raise a dispute on an entry so that it is reviewed against recorded data.
23. As a supervisor, I can resolve a dispute with a note so that the outcome is recorded.

---

## 5. Features and priorities

| Feature | Stories | Priority |
|---|---|---|
| F1. Login, roles, account creation | 1, 2 | **MVP** |
| F2. Rate chart setup | 17 | **MVP** |
| F3. Collection entry (offline) | 4, 5, 6, 7, 9 | **MVP** |
| F4. Farmer view | 10, 11, 12 | **MVP** |
| F5. Entry correction with audit log | 8, 13 | **MVP** |
| F6. Hindi/English, dark mode | 3 | **MVP** |
| F7. Admin dashboard | 15 | Next |
| F8. Bills and exports (PDF/Excel) | 18, 19 | Next |
| F9. Notifications | 13, 16 | Next (correction alert in MVP if easy) |
| F10. QC tests and lots/tankers | 20, 21 | Next |
| F11. Payment history (recorded manually) | 14 | Next |
| F12. Disputes workflow | 22, 23 | Later |
| F13. Online payments (gateway) | n/a | Later |
| F14. Analyzer integration, device transfer | n/a | Later |

**MVP = login + rate chart + collection entry (offline) + farmer view + audited corrections.**

---

## 6. Functional details (MVP)

### F1. Login and roles
- Fields: ID (Farmer ID, collector ID or email), PIN/password. Optional phone OTP.
- Roles: `admin`, `supervisor`, `collector`, `qc`, `farmer`. Role decides the home screen.
- Rules: PIN of at least 4 digits for farmers (6+ for staff); 5 failed attempts locks the account for 15 minutes; admin can reset.
- Offline: after first login, the session works offline.
- Errors: wrong credentials show a clear message in the selected language.

### F2. Rate chart
- Admin picks a method: **chart** (fat range x SNF range = rate per litre) or **formula** (fat rate and SNF rate per unit).
- Each chart has an effective-from date. Entries use the chart active on their date.
- Rule: ranges must not overlap or leave gaps; the app validates before saving.
- Each collection stores a snapshot of the rate used.

### F3. Collection entry
- Screen fields: farmer (search by ID or name, or scan QR later), shift (auto: AM/PM), quantity (litres, 1 decimal), fat % (1 to 2 decimals), SNF % (1 to 2 decimals).
- Auto-calculated and shown before saving: rate per litre, amount.
- Validation: quantity 0.5 to 200 L; fat 1.0 to 12.0; SNF 5.0 to 12.0 (configurable). Out-of-range asks for confirmation.
- Duplicate guard: the same farmer and shift on the same day warns "already recorded".
- Save writes to the local database first, then queues for sync.
- Offline: fully functional. A banner shows "Pending sync: N".
- On sync failure: entries stay on the device and retry automatically. The collector can export a PDF or share a summary as a backup.

### F4. Farmer view
- Tabs: Today, This Month, Last 10 Days.
- Each row: date, shift, quantity, fat, SNF, rate, amount, entry time.
- Totals: litres and amount for the period.
- Farmers see **only their own** records (enforced on the server).
- Offline: shows last synced data with a "last updated" time.

### F5. Corrections and audit log
- Entries are never overwritten. A correction needs a reason and creates a new version.
- The log stores old values, new values, who, when and why.
- The farmer gets a notification: "Entry of 10 Sep AM changed from 120 L to 125 L at 07:45".
- Collectors can correct only within a set window (default: same day); later corrections need a supervisor.

### F6. Language and theme
- Hindi and English via translation files; day/night mode; large readable fonts.

---

## 7. Non-functional requirements

- **Offline-first:** collection entry and viewing work with no internet; automatic sync later.
- **Low-end phones:** runs on Android 8+ with 2 GB RAM; APK under 30 MB; no heavy animations.
- **Security:** each farmer sees only their own data; role-based access enforced on the server; PINs hashed; HTTPS only.
- **Auditability:** every edit logged with timestamps; device time and server time both stored.
- **Reliability:** no data loss on app crash or phone restart; sync is idempotent (no duplicates).
- **Performance:** entry save under 1 second; farmer screen loads under 3 seconds on 3G.
- **Data retention:** nothing is deleted. Farmers see 6 months, collectors up to 12 months in the app; older data is archived and exportable by admin.
- **Scalability:** supports 10,000 farmers and 500 collectors per dairy without redesign.
- **Localization:** Hindi and English; more languages addable through translation files.

---

## 8. Data model (summary)

Main entities: dairies, centers, users/profiles (roles), farmers, collectors, rate charts and rows, collections, collection edits, tankers, lots, lot-collections, QC tests, disputes, payouts, notifications, audit log.

Key links: collection belongs to farmer, center, collector, shift. A lot groups many collections. QC test belongs to a lot. A payout covers a farmer and a period.

Full schema: see `LLD.md`.

---

## 9. Roadmap and risks

| Phase | Weeks | Done when |
|---|---|---|
| 0. Foundation | 1-2 | App runs on a phone; operator has reviewed sketches |
| 1. Auth and roles | 3-4 | A farmer cannot read another farmer's data (tested) |
| 2. Collection entry | 5-8 | Collector completes a full shift offline; sync has no duplicates |
| 3. Farmer view | 9-10 | Farmer totals match collector records |
| 4. Admin portal | 11-14 | Month-end bills generated in minutes |
| 5. QC and traceability | 15-18 | Rejected lot traced to farmers in under 1 minute |
| 6. Pilot | 19-22 | Two weeks of real daily use at one center, paper kept as backup |
| 7. Payments and scale | later | Gateway live; disputes workflow |

| Risk | Handling |
|---|---|
| Poor internet | Offline-first; test in airplane mode from week 1 |
| Users resist change | Pilot with paper in parallel; minimal entry screen; train operators |
| Wrong rate rules | Get a real rate chart before Phase 2; make rates configurable |
| Disputes continue | Immutable log, dual timestamps, farmer notifications |
| Scope creep | Hold to MVP list; add to backlog, not to current phase |
| Low-end devices | Test on an old phone; keep UI light |
| Privacy of farmer data | Row-level security; no sensitive data in logs |

---

## 10. Open questions and review

- Who pays farmers (dairy or collector), how often (10-day, monthly), and by what mode?
- Which fat/SNF analyzer do centers use, and does it export data?
- Is the rate chart per dairy or per center, and how often does it change?
- Do all farmers have smartphones, or is SMS / collector-shown screen needed?
- Can one collector serve more than one center?
- What farmer ID format will be used (suggestion: `F-<center>-<number>`)?
- What is the correction window for collectors?

**Review plan:** show this draft and the screen sketches to one real operator and one supervisor; note every point where they are confused and fix it before Phase 2.
