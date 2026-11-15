import 'package:flutter/material.dart';

import '../models/grade_template.dart';
import '../services/grade_template_storage.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/grade_template_card.dart';
import '../widgets/section_header.dart';
import 'grade_template_editor_screen.dart';

class GradeTemplateScreen extends StatefulWidget {
  const GradeTemplateScreen({super.key});

  @override
  State<GradeTemplateScreen> createState() => _GradeTemplateScreenState();
}

class _GradeTemplateScreenState extends State<GradeTemplateScreen> {
  final GradeTemplateStorage _storage = GradeTemplateStorage();

  List<GradeTemplate> _templates = [];
  String _activeTemplateId = GradeTemplate.original().id;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    try {
      final templates = await _storage.getTemplates();
      final activeId = await _storage.getActiveTemplateId();

      if (!mounted) return;

      setState(() {
        _templates = templates;
        _activeTemplateId = activeId;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Gagal memuat template: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectTemplate(GradeTemplate template) async {
    try {
      await _storage.setActiveTemplate(template.id);

      if (!mounted) return;

      setState(() {
        _activeTemplateId = template.id;
      });

      _showMessage('${template.name} berhasil dipilih.');

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal memilih template: $error');
    }
  }

  Future<void> _openEditor({GradeTemplate? template}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => GradeTemplateEditorScreen(template: template),
      ),
    );

    if (result == true && mounted) {
      await _loadTemplates();
    }
  }

  Future<void> _duplicateTemplate(GradeTemplate template) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _DuplicateTemplateDialog(initialName: '${template.name} Copy');
      },
    );

    if (newName == null || newName.trim().isEmpty) return;

    try {
      await _storage.duplicateTemplate(sourceId: template.id, newName: newName);

      if (!mounted) return;

      await _loadTemplates();

      if (!mounted) return;
      _showMessage('Template berhasil diduplikasi.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal menduplikasi template: $error');
    }
  }

  Future<void> _deleteTemplate(GradeTemplate template) async {
    if (template.isOriginal) {
      _showMessage('Original Template tidak dapat dihapus.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final p = AppPalette.of(dialogContext);

        return AlertDialog(
          icon: Icon(Icons.delete_outline, color: p.danger),
          title: const Text('Hapus template?'),
          content: Text(
            'Template "${template.name}" akan dihapus secara permanen. '
            'Tindakan ini tidak dapat dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: p.danger,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
                minimumSize: const Size(88, 44),
              ),
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _storage.deleteTemplate(template.id);

      if (!mounted) return;

      await _loadTemplates();

      if (!mounted) return;
      _showMessage('Template berhasil dihapus.');
    } catch (error) {
      if (!mounted) return;
      _showMessage('Gagal menghapus template: $error');
    }
  }

  Widget _buildCard(GradeTemplate template) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GradeTemplateCard(
        template: template,
        isActive: template.id == _activeTemplateId,
        onSelect: () => _selectTemplate(template),
        onDuplicate: () => _duplicateTemplate(template),
        onEdit: template.isOriginal
            ? null
            : () => _openEditor(template: template),
        onDelete: template.isOriginal ? null : () => _deleteTemplate(template),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    final originalTemplates = _templates.where((t) => t.isOriginal).toList();
    final customTemplates = _templates.where((t) => !t.isOriginal).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Grade Templates')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: RefreshIndicator(
                    onRefresh: _loadTemplates,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.sm,
                        AppSpacing.page,
                        32,
                      ),
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            'Pengaturan Sistem Penilaian',
                            style: textTheme.headlineMedium,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pilih sistem penilaian yang akan digunakan untuk '
                          'menghitung nilai akhir mahasiswa.',
                          style: textTheme.bodyMedium?.copyWith(color: p.muted),
                        ),
                        const SizedBox(height: AppSpacing.section),
                        const SectionHeader(title: 'Template Bawaan'),
                        const SizedBox(height: 12),
                        if (originalTemplates.isEmpty)
                          const Text('Template bawaan tidak tersedia.')
                        else
                          ...originalTemplates.map(_buildCard),
                        const SizedBox(height: 16),
                        SectionHeader(
                          title: 'Template Kustom',
                          trailing: customTemplates.isEmpty
                              ? null
                              : TextButton.icon(
                                  onPressed: () => _openEditor(),
                                  icon: const Icon(Icons.add, size: 20),
                                  label: const Text('Buat baru'),
                                ),
                        ),
                        const SizedBox(height: 12),
                        if (customTemplates.isEmpty)
                          EmptyState(
                            icon: Icons.playlist_add,
                            title: 'Belum ada template kustom',
                            message:
                                'Buat skala penilaian sendiri, misalnya sesuai '
                                'aturan kampus atau mata kuliah.',
                            action: FilledButton.icon(
                              onPressed: () => _openEditor(),
                              icon: const Icon(Icons.add),
                              label: const Text('Buat Template Baru'),
                            ),
                          )
                        else
                          ...customTemplates.map(_buildCard),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

/// Dialog nama template untuk duplikasi.
/// Controller dimiliki dialog sendiri agar dibuang dengan aman.
class _DuplicateTemplateDialog extends StatefulWidget {
  const _DuplicateTemplateDialog({required this.initialName});

  final String initialName;

  @override
  State<_DuplicateTemplateDialog> createState() =>
      _DuplicateTemplateDialogState();
}

class _DuplicateTemplateDialogState extends State<_DuplicateTemplateDialog> {
  late final TextEditingController _controller;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();

    if (name.isEmpty) {
      setState(() => _error = 'Nama template tidak boleh kosong.');
      return;
    }

    Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplikasi template'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: 'Nama template baru',
          errorText: _error,
        ),
        onChanged: (_) {
          if (_error != null) setState(() => _error = null);
        },
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(96, 44)),
          onPressed: _submit,
          child: const Text('Duplikat'),
        ),
      ],
    );
  }
}
