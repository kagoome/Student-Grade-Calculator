import '../models/student.dart';
import '../models/grade_template.dart';
import '../models/assessment_component.dart';
import 'assessment_validator.dart';

class GradeResult {
  final double finalScore;
  final String grade;
  final bool isPassed;
  final double gradeWeight;
  final String description;

  const GradeResult({
    required this.finalScore,
    required this.grade,
    required this.isPassed,
    this.gradeWeight = 0,
    this.description = '',
  });
}

class GradeCalculator {
  /// Hint untuk ditampilkan pada UI.
  static const String decimalScoreHint =
      'Nilai desimal tidak dibulatkan secara otomatis. '
      'Penyesuaian pembulatan mengikuti kebijakan dosen masing-masing.';

  /// Kalkulasi lama untuk menjaga kompatibilitas dengan UI sebelumnya.
  static GradeResult calculate(Student student) {
    final result =
        (student.assignmentScore * 0.30) +
        (student.midScore * 0.30) +
        (student.finalExamScore * 0.40);

    final template = GradeTemplate.original();
    final gradeBand = findGrade(result, template);

    return _createResult(result, gradeBand);
  }

  /// Kalkulasi dinamis berdasarkan komponen dan bobot pengguna.
  static GradeResult calculateDynamic({
    required List<AssessmentComponent> components,
    required GradeTemplate template,
  }) {
    final errors = AssessmentValidator.validate(components);

    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join('\n'));
    }

    final weightedScore = components.fold<double>(0, (total, component) {
      return total + (component.score * component.weight / 100);
    });

    final gradeBand = findGrade(weightedScore, template);

    return _createResult(weightedScore, gradeBand);
  }

  /// Mencari grade tanpa membulatkan nilai akhir.
  static GradeBand? findGrade(double finalScore, GradeTemplate template) {
    if (!finalScore.isFinite || finalScore < 0 || finalScore > 100) {
      return null;
    }

    for (final band in template.grades) {
      final lowerBound = band.minScore.toDouble();
      final upperBound = band.maxScore.toDouble() + 1;

      final isLastRange = band.maxScore == 100;

      if (finalScore >= lowerBound &&
          (isLastRange ? finalScore <= 100 : finalScore < upperBound)) {
        return band;
      }
    }

    return null;
  }

  /// Membuat hasil kalkulasi.
  static GradeResult _createResult(double finalScore, GradeBand? gradeBand) {
    return GradeResult(
      finalScore: finalScore,
      grade: gradeBand?.grade ?? '-',
      isPassed: gradeBand != null && gradeBand.grade != 'E',
      gradeWeight: gradeBand?.weight ?? 0,
      description: gradeBand?.description ?? 'Grade tidak ditemukan',
    );
  }
}
