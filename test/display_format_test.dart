import 'package:flutter_test/flutter_test.dart';

import 'package:student_grade_calculator/utils/display_format.dart';

void main() {
  group('display_format', () {
    test('formatDecimal menghapus nol di belakang dan memakai koma', () {
      expect(formatDecimal(30), '30');
      expect(formatDecimal(82.5), '82,5');
      expect(formatDecimal(12.3456), '12,35');
      expect(formatDecimal(0), '0');
      expect(formatDecimal(100), '100');
    });

    test('formatExact tidak membulatkan nilai', () {
      expect(formatExact(82.75), '82,75');
      expect(formatExact(80.5), '80,5');
    });

    test('twoDigits menambahkan nol di depan', () {
      expect(twoDigits(1), '01');
      expect(twoDigits(12), '12');
    });
  });
}
