# Farm2Factory — Mobile & Web Platform

> Dairy Cooperative Milk Collection, Quality Analysis, and Farmer Settlement Platform built with Flutter and Dart.

---

## 🚀 Overview

**Farm2Factory** is a cross-platform Flutter application tailored for dairy cooperatives in India. It links dairy farmers, village milk collection centers, and dairy processing plant administrators into a unified, transparent digital ledger system.

---

## 🛠️ Toolchain Setup & Requirements

- **Flutter SDK**: 3.47.6 or higher (stable channel)
- **Dart SDK**: 3.13.5 or higher
- **JDK**: OpenJDK 17 (Temurin recommended)
- **Android SDK**: API level 34+ / Build Tools 34.0.0+ / 36.0.0
- **Platforms**: Android, Web (Chrome), Windows Desktop

### Environment Configuration
```powershell
# Set Java 17 and Android SDK environment variables
$env:JAVA_HOME = "C:\Android\jdk-17"
$env:ANDROID_HOME = "C:\Android\android-sdk"
$env:PATH = "$env:JAVA_HOME\bin;$env:ANDROID_HOME\platform-tools;$env:ANDROID_HOME\cmdline-tools\latest\bin;" + $env:PATH

# Verify toolchain health
flutter doctor -v
```

---

## 📦 Project Structure

```text
SW2627-DART-FLUTTER-Farm2Factory/
├── flutter_application_1/
│   ├── lib/
│   │   ├── main.dart             # Application entry point & Firebase init
│   │   ├── app.dart              # Global app wrapper & router config
│   │   ├── firebase_options.dart # Multi-platform Firebase credentials
│   │   ├── models/               # Domain models (Farmer, MilkEntry, RateChart, etc.)
│   │   ├── services/             # Firebase Auth, Firestore, and Sync engines
│   │   └── screens/              # UI screens (Collector, Farmer, Admin portals)
│   ├── pubspec.yaml              # Project manifest, dependencies (intl, Firebase, etc.)
│   ├── android/                  # Native Android configuration & Gradle build scripts
│   ├── web/                      # Web entry point & assets
│   ├── windows/                  # Windows desktop native harness
│   └── test/                     # Unit and widget test suite
├── docs/
│   └── evidence/                 # Verification outputs & running app screenshots
└── README.md
```

---

## ⚡ Developer Workflow

### 1. Fetch Dependencies
```bash
cd flutter_application_1
flutter pub get
```

### 2. Static Analysis
```bash
flutter analyze
```
*Baseline requirement: 0 issues, 0 errors, 0 warnings.*

### 3. Run on Connected Device
```bash
# List available target devices
flutter devices

# Launch on Chrome or connected Android emulator
flutter run -d chrome
```

### 4. Interactive Reloading
- **Hot Reload (`r`)**: Injects updated source code into the active Dart VM in under a second while **preserving application state** (current forms, scroll positions, session tokens).
- **Hot Restart (`R`)**: Resets all state and re-executes from `main()`. Use when changing global singletons, static variables, or constructor initializers.

### 5. Production / Debug Build
```bash
flutter build apk --debug
```

---

## 📋 Verification Evidence

All baseline verification outputs are preserved under [`docs/evidence/`](docs/evidence/):
- [`flutter_doctor.txt`](docs/evidence/flutter_doctor.txt) — Clean toolchain diagnosis
- [`flutter_analyze.txt`](docs/evidence/flutter_analyze.txt) — 0 issues static analysis report
- [`flutter_build_apk.txt`](docs/evidence/flutter_build_apk.txt) — Successful Gradle APK build log
- [`app_running.png`](docs/evidence/app_running.png) — Screenshot of the running Farm2Factory application
