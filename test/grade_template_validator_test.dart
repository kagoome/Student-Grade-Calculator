import 'package:flutter_test/flutter_test.dart';

import 'package:student_grade_calculator/models/grade_template.dart';
import 'package:student_grade_calculator/utils/grade_template_validator.dart';
import 'package:student_grade_calculator/utils/grade_calculator.dart';

void main() {
  group('Grade Template Validator', () {
    test('Original Template harus valid', () {
      final template = GradeTemplate.original();

      expect(GradeTemplateValidator.isValid(template), isTrue);
    });

    test('Menolak rentang yang tumpang tindih', () {
      final template = GradeTemplate(
        id: 'custom_1',
        name: 'Template Test',
        isOriginal: false,
        grades: const [
          GradeBand(
            grade: 'A',
            minScore: 81,
            maxScore: 100,
            weight: 4,
            description: 'Istimewa',
          ),
          GradeBand(
            grade: 'B',
            minScore: 70,
            maxScore: 85,
            weight: 3,
            description: 'Baik',
          ),
          GradeBand(
            grade: 'C',
            minScore: 0,
            maxScore: 69,
            weight: 2,
            description: 'Cukup',
          ),
        ],
      );

      expect(GradeTemplateValidator.isValid(template), isFalse);
    });

    test('Menolak rentang yang memiliki celah', () {
      final template = GradeTemplate(
        id: 'custom_2',
        name: 'Template Test',
        isOriginal: false,
        grades: const [
          GradeBand(
            grade: 'A',
            minScore: 81,
            maxScore: 100,
            weight: 4,
            description: 'Istimewa',
          ),
          GradeBand(
            grade: 'B',
            minScore: 70,
            maxScore: 79,
            weight: 3,
            description: 'Baik',
          ),
          GradeBand(
            grade: 'C',
            minScore: 0,
            maxScore: 69,
            weight: 2,
            description: 'Cukup',
          ),
        ],
      );

      expect(GradeTemplateValidator.isValid(template), isFalse);
    });
  });

  group('Grade Calculator', () {
    test('82.5 menghasilkan grade A pada Original Template', () {
      final template = GradeTemplate.original();

      final result = GradeCalculator.findGrade(82.5, template);

      expect(result?.grade, 'A');
      expect(result?.weight, 4.0);
    });

    test('75 menghasilkan grade B', () {
      final template = GradeTemplate.original();

      final result = GradeCalculator.findGrade(75, template);

      expect(result?.grade, 'B');
      expect(result?.weight, 3.0);
    });
  });
}
