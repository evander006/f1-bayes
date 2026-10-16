# f1_app

A new Flutter project.

## OpenF1 credentials

The OpenF1 username and password are compile-time values (`OPENF1_USERNAME`, `OPENF1_PASSWORD`). They are not stored in Dart source.

1. Create a local env file from the template and fill in your OpenF1 account:

```bash
cp .env.example .env
```

2. Pass that file on every run and build. The flag is the same for Android, iOS, web, Linux, macOS, and Windows:

```bash
flutter run --dart-define-from-file=.env
flutter run -d chrome --dart-define-from-file=.env
flutter build apk --dart-define-from-file=.env
flutter build ios --dart-define-from-file=.env
flutter build web --dart-define-from-file=.env
flutter build linux --dart-define-from-file=.env
flutter build macos --dart-define-from-file=.env
flutter build windows --dart-define-from-file=.env
```

The Dart and Chrome launch configs in `.vscode/launch.json` already add `--dart-define-from-file=.env`. The same keys still work as separate flags: `--dart-define=OPENF1_USERNAME=...` and `--dart-define=OPENF1_PASSWORD=...`.

Tests do not need an account. Missing or empty values stay on the unauthenticated path:

```bash
flutter test
```

`.env` is gitignored. Do not commit it.

These values are baked into the binary. The app does not read `.env` from the device at runtime, so change the file and run or build again. A shipped web or mobile build still contains the values inside the compiled app; this setup only keeps them out of git.

If you previously copied `openf1_secrets.example.dart` to a local `openf1_secrets.dart`, move those values into `.env` and delete the local Dart copy before pulling. `lib/data/datasources/openf1_secrets.dart` is now a committed reader of the env keys and must not contain credentials.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
