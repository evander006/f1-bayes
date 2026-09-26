/// Copy to `openf1_secrets.dart` (gitignored) or pass:
/// `--dart-define=OPENF1_USERNAME=... --dart-define=OPENF1_PASSWORD=...`
class OpenF1Secrets {
  static const username = String.fromEnvironment('OPENF1_USERNAME', defaultValue: '');
  static const password = String.fromEnvironment('OPENF1_PASSWORD', defaultValue: '');
}
