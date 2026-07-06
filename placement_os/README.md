# Placement OS

Production-ready Flutter Android app for placement preparation.

## Setup

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.2+).
2. Configure Firebase:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates `lib/firebase_options.dart` and `android/app/google-services.json`.
3. Install dependencies and run:
   ```bash
   flutter pub get
   flutter run
   ```
4. Build release APK:
   ```bash
   flutter build apk --release
   ```
   Output: `build/app/outputs/flutter-apk/app-release.apk`

## Offline Mode

The app works fully offline via Hive. Data syncs to Firestore when Firebase is configured and the device is online.

## Architecture

Clean Architecture with Presentation → Domain → Data layers, Riverpod, Repository pattern.
