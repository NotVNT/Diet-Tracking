# add your vlan ipv4 
https://ivank04-barcode-server.hf.space
# diet_tracking_project

[![CI](https://github.com/NotVNT/Diet-Tracking/actions/workflows/ci.yml/badge.svg?branch=testing)](https://github.com/NotVNT/Diet-Tracking/actions/workflows/ci.yml)

A new Flutter project.

## CI (GitHub Actions)

This repo has a CI workflow in `.github/workflows/ci.yml`.

It runs on every **pull request** and on **push** to `main` and `testing`, and performs:

- `flutter pub get`
- `flutter analyze --no-fatal-infos`
- `flutter test`

Optionally (non-blocking):

- Collects coverage using `dart run tool/coverage_sharded.dart`
- Uploads `coverage/lcov.info` to Codecov if `CODECOV_TOKEN` is configured in repo secrets

### Run the same checks locally

```powershell
flutter pub get
flutter analyze --no-fatal-infos
flutter test

# optional coverage
dart run tool/coverage_sharded.dart
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Local chat backend

The diet assistant chat requires a running FastAPI backend (see `chat_box/`) and uses
`CHAT_BOT_API_URL` (via `ApiClientConfig`) to resolve the HTTP host/port. Define this
with `--dart-define` whenever your emulator or device needs a different address from
the default `http://127.0.0.1:8000`.

- Start the backend exposing a reachable interface, for example:
	`uvicorn nutrient_regressor:app --host 0.0.0.0 --port 8000 --reload`.
	Binding to `0.0.0.0` allows emulators and other hosts to reach the service.
- For the Android emulator, access the host machine through `http://10.0.2.2:8000`:
	`flutter run -d emulator --dart-define=CHAT_BOT_API_URL=http://10.0.2.2:8000`.
- For iOS simulators or debugging on the host, the default base URL already points
	to `127.0.0.1:8000`, so no extra define is necessary unless you bind the server
	to a different IP.

## Barcode backend (local hoặc remote)

Tính năng barcode gọi Python FastAPI backend (tham khảo `chat_box/barcode.py`) qua 2 endpoint:

- `POST /get_product_info` (form field: `barcode`)
- `POST /scan_barcode` (multipart form field: `file`)

### Cấu hình URL server barcode

Barcode backend hiện được cấu hình **remote-first**.

Trong Flutter, URL server barcode được lấy từ compile-time define `SERVER_BARCODE_API_URL`.

- Nếu **không** truyền define, app sẽ dùng default remote server.
- Nếu bạn deploy server khác, hãy truyền define này khi chạy/build.

Ví dụ:

- Chạy app và trỏ tới server remote:
	`flutter run --dart-define=SERVER_BARCODE_API_URL=https://your-server`

Ghi chú:

- Repo có file `.env` chứa `SERVER_BARCODE_API_URL=...` để bạn lưu URL, nhưng Flutter **không tự đọc `.env`** nếu bạn chưa thêm package kiểu `flutter_dotenv` và gọi load trong `main()`.
	Hiện tại app đang dùng `--dart-define` để đảm bảo hoạt động trên mọi platform (mobile/web).
