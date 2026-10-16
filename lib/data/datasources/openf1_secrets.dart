/// OpenF1 account compiled in with `--dart-define-from-file`.
///
/// Copy `.env.example` to `.env`, set the two keys, then launch with:
/// `flutter run --dart-define-from-file=.env`
///
/// Empty values keep the unauthenticated path. Do not hardcode credentials here.
class OpenF1Secrets {
  static const username = String.fromEnvironment(
    'OPENF1_USERNAME',
    defaultValue: '',
  );
  static const password = String.fromEnvironment(
    'OPENF1_PASSWORD',
    defaultValue: '',
  );
}
