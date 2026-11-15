import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/grade_template.dart';
import '../services/grade_template_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/grade_template_validator.dart';
import '../widgets/animated_item.dart';
import '../widgets/grade_band_editor.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/section_header.dart';

class GradeTemplateEditorScreen extends StatefulWidget {
  final GradeTemplate? template;

  const GradeTemplateEditorScreen({super.key, this.template});

  @override
  State<GradeTemplateEditorScreen> createState() =>
      _GradeTemplateEditorScreenState();
}

class _GradeTemplateEditorScreenState extends State<GradeTemplateEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  final GradeTemplateStorage _storage = GradeTemplateStorage();
  final TextEditingController _nameController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  late final List<GradeBandFields> _gradeFields;

  bool _isSaving = false;

  // Pemeriksaan langsung baru tampil setelah pengguna mengubah sesuatu
  // atau mencoba menyimpan (progressive disclosure).
  bool _showValidation = false;

  bool get _isEditing => widget.template != null;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.template?.name ?? '';

    final sourceGrades =
        widget.template?.grades ?? GradeTemplate.original().grades;

    _gradeFields = sourceGrades.map((grade) {
      return GradeBandFields.fromGradeBand(grade);
    }).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();

    for (final fields in _gradeFields) {
      fields.dispose();
    }

    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _onEdited() {
    setState(() => _showValidation = true);
  }

  void _addGrade() {
    final index = _gradeFields.length;

    _gradeFields.add(GradeBandFields.empty());
    _listKey.currentState?.insertItem(index, duration: AppMotion.base);

    setState(() => _showValidation = true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: AppMotion.page,
        curve: AppMotion.curve,
      );
    });
  }

  void _removeGrade(int index) {
    if (_gradeFields.length <= 1) {
      _showMessage('Minimal harus ada satu grade.');
      return;
    }

    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    final removed = _gradeFields.removeAt(index);

    _listKey.currentState?.removeItem(index, (context, animation) {
      return AnimatedItem(
        animation: animation,
        child: IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GradeBandEditorCard(
              index: index,
              fields: removed,
              onRemove: () {},
              onChanged: () {},
            ),
          ),
        ),
      );
    }, duration: AppMotion.base);

    // Controller dibuang setelah animasi keluar selesai.
    Future<void>.delayed(
      AppMotion.base + const Duration(milliseconds: 150),
      removed.dispose,
    );

    setState(() => _showValidation = true);
  }

  /// Membaca seluruh field menjadi daftar grade.
  /// Mengembalikan null jika masih ada angka yang belum valid.
  List<GradeBand>? _parseGrades() {
    final grades = <GradeBand>[];

    for (final fields in _gradeFields) {
      final band = fields.toGradeBand();

      if (band == null) return null;

      grades.add(band);
    }

    return grades;
  }

  GradeTemplate _buildTemplate(String id, List<GradeBand> grades) {
    return GradeTemplate(
      id: id,
      name: _nameController.text.trim(),
      isOriginal: false,
      grades: grades,
    );
  }

  /// Hasil pemeriksaan langsung (memakai GradeTemplateValidator yang sama
  /// dengan yang dipakai saat menyimpan). Null jika field belum lengkap.
  List<String>? _liveErrors() {
    final grades = _parseGrades();

    if (grades == null) return null;

    return GradeTemplateValidator.validate(_buildTemplate('draft', grades));
  }

  Future<void> _saveTemplate() async {
    FocusScope.of(context).unfocus();

    setState(() => _showValidation = true);

    final formValid = _formKey.currentState!.validate();
    final grades = _parseGrades();

    if (!formValid || grades == null) {
      HapticFeedback.selectionClick();
      _showMessage('Periksa kembali kolom yang ditandai.');
      return;
    }

    final newTemplate = _buildTemplate(
      widget.template?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
      grades,
    );

    final errors = GradeTemplateValidator.validate(newTemplate);

    if (errors.isNotEmpty) {
      HapticFeedback.mediumImpact();
      _showMessage(
        'Template belum valid. Lihat bagian Pemeriksaan sebelum menyimpan.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      if (_isEditing) {
        await _storage.updateTemplate(newTemplate);
      } else {
        await _storage.createTemplate(newTemplate);
      }

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      _showMessage('Gagal menyimpan template: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi';
    }

    return null;
  }

  Widget _buildValidationPanel() {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    if (!_showValidation) return const SizedBox.shrink();

    final errors = _liveErrors();

    final Color color;
    final Color background;
    final IconData icon;
    final String title;
    final List<String> lines;

    if (errors == null) {
      color = p.muted;
      background = p.elevated;
      icon = Icons.info_outline;
      title = 'Lengkapi semua kolom grade';
      lines = const [
        'Pemeriksaan rentang nilai akan muncul setelah semua kolom terisi.',
      ];
    } else if (errors.isEmpty) {
      color = p.success;
      background = p.successContainer;
      icon = Icons.check_circle_outline;
      title = 'Template valid';
      lines = const ['Rentang nilai lengkap dan siap disimpan.'];
    } else {
      color = p.danger;
      background = p.dangerContainer;
      icon = Icons.error_outline;
      title = 'Template belum valid';
      lines = errors;
    }

    return Container(
      key: ValueKey('$title-${lines.join('|')}'),
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Semantics(
        liveRegion: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(left: 28, bottom: 4),
                child: Text(
                  line,
                  style: textTheme.bodySmall?.copyWith(color: p.body),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Grade Template' : 'Buat Grade Template'),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        'Pengaturan Template',
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Atur nama template dan skala penilaian akademik '
                      'yang ingin digunakan.',
                      style: textTheme.bodyMedium?.copyWith(color: p.muted),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Nama template',
                        hintText: 'Contoh: Sistem Penilaian Kampus',
                      ),
                      validator: _validateRequired,
                      onChanged: (_) => _onEdited(),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    SectionHeader(
                      title: 'Daftar Grade',
                      subtitle:
                          'Rentang nilai harus mencakup 0 sampai 100 '
                          'tanpa celah atau tumpang tindih.',
                      trailing: Text(
                        '${_gradeFields.length} grade',
                        style: textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedList(
                      key: _listKey,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      initialItemCount: _gradeFields.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= _gradeFields.length) {
                          return const SizedBox.shrink();
                        }

                        final fields = _gradeFields[index];

                        return AnimatedItem(
                          key: fields.key,
                          animation: animation,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GradeBandEditorCard(
                              index: index,
                              fields: fields,
                              onRemove: () => _removeGrade(index),
                              onChanged: _onEdited,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addGrade,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Grade'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    AnimatedSize(
                      duration: AppMotion.base,
                      curve: AppMotion.curve,
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: AppMotion.base,
                        child: _buildValidationPanel(),
                      ),
                    ),
                    if (_showValidation) const SizedBox(height: 16),
                    PressableScale(
                      enabled: !_isSaving,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _saveTemplate,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _isSaving ? 'Menyimpan...' : 'Simpan Template',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
