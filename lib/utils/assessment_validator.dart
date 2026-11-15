import '../models/assessment_component.dart';

class AssessmentValidator {
  /// Memeriksa seluruh komponen penilaian.
  static List<String> validate(List<AssessmentComponent> components) {
    final errors = <String>[];

    if (components.isEmpty) {
      errors.add('Minimal harus ada satu komponen penilaian.');
      return errors;
    }

    final componentIds = <String>{};

    for (final component in components) {
      if (component.id.trim().isEmpty) {
        errors.add('ID komponen tidak boleh kosong.');
      } else if (!componentIds.add(component.id)) {
        errors.add('ID komponen "${component.id}" tidak boleh duplikat.');
      }

      if (component.name.trim().isEmpty) {
        errors.add('Nama komponen tidak boleh kosong.');
      }

      if (!component.score.isFinite ||
          component.score < 0 ||
          component.score > 100) {
        errors.add('Nilai ${component.name} harus berada di antara 0–100.');
      }

      if (!component.weight.isFinite ||
          component.weight <= 0 ||
          component.weight > 100) {
        errors.add(
          'Bobot ${component.name} harus lebih dari 0 dan maksimal 100%.',
        );
      }
    }

    final totalWeight = components.fold<double>(
      0,
      (total, component) => total + component.weight,
    );

    if ((totalWeight - 100).abs() > 0.000001) {
      errors.add(
        'Total bobot harus tepat 100%. '
        'Bobot saat ini: ${totalWeight.toStringAsFixed(2)}%.',
      );
    }

    return errors;
  }

  /// Memeriksa apakah seluruh komponen valid.
  static bool isValid(List<AssessmentComponent> components) {
    return validate(components).isEmpty;
  }

  /// Menghitung total bobot komponen.
  static double calculateTotalWeight(List<AssessmentComponent> components) {
    return components.fold<double>(
      0,
      (total, component) => total + component.weight,
    );
  }
}
