import 'package:f1_app/data/datasources/openf1_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty credentials skip token requests', () {
    final auth = OpenF1Auth(username: '', password: '');
    expect(auth.configured, isFalse);
  });

  test('configured credentials are marked ready', () {
    final auth = OpenF1Auth(username: 'user@example.com', password: 'secret');
    expect(auth.configured, isTrue);
    expect(auth.hasValidToken, isFalse);
  });
}
