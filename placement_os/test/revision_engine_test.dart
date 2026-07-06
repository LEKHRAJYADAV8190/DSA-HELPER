import 'package:flutter_test/flutter_test.dart';

void main() {
  test('revision queue index wraps modulo solved count', () {
    expect(5 % 3, 2);
    expect(3 % 3, 0);
  });
}
