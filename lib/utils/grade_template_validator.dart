import '../models/grade_template.dart';

class GradeTemplateValidator {
  static List<String> validate(GradeTemplate template) {
    final errors = <String>[];

    if (template.name.trim().isEmpty) {
      errors.add('Nama template tidak boleh kosong.');
    }

    if (template.grades.isEmpty) {
      errors.add('Template harus memiliki minimal satu grade.');
      return errors;
    }

    final grades = template.grades;

    // Memeriksa nama grade yang duplikat.
    final gradeNames = <String>{};

    for (final item in grades) {
      final name = item.grade.trim().toUpperCase();

      if (name.isEmpty) {
        errors.add('Nama grade tidak boleh kosong.');
      } else if (!gradeNames.add(name)) {
        errors.add('Grade "$name" tidak boleh duplikat.');
      }

      // Memeriksa rentang nilai.
      if (item.minScore < 0 || item.maxScore > 100) {
        errors.add('Rentang nilai ${item.grade} harus berada di antara 0–100.');
      }

      if (item.minScore > item.maxScore) {
        errors.add(
          'Nilai minimum ${item.grade} tidak boleh melebihi nilai maksimum.',
        );
      }

      // Memeriksa bobot.
      if (!item.weight.isFinite || item.weight < 0) {
        errors.add(
          'Bobot ${item.grade} harus berupa angka valid dan tidak negatif.',
        );
      }

      // Memeriksa keterangan.
      if (item.description.trim().isEmpty) {
        errors.add('Keterangan untuk grade ${item.grade} tidak boleh kosong.');
      }
    }

    // Urutkan rentang dari nilai terendah.
    final sortedGrades = [...grades]
      ..sort((a, b) => a.minScore.compareTo(b.minScore));

    // Memastikan seluruh nilai 0–100 tercakup.
    if (sortedGrades.first.minScore != 0) {
      errors.add('Rentang grade harus dimulai dari nilai 0.');
    }

    if (sortedGrades.last.maxScore != 100) {
      errors.add('Rentang grade harus berakhir pada nilai 100.');
    }

    // Memeriksa celah dan tumpang tindih rentang.
    for (int i = 0; i < sortedGrades.length - 1; i++) {
      final current = sortedGrades[i];
      final next = sortedGrades[i + 1];

      if (current.maxScore >= next.minScore) {
        errors.add(
          'Rentang ${current.grade} dan ${next.grade} saling tumpang tindih.',
        );
      } else if (current.maxScore + 1 != next.minScore) {
        errors.add(
          'Terdapat celah nilai antara ${current.grade} dan ${next.grade}.',
        );
      }
    }

    return errors;
  }

  static bool isValid(GradeTemplate template) {
    return validate(template).isEmpty;
  }
}
