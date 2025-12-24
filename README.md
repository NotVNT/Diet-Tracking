# diet_tracking_project

A new Flutter project.

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
