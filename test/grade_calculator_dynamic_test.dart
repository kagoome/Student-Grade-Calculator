import 'package:flutter_test/flutter_test.dart';

import 'package:student_grade_calculator/models/assessment_component.dart';
import 'package:student_grade_calculator/models/grade_template.dart';
import 'package:student_grade_calculator/utils/grade_calculator.dart';

void main() {
  group('Dynamic Grade Calculator', () {
    final template = GradeTemplate.original();

    test('Menghitung nilai akhir berdasarkan bobot dinamis', () {
      final components = [
        const AssessmentComponent(
          id: '1',
          name: 'Tugas',
          score: 85,
          weight: 20,
        ),
        const AssessmentComponent(id: '2', name: 'Kuis', score: 90, weight: 10),
        const AssessmentComponent(
          id: '3',
          name: 'Praktikum',
          score: 80,
          weight: 20,
        ),
        const AssessmentComponent(id: '4', name: 'UTS', score: 75, weight: 25),
        const AssessmentComponent(id: '5', name: 'UAS', score: 88, weight: 25),
      ];

      final result = GradeCalculator.calculateDynamic(
        components: components,
        template: template,
      );

      expect(result.finalScore, closeTo(82.75, 0.000001));
      expect(result.grade, 'A');
      expect(result.gradeWeight, 4.0);
    });

    test('Nilai desimal tidak dibulatkan otomatis', () {
      final components = [
        const AssessmentComponent(
          id: '1',
          name: 'Tugas',
          score: 80,
          weight: 50,
        ),
        const AssessmentComponent(id: '2', name: 'UAS', score: 81, weight: 50),
      ];

      final result = GradeCalculator.calculateDynamic(
        components: components,
        template: template,
      );

      expect(result.finalScore, 80.5);
      expect(result.grade, 'B+');
    });

    test('Nilai 81 masuk grade A', () {
      final result = GradeCalculator.findGrade(81, template);

      expect(result?.grade, 'A');
    });

    test('Nilai 80.99 tetap masuk grade B+', () {
      final result = GradeCalculator.findGrade(80.99, template);

      expect(result?.grade, 'B+');
    });

    test('Nilai 100 masuk grade A', () {
      final result = GradeCalculator.findGrade(100, template);

      expect(result?.grade, 'A');
    });

    test('Bobot tidak berjumlah 100 harus ditolak', () {
      final components = [
        const AssessmentComponent(
          id: '1',
          name: 'Tugas',
          score: 80,
          weight: 30,
        ),
        const AssessmentComponent(id: '2', name: 'UAS', score: 90, weight: 50),
      ];

      expect(
        () => GradeCalculator.calculateDynamic(
          components: components,
          template: template,
        ),
        throwsArgumentError,
      );
    });
  });
}
