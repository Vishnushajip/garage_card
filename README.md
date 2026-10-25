# WeFix — Garage Card Management Platform

Production-ready multi-tenant vehicle service and garage management platform built with Flutter and Firebase.

---

## 🚀 Build & Deployment Commands

### 1. WebAssembly (WASM) Web Release & Firebase Deployment

#### Build for Web with WebAssembly (WASM):
```bash
# Clean previous build artifacts (optional)
flutter clean
flutter pub get

# Build production Web release with WASM compilation
flutter build web --wasm --release
```

> **Note on WASM:** This generates both modern WebAssembly (`main.dart.wasm` + `main.dart.mjs`) and JavaScript fallback (`main.dart.js`) for older browsers. Firebase Hosting is configured in `firebase.json` with the required `application/wasm` headers and cross-origin isolation.

#### Deploy to Firebase Hosting:
```bash
# Deploy only the web app to Firebase Hosting
firebase deploy --only hosting

# Or deploy everything (Hosting, Firestore rules, Storage rules, Functions)
firebase deploy
```

#### Test Web Locally before deploying:
```bash
# Serve locally via dhttpd with proper headers
flutter pub global activate dhttpd
dhttpd --path build/web --headers="Cross-Origin-Opener-Policy=same-origin-allow-popups;Cross-Origin-Embedder-Policy=credentialless"

# Or use Firebase emulator
firebase emulators:start --only hosting
```

---

### 2. Android APK Build Commands

#### Build Release APK:
```bash
# Universal release APK (works on all Android device architectures)
flutter build apk --release
```
*Output artifact:* `build/app/outputs/flutter-apk/app-release.apk`

#### Build Optimized Split APKs (smaller file size per architecture):
```bash
# Generates separate APKs for armeabi-v7a, arm64-v8a, and x86_64
flutter build apk --release --split-per-abi
```
*Output artifacts:* `build/app/outputs/flutter-apk/app-*-release.apk`

#### Build Android App Bundle (for Google Play Store):
```bash
flutter build appbundle --release
```
*Output artifact:* `build/app/outputs/bundle/release/app-release.aab`

#### Build Debug APK (for quick local testing):
```bash
flutter build apk --debug
```
*Output artifact:* `build/app/outputs/flutter-apk/app-debug.apk`

---

### 3. Running Locally in Development

```bash
# Run on connected Android device / emulator
flutter run -d android

# Run on Chrome (Web)
flutter run -d chrome

# Run on Chrome with WebAssembly enabled
flutter run -d chrome --wasm
```

---

### 4. Code Quality & Verification

```bash
# Run static analysis
flutter analyze

# Run unit tests
flutter test
```

