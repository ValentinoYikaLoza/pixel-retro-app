import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_retro_app/app/shared/functions/generate_random_string.dart';

void main() {
  group('generateRandomString', () {
    test('returns a string of the requested length', () {
      expect(generateRandomString(10).length, 10);
      expect(generateRandomString(1).length, 1);
      expect(generateRandomString(0), isEmpty);
    });

    test('only contains alphanumeric characters', () {
      final result = generateRandomString(500);
      expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(result), isTrue);
    });
  });
}
