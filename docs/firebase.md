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

### Upcoming Collections
- `collections`: To store individual milk readings (quantity, fat, snf, etc.).
- `batches`: To store combined collections for traceability.
- `collection_centers`: To map operators and farmers to specific locations.

## Authentication
Currently using Firebase Email/Password authentication.
- Implemented in `lib/services/auth_service.dart`.
- Includes `registerUser`, `loginUser`, `logoutUser`, and `getCurrentUser`.

## Security Rules (Phase 1)
Currently, all collections are secured to require an authenticated user (`request.auth != null`). Granular role-based access control (RBAC) will be implemented in later stages.
