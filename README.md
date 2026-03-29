# Diet Tracking

[![CI](https://github.com/NotVNT/Diet-Tracking/actions/workflows/ci.yml/badge.svg?branch=testing)](https://github.com/NotVNT/Diet-Tracking/actions/workflows/ci.yml)

A Flutter application for nutrition tracking, meal planning, and an integrated diet assistant chatbot.

## Overview

This repository contains two main parts:

- **Flutter app** in the root project (`lib/`, `test/`, `assets/`, ...).
- **Python backend for chatbot/barcode** in `chat_box/` (FastAPI + ML models).

## Key Features

- Nutrition and diet goal tracking.
- Chatbot-assisted meal suggestions.
- Barcode scanning for product information.
- Multi-platform support: Android, iOS, Web, and Desktop (based on current Flutter setup).

## Environment Requirements

### Flutter

- Flutter SDK (latest stable recommended).
- Dart SDK (bundled with Flutter).
- Android Studio / Xcode (for mobile builds).

### Python backend (optional, for local chat/barcode services)

- Python 3.10+.
- Packages listed in `chat_box/requirements.txt`.

## Quick Setup

### 1) Install Flutter dependencies

```powershell
flutter pub get
```

### 2) (Optional) Install Python backend dependencies

```powershell
cd chat_box
pip install -r requirements.txt
```

## Run the Flutter App

```powershell
flutter run
```

If you need to pass backend URLs at compile time:

```powershell
flutter run --dart-define=CHAT_BOT_API_URL=http://127.0.0.1:8000 --dart-define=SERVER_BARCODE_API_URL=https://your-server
```

## Run the Local Chatbot Backend

From the `chat_box/` directory:

```powershell
uvicorn nutrient_regressor:app --host 0.0.0.0 --port 8000 --reload
```

Default chatbot/barcode endpoints used by the app:

- `POST /get_product_info` (form field: `barcode`)
- `POST /scan_barcode` (multipart form field: `file`)

### URL Mapping by Runtime Environment

- Android Emulator: use `http://10.0.2.2:8000`
- iOS Simulator / host machine: usually `http://127.0.0.1:8000`

Android Emulator example:

```powershell
flutter run -d emulator --dart-define=CHAT_BOT_API_URL=http://10.0.2.2:8000
```

## CI & Quality Checks

The CI workflow is defined in `ci.yml` and runs on pull requests and configured branch pushes.

Main steps:

- `flutter pub get`
- `flutter analyze --no-fatal-infos`
- `flutter test`

Coverage (optional, non-blocking in CI):

- `dart run tool/coverage_sharded.dart`
- Outputs coverage to `coverage/lcov.info`

### Run the same checks locally

```powershell
flutter pub get
flutter analyze --no-fatal-infos
flutter test
dart run tool/coverage_sharded.dart
```

## Main Folder Structure

```text
lib/            Flutter source code
test/           Unit/widget/integration tests
assets/         Images, icons, and static assets
chat_box/       Python backend for chatbot/barcode
tool/           Utility scripts (for example, sharded coverage)
```

## Configuration Notes

- `SERVER_BARCODE_API_URL` is currently handled via `--dart-define` (remote-first approach).
- The `.env` file is reference-only. Flutter does not load `.env` automatically unless you add and initialize an env-loading package at runtime.

## Quick Troubleshooting

- Cannot reach backend from emulator: verify host mapping (`10.0.2.2` for Android Emulator).
- Flutter package issues: run `flutter clean` then `flutter pub get`.
- Python dependency issues: verify Python version and reinstall from `requirements.txt`.

## References

- [Flutter docs](https://docs.flutter.dev/)
- [FastAPI docs](https://fastapi.tiangolo.com/)
