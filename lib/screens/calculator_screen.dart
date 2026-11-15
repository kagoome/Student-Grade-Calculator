import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/assessment_component.dart';
import '../models/grade_template.dart';
import '../services/grade_template_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/assessment_validator.dart';
import '../utils/display_format.dart';
import '../utils/grade_calculator.dart';
import '../widgets/animated_item.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/result_card.dart';
import '../widgets/section_header.dart';
import '../widgets/theme_mode_button.dart';
import '../widgets/weight_summary.dart';
import 'grade_template_screen.dart';

class _AssessmentEntry {
  final String id;
  final TextEditingController nameController;
  final TextEditingController scoreController;
  final TextEditingController weightController;
  final FocusNode nameFocus = FocusNode();

  _AssessmentEntry({
    required this.id,
    required String name,
    required String score,
    required String weight,
  }) : nameController = TextEditingController(text: name),
       scoreController = TextEditingController(text: score),
       weightController = TextEditingController(text: weight);

  void dispose() {
    nameController.dispose();
    scoreController.dispose();
    weightController.dispose();
    nameFocus.dispose();
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scrollController = ScrollController();
  final _resultKey = GlobalKey();
  final GradeTemplateStorage _templateStorage = GradeTemplateStorage();

  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  final List<_AssessmentEntry> _entries = [];

  GradeTemplate _activeTemplate = GradeTemplate.original();

  bool _isTemplateLoading = true;

  String? studentName;
  GradeResult? gradeResult;

  // Komponen yang dipakai pada perhitungan terakhir. Rincian hasil
  // dibaca dari daftar yang sama dengan yang dikirim ke calculateDynamic.
  List<AssessmentComponent> _resultComponents = const [];
  int _resultSerial = 0;

  int _nextId = 1;

  @override
  void initState() {
    super.initState();

    _entries.addAll([
      _createEntry('Tugas', '30'),
      _createEntry('UTS', '30'),
      _createEntry('UAS', '40'),
    ]);

    _loadActiveTemplate();
  }

  Future<void> _loadActiveTemplate() async {
    try {
      final template = await _templateStorage.getActiveTemplate();

      if (!mounted) return;

      setState(() {
        _activeTemplate = template;
        _isTemplateLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _activeTemplate = GradeTemplate.original();
        _isTemplateLoading = false;
      });

      _showMessage('Gagal memuat template: $error');
    }
  }

  Future<void> _openGradeTemplate() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GradeTemplateScreen()),
    );

    if (!mounted) return;

    await _loadActiveTemplate();

    if (!mounted) return;

    setState(() {
      gradeResult = null;
    });
  }

  _AssessmentEntry _createEntry(String name, String weight) {
    return _AssessmentEntry(
      id: 'component_${_nextId++}',
      name: name,
      score: '',
      weight: weight,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scrollController.dispose();

    for (final entry in _entries) {
      entry.dispose();
    }

    super.dispose();
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  double? _parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }

  double get _totalWeight {
    return _entries.fold<double>(0, (total, entry) {
      return total + (_parseNumber(entry.weightController.text) ?? 0);
    });
  }

  List<AssessmentComponent> _buildComponents() {
    return _entries.map((entry) {
      return AssessmentComponent(
        id: entry.id,
        name: entry.nameController.text.trim(),
        score: _parseNumber(entry.scoreController.text) ?? 0,
        weight: _parseNumber(entry.weightController.text) ?? 0,
      );
    }).toList();
  }

  String? _validateRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bagian ini wajib diisi';
    }

    return null;
  }

  String? _validateScore(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nilai wajib diisi';
    }

    final score = _parseNumber(value);

    if (score == null || !score.isFinite) {
      return 'Masukkan angka yang valid';
    }

    if (score < 0 || score > 100) {
      return 'Nilai harus antara 0–100';
    }

    return null;
  }

  String? _validateWeight(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bobot wajib diisi';
    }

    final weight = _parseNumber(value);

    if (weight == null || !weight.isFinite) {
      return 'Masukkan angka yang valid';
    }

    if (weight <= 0 || weight > 100) {
      return 'Bobot harus lebih dari 0 dan maksimal 100';
    }

    return null;
  }

  void _invalidateResult() {
    setState(() => gradeResult = null);
  }

  // ---- Tambah / hapus komponen (AnimatedList) ---------------------------

  void _addComponent() {
    final entry = _createEntry('Komponen Baru', '');
    final index = _entries.length;

    _entries.add(entry);
    _listKey.currentState?.insertItem(index, duration: AppMotion.base);

    setState(() {
      gradeResult = null;
    });

    // Arahkan fokus ke nama komponen baru dan pilih seluruh teksnya.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      entry.nameController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: entry.nameController.text.length,
      );
      entry.nameFocus.requestFocus();
    });
  }

  void _removeComponent(int index) {
    final entry = _entries[index];
    final removedName = entry.nameController.text.trim();
    final snapshotName = entry.nameController.text;
    final snapshotScore = entry.scoreController.text;
    final snapshotWeight = entry.weightController.text;

    HapticFeedback.lightImpact();
    FocusScope.of(context).unfocus();

    _entries.removeAt(index);

    _listKey.currentState?.removeItem(index, (context, animation) {
      return AnimatedItem(
        animation: animation,
        child: IgnorePointer(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildComponentCard(entry, index),
          ),
        ),
      );
    }, duration: AppMotion.base);

    // Controller baru dibuang setelah animasi keluar selesai.
    Future<void>.delayed(
      AppMotion.base + const Duration(milliseconds: 150),
      entry.dispose,
    );

    setState(() {
      gradeResult = null;
    });

    _showMessage(
      removedName.isEmpty
          ? 'Komponen dihapus.'
          : 'Komponen "$removedName" dihapus.',
      action: SnackBarAction(
        label: 'Urungkan',
        onPressed: () {
          _restoreComponent(index, snapshotName, snapshotScore, snapshotWeight);
        },
      ),
    );
  }

  void _restoreComponent(int index, String name, String score, String weight) {
    if (!mounted) return;

    final entry = _AssessmentEntry(
      id: 'component_${_nextId++}',
      name: name,
      score: score,
      weight: weight,
    );
    final position = index.clamp(0, _entries.length);

    _entries.insert(position, entry);
    _listKey.currentState?.insertItem(position, duration: AppMotion.base);

    setState(() {
      gradeResult = null;
    });
  }

  // ---- Perhitungan -----------------------------------------------------

  void calculateGrade() {
    FocusScope.of(context).unfocus();

    if (_isTemplateLoading) {
      _showMessage('Template penilaian masih dimuat.');
      return;
    }

    if (!_formKey.currentState!.validate()) {
      HapticFeedback.selectionClick();
      return;
    }

    final components = _buildComponents();
    final errors = AssessmentValidator.validate(components);

    if (errors.isNotEmpty) {
      HapticFeedback.selectionClick();
      _showMessage(errors.first);
      return;
    }

    final result = GradeCalculator.calculateDynamic(
      components: components,
      template: _activeTemplate,
    );

    HapticFeedback.mediumImpact();

    setState(() {
      studentName = _nameController.text.trim();
      gradeResult = result;
      _resultComponents = components;
      _resultSerial++;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final resultContext = _resultKey.currentContext;
      if (resultContext == null) return;

      final reduceMotion = MediaQuery.disableAnimationsOf(context);

      Scrollable.ensureVisible(
        resultContext,
        alignment: 0.02,
        duration: reduceMotion
            ? Duration.zero
            : const Duration(milliseconds: 450),
        curve: AppMotion.curve,
      );
    });
  }

  void resetForm() {
    final oldEntries = List<_AssessmentEntry>.of(_entries);

    // Controller lama dibuang setelah list lama dilepas dari pohon widget.
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      for (final entry in oldEntries) {
        entry.dispose();
      }
    });

    setState(() {
      _entries
        ..clear()
        ..addAll([
          _createEntry('Tugas', '30'),
          _createEntry('UTS', '30'),
          _createEntry('UAS', '40'),
        ]);

      // Key baru agar AnimatedList dibangun ulang dengan data default.
      _listKey = GlobalKey<AnimatedListState>();

      _nameController.clear();
      studentName = null;
      gradeResult = null;
      _resultComponents = const [];
    });

    _formKey.currentState?.reset();

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: AppMotion.page,
        curve: AppMotion.curve,
      );
    }
  }

  // ---- UI ---------------------------------------------------------------

  Widget _buildComponentCard(_AssessmentEntry entry, int index) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final componentName = entry.nameController.text.trim();

    return Container(
      key: ValueKey(entry.id),
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
                        text: componentName.isEmpty
                            ? '  —  Tanpa nama'
                            : '  —  $componentName',
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall,
                ),
              ),
              IconButton(
                tooltip: 'Hapus komponen',
                onPressed: () => _removeComponent(index),
                icon: const Icon(Icons.delete_outline),
                color: p.danger,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                TextFormField(
                  controller: entry.nameController,
                  focusNode: entry.nameFocus,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Nama komponen',
                    hintText: 'Contoh: Tugas, Kuis, Praktikum',
                  ),
                  validator: _validateRequired,
                  onChanged: (_) => _invalidateResult(),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: entry.scoreController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Nilai',
                          hintText: '0–100',
                          suffixText: '/ 100',
                        ),
                        style: textTheme.bodyMedium?.copyWith(
                          fontFeatures: AppNumberStyle.tabular,
                        ),
                        validator: _validateScore,
                        onChanged: (_) => _invalidateResult(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: entry.weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Bobot',
                          hintText: 'Contoh: 20',
                          suffixText: '%',
                        ),
                        style: textTheme.bodyMedium?.copyWith(
                          fontFeatures: AppNumberStyle.tabular,
                        ),
                        validator: _validateWeight,
                        onChanged: (_) => _invalidateResult(),
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

  Widget _buildActiveTemplateCard() {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(AppRadius.card);

    return Material(
      color: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: p.border),
      ),
      child: InkWell(
        borderRadius: radius,
        onTap: _openGradeTemplate,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.input),
                ),
                child: Icon(Icons.grading_outlined, color: p.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Template penilaian aktif',
                      style: textTheme.labelMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isTemplateLoading
                          ? 'Memuat template...'
                          : _activeTemplate.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleSmall,
                    ),
                    if (!_isTemplateLoading) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: p.success),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Aktif · ${_activeTemplate.grades.length} '
                              'tingkatan grade · '
                              '${_activeTemplate.isOriginal ? 'Bawaan' : 'Kustom'}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                'Kelola',
                style: textTheme.labelLarge?.copyWith(color: p.primary),
              ),
              Icon(Icons.chevron_right, color: p.primary),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final totalWeight = _totalWeight;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Grade Calculator'),
        actions: const [ThemeModeButton(), SizedBox(width: 4)],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              controller: _scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.sm,
                AppSpacing.page,
                32,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Semantics(
                      header: true,
                      child: Text(
                        'Hitung Nilai Akademik',
                        style: textTheme.headlineMedium,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Atur komponen penilaian sesuai kebutuhan mata kuliah.',
                      style: textTheme.bodyMedium?.copyWith(color: p.muted),
                    ),
                    const SizedBox(height: 20),
                    _buildActiveTemplateCard(),
                    const SizedBox(height: AppSpacing.section),

                    // Student information
                    const SectionHeader(title: 'Data Mahasiswa'),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nama mahasiswa',
                        hintText: 'Masukkan nama mahasiswa',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: _validateRequired,
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Assessment components
                    SectionHeader(
                      title: 'Komponen Penilaian',
                      subtitle:
                          'Tentukan nilai dan persentase bobot tiap komponen.',
                      trailing: Text(
                        '${_entries.length} komponen',
                        style: textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedList(
                      key: _listKey,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      initialItemCount: _entries.length,
                      itemBuilder: (context, index, animation) {
                        if (index >= _entries.length) {
                          return const SizedBox.shrink();
                        }

                        return AnimatedItem(
                          animation: animation,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildComponentCard(_entries[index], index),
                          ),
                        );
                      },
                    ),
                    if (_entries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Belum ada komponen penilaian. '
                          'Tambahkan minimal satu komponen.',
                          style: textTheme.bodySmall,
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addComponent,
                        icon: const Icon(Icons.add),
                        label: const Text('Tambah Komponen'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),

                    // Weight summary
                    WeightSummary(totalWeight: totalWeight),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 16, color: p.muted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            GradeCalculator.decimalScoreHint,
                            style: textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Primary action
                    PressableScale(
                      enabled: !_isTemplateLoading,
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton.icon(
                          onPressed: _isTemplateLoading ? null : calculateGrade,
                          icon: _isTemplateLoading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.calculate_outlined),
                          label: Text(
                            _isTemplateLoading
                                ? 'Memuat template...'
                                : 'Hitung Nilai Akhir',
                          ),
                        ),
                      ),
                    ),

                    // Result
                    if (gradeResult != null) ...[
                      const SizedBox(height: AppSpacing.section),
                      KeyedSubtree(
                        key: _resultKey,
                        child: ResultCard(
                          key: ValueKey(_resultSerial),
                          studentName: studentName!,
                          result: gradeResult!,
                          components: _resultComponents,
                          onReset: resetForm,
                        ),
                      ),
                    ],
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
