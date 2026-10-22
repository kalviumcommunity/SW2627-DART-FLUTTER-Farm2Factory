# Firebase Architecture & Setup

## Overview
This document outlines the Firebase setup and Firestore schema for the Dairy Cooperative digital milk collection system.

## Setup Instructions (Flutter)
1. Firebase Core, Auth, and Cloud Firestore dependencies have been added to `pubspec.yaml`.
2. Ensure you have the `firebase-tools` CLI installed and run `flutterfire configure` to generate `firebase_options.dart`.
3. In `main.dart`, initialize Firebase before running the app:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   ```

## Collections & Schema

### `users`
Stores application users (Admins, Collection Center Operators).
- `uid` (String, Document ID): Unique identifier from Firebase Auth.
- `email` (String): User's email.
- `name` (String): Full name.
- `role` (String): e.g., 'admin', 'operator'.

### `farmers`
Stores farmer profiles.
- `id` (String, Document ID): Unique farmer ID (e.g., FMR-1024).
- `name` (String): Full name.
- `phone` (String): Contact number.
- `village` (String): Village name.
- `centerId` (String): The ID of the collection center they belong to.
- `status` (String): 'active' or 'inactive'.
- `createdAt` (Timestamp): Record creation time.

### `milk_entries`
Stores individual farmer milk collection records for Morning and Evening shifts.
- `id` (String, Document ID): Unique entry ID (e.g., `ENT-1024`).
- `farmerId` (String): Reference to the farmer.
- `farmerName` (String): Denormalized farmer name for display speed.
- `farmerCode` (String): Farmer identifier code.
- `collectorId` (String): Associated collection center operator ID.
- `centerId` (String): Center name/ID (e.g., `Jaipur Center`).
- `shift` (String): `'Morning (AM)'` or `'Evening (PM)'`.
- `date` (Timestamp): Collection date and time.
- `milkType` (String): `'cow'` or `'buffalo'`.
- `quantityLitres` (Number): Litres supplied (e.g., `15.5`).
- `fatPercentage` (Number): Fat percentage (e.g., `4.2`).
- `snfPercentage` (Number): Solid-Not-Fat percentage (e.g., `8.5`).
- `temperature` (Number): Chilled milk temperature in °C (e.g., `4.0`).
- `qualityStatus` (String): `'ACCEPTED'` or `'REJECTED'`.
- `qualityGrade` (String): Quality category (`'Premium'`, `'Good'`, `'Fair'`, `'Substandard'`).
- `rejectionReason` (String, optional): Explanation if quality thresholds failed.
- `ratePerLitre` (Number): Calculated payout rate per litre.
- `totalAmount` (Number): Total monetary payout (`quantity * rate`).
- `batchId` (String, optional): Assigned batch ID when this collection is packaged into a tanker dispatch batch.

### `batches`
Aggregates multiple individual collections into a dispatch batch/tanker for transportation to the factory.
- `id` (String, Document ID): Batch identifier (e.g., `BATCH-JaipurCenter-20261015-AM-104`).
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

### `payouts`
Stores digital reconciliation and disbursal records for billing cycles (10-day or monthly).
- `statementId` (String, Document ID): Unique reconciliation statement ID (e.g., `REC-202610-F001`).
- `farmerId` (String): Associated farmer.
- `farmerName` (String): Farmer name.
- `totalLitres` (Number): Reconciled total milk volume.
- `netPayable` (Number): Net monetary disbursal after quality adjustments and deductions.
- `status` (String): `'PAID'`, `'PENDING'`, or `'DISPUTED'`.
- `paidAt` (Timestamp): Timestamp when payment was settled.
- `paymentMethod` (String): e.g., `'Bank NEFT/RTGS'`, `'UPI'`, `'Cash'`.
- `transactionReference` (String): Bank NEFT/UTR reference code.

## Batch Traceability Engine
The system directly addresses the core problem statement: *“late-detected quality shortfalls lead to batch rejections that cannot be traced back to source.”*

When a batch is inspected or rejected at the factory:
1. `BatchService.traceBatchSources(batchId)` queries all `milk_entries` where `batchId == batchId`.
2. It aggregates every contributing farmer and collection reading.
3. It flags suspect collections (e.g., low fat `< 3.5%`, low SNF `< 8.2%`, or high temperature `> 6°C`) that triggered the batch rejection.
4. The factory manager can view the list of responsible farmers and exact collection timestamps in `BatchTraceabilityScreen`.

## Month-End Reconciliation & Dispute Resolution Engine
The system eliminates paper-based reconciliation disputes:
1. `ReconciliationService.getReconciliationForCycle()` aggregates morning and evening shift collections across a 10-day or monthly cycle.
2. It calculates weighted average Fat % and SNF %, gross earnings, quality variance deductions, and net payable.
3. Farmers and collectors can audit line-by-line shift readings in `PaymentsScreen` to resolve reading disputes before payment execution.
4. Generates a bank-ready NEFT reconciliation CSV via `exportReconciliationCsv()` for automated bank transfer uploads.

## Authentication
Using Firebase Email/Password authentication.
- Implemented in `lib/services/auth_service.dart`.
- Includes `registerUser`, `loginUser`, `logoutUser`, and `getCurrentUser`.

## Security Rules
All collections require an authenticated user (`request.auth != null`). Role-based access control (RBAC) restricts farmers, collectors, and admins based on custom claims or user profile documents.
