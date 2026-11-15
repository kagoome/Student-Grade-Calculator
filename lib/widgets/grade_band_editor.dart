import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/grade_template.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/display_format.dart';

/// Controller untuk satu baris grade pada editor template.
class GradeBandFields {
  GradeBandFields({
    required this.gradeController,
    required this.minScoreController,
    required this.maxScoreController,
    required this.weightController,
    required this.descriptionController,
  });

  final TextEditingController gradeController;
  final TextEditingController minScoreController;
  final TextEditingController maxScoreController;
  final TextEditingController weightController;
  final TextEditingController descriptionController;

  /// Key unik agar item AnimatedList tetap stabil saat dihapus.
  final Key key = UniqueKey();

  factory GradeBandFields.fromGradeBand(GradeBand grade) {
    return GradeBandFields(
      gradeController: TextEditingController(text: grade.grade),
      minScoreController: TextEditingController(
        text: grade.minScore.toString(),
      ),
      maxScoreController: TextEditingController(
        text: grade.maxScore.toString(),
      ),
      weightController: TextEditingController(text: grade.weight.toString()),
      descriptionController: TextEditingController(text: grade.description),
    );
  }

  factory GradeBandFields.empty() {
    return GradeBandFields(
      gradeController: TextEditingController(),
      minScoreController: TextEditingController(),
      maxScoreController: TextEditingController(),
      weightController: TextEditingController(),
      descriptionController: TextEditingController(),
    );
  }

  /// Membaca isi field menjadi [GradeBand]; null jika ada angka tidak valid.
  GradeBand? toGradeBand() {
    final minScore = int.tryParse(minScoreController.text.trim());
    final maxScore = int.tryParse(maxScoreController.text.trim());
    final weight = double.tryParse(
      weightController.text.trim().replaceAll(',', '.'),
    );

    if (minScore == null || maxScore == null || weight == null) return null;

    return GradeBand(
      grade: gradeController.text.trim(),
      minScore: minScore,
      maxScore: maxScore,
      weight: weight,
      description: descriptionController.text.trim(),
    );
  }

  void dispose() {
    gradeController.dispose();
    minScoreController.dispose();
    maxScoreController.dispose();
    weightController.dispose();
    descriptionController.dispose();
  }
}

/// Kartu editor satu grade: Grade, rentang nilai, bobot, deskripsi.
class GradeBandEditorCard extends StatelessWidget {
  const GradeBandEditorCard({
    super.key,
    required this.index,
    required this.fields,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final GradeBandFields fields;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }

  String? _validateScore(String? value) {
    final number = int.tryParse(value ?? '');

    if (number == null) return 'Wajib diisi';
    if (number < 0 || number > 100) return 'Rentang 0–100';

    return null;
  }

  String? _validateMax(String? value) {
    final basic = _validateScore(value);
    if (basic != null) return basic;

    final max = int.parse(value!);
    final min = int.tryParse(fields.minScoreController.text.trim());

    if (min != null && max < min) return 'Maks < min';

    return null;
  }

  String? _validateWeight(String? value) {
    final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));

    if (value == null || value.trim().isEmpty) return 'Bobot wajib diisi';
    if (number == null || !number.isFinite) return 'Angka tidak valid';
    if (number < 0) return 'Tidak boleh negatif';

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    final gradeName = fields.gradeController.text.trim();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 4, 4, 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: twoDigits(index + 1),
                        style: TextStyle(
                          color: p.primary,
                          fontFeatures: AppNumberStyle.tabular,
                        ),
                      ),
                      TextSpan(
                        text: gradeName.isEmpty
                            ? '  —  Grade baru'
                            : '  —  $gradeName',
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Hapus grade',
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                color: p.danger,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: fields.gradeController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Grade',
                          hintText: 'A, B+',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateRequired,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: fields.minScoreController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nilai min',
                          hintText: '0',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateScore,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: fields.maxScoreController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nilai maks',
                          hintText: '100',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateMax,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: fields.weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Bobot',
                          hintText: '4.0',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateWeight,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: fields.descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Deskripsi',
                          hintText: 'Istimewa',
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: _validateRequired,
                        onChanged: (_) => onChanged(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
