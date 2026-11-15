import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/grade_template.dart';
import '../utils/grade_template_validator.dart';

class GradeTemplateStorage {
  GradeTemplateStorage({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  static const String _templatesKey = 'grade_templates';
  static const String _activeTemplateKey = 'active_grade_template';

  /// Mengambil Original Template dan seluruh Custom Template.
  Future<List<GradeTemplate>> getTemplates() async {
    final original = GradeTemplate.original();

    final storedData = await _preferences.getString(_templatesKey);

    if (storedData == null || storedData.isEmpty) {
      return [original];
    }

    try {
      final decoded = jsonDecode(storedData);

      if (decoded is! List) {
        return [original];
      }

      final customTemplates = decoded
          .map((item) {
            return GradeTemplate.fromMap(
              Map<String, dynamic>.from(item as Map),
            );
          })
          .where((template) {
            return !template.isOriginal && template.id != original.id;
          })
          .toList();

      return [original, ...customTemplates];
    } catch (_) {
      // Jika data penyimpanan rusak, Original Template
      // tetap tersedia sebagai pilihan default.
      return [original];
    }
  }

  /// Menyimpan seluruh Custom Template.
  Future<void> _saveCustomTemplates(List<GradeTemplate> templates) async {
    final customTemplates = templates.where((template) {
      return !template.isOriginal && template.id != GradeTemplate.original().id;
    }).toList();

    final encoded = jsonEncode(
      customTemplates.map((template) {
        return template.toMap();
      }).toList(),
    );

    await _preferences.setString(_templatesKey, encoded);
  }

  /// Memastikan template valid dan bukan Original Template.
  void _validateCustomTemplate(GradeTemplate template) {
    if (template.isOriginal || template.id == GradeTemplate.original().id) {
      throw ArgumentError('Original Template tidak dapat dimodifikasi.');
    }

    final errors = GradeTemplateValidator.validate(template);

    if (errors.isNotEmpty) {
      throw ArgumentError(errors.join('\n'));
    }
  }

  /// Membuat Custom Template baru.
  Future<void> createTemplate(GradeTemplate template) async {
    _validateCustomTemplate(template);

    final templates = await getTemplates();

    final exists = templates.any((item) => item.id == template.id);

    if (exists) {
      throw ArgumentError('ID template sudah digunakan.');
    }

    templates.add(template);

    await _saveCustomTemplates(templates);
  }

  /// Memperbarui Custom Template.
  Future<void> updateTemplate(GradeTemplate template) async {
    _validateCustomTemplate(template);

    final templates = await getTemplates();

    final index = templates.indexWhere((item) => item.id == template.id);

    if (index <= 0) {
      throw ArgumentError('Custom Template tidak ditemukan.');
    }

    templates[index] = template;

    await _saveCustomTemplates(templates);
  }

  /// Menggandakan template yang sudah ada.
  Future<GradeTemplate> duplicateTemplate({
    required String sourceId,
    required String newName,
  }) async {
    if (newName.trim().isEmpty) {
      throw ArgumentError('Nama template tidak boleh kosong.');
    }

    final templates = await getTemplates();

    final source = templates.firstWhere(
      (item) => item.id == sourceId,
      orElse: () => throw ArgumentError('Template sumber tidak ditemukan.'),
    );

    final duplicated = GradeTemplate(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: newName.trim(),
      isOriginal: false,
      grades: source.grades.map((grade) {
        return GradeBand(
          grade: grade.grade,
          minScore: grade.minScore,
          maxScore: grade.maxScore,
          weight: grade.weight,
          description: grade.description,
        );
      }).toList(),
    );

    await createTemplate(duplicated);

    return duplicated;
  }

  /// Menghapus Custom Template.
  Future<void> deleteTemplate(String templateId) async {
    if (templateId == GradeTemplate.original().id) {
      throw ArgumentError('Original Template tidak dapat dihapus.');
    }

    final templates = await getTemplates();

    final index = templates.indexWhere((item) => item.id == templateId);

    if (index == -1) {
      throw ArgumentError('Template tidak ditemukan.');
    }

    templates.removeAt(index);

    await _saveCustomTemplates(templates);

    final activeId = await getActiveTemplateId();

    if (activeId == templateId) {
      await setActiveTemplate(GradeTemplate.original().id);
    }
  }

  /// Mengambil ID template yang sedang aktif.
  Future<String> getActiveTemplateId() async {
    return await _preferences.getString(_activeTemplateKey) ??
        GradeTemplate.original().id;
  }

  /// Mengatur template aktif.
  Future<void> setActiveTemplate(String templateId) async {
    final templates = await getTemplates();

    final exists = templates.any((template) => template.id == templateId);

    if (!exists) {
      throw ArgumentError('Template yang dipilih tidak ditemukan.');
    }

    await _preferences.setString(_activeTemplateKey, templateId);
  }

  /// Mengambil objek template yang sedang aktif.
  Future<GradeTemplate> getActiveTemplate() async {
    final templates = await getTemplates();
    final activeId = await getActiveTemplateId();

    return templates.firstWhere(
      (template) => template.id == activeId,
      orElse: () => GradeTemplate.original(),
    );
  }
}
