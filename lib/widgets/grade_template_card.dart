import 'package:flutter/material.dart';

import '../models/grade_template.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

enum GradeTemplateMenuAction { edit, duplicate, delete }

/// Kartu satu grade template.
///
/// - Template bawaan: ikon gembok, tidak dapat diubah/dihapus, hanya
///   dapat diduplikasi.
/// - Custom template: edit / duplikat / hapus lewat overflow menu.
class GradeTemplateCard extends StatelessWidget {
  const GradeTemplateCard({
    super.key,
    required this.template,
    required this.isActive,
    required this.onSelect,
    required this.onDuplicate,
    this.onEdit,
    this.onDelete,
  });

  final GradeTemplate template;
  final bool isActive;
  final VoidCallback onSelect;
  final VoidCallback onDuplicate;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final isOriginal = template.isOriginal;

    final preview = template.grades
        .take(4)
        .map((grade) => '${grade.grade} ${grade.minScore}–${grade.maxScore}')
        .join('   ·   ');
    final remaining = template.grades.length - 4;

    return AnimatedContainer(
      duration: AppMotion.base,
      curve: AppMotion.curve,
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(
          color: isActive ? p.primary : p.border,
          width: isActive ? 1.6 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isOriginal ? p.primaryContainer : p.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.input),
                    border: isOriginal ? null : Border.all(color: p.border),
                  ),
                  child: Icon(
                    isOriginal ? Icons.lock_outline : Icons.edit_note,
                    size: 22,
                    color: isOriginal ? p.primary : p.muted,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(template.name, style: textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        isOriginal
                            ? 'Template bawaan · tidak dapat diubah'
                            : 'Template kustom',
                        style: textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isActive)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 18, color: p.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Aktif',
                        style: textTheme.labelLarge?.copyWith(color: p.primary),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              remaining > 0 ? '$preview   ·   +$remaining lainnya' : preview,
              style: textTheme.bodySmall?.copyWith(
                color: p.body,
                fontFeatures: AppNumberStyle.tabular,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text(
              '${template.grades.length} tingkatan grade',
              style: textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: p.border),
          const SizedBox(height: 4),
          Row(
            children: [
              if (!isActive)
                FilledButton.icon(
                  onPressed: onSelect,
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Gunakan'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 44),
                    backgroundColor: p.primaryContainer,
                    foregroundColor: p.onPrimaryContainer,
                  ),
                ),
              const Spacer(),
              if (isOriginal)
                TextButton.icon(
                  onPressed: onDuplicate,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                  label: const Text('Duplikat'),
                )
              else
                PopupMenuButton<GradeTemplateMenuAction>(
                  tooltip: 'Opsi template',
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) {
                    switch (action) {
                      case GradeTemplateMenuAction.edit:
                        onEdit?.call();
                      case GradeTemplateMenuAction.duplicate:
                        onDuplicate();
                      case GradeTemplateMenuAction.delete:
                        onDelete?.call();
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      _menuItem(
                        context,
                        GradeTemplateMenuAction.edit,
                        Icons.edit_outlined,
                        'Edit',
                      ),
                      _menuItem(
                        context,
                        GradeTemplateMenuAction.duplicate,
                        Icons.copy_outlined,
                        'Duplikat',
                      ),
                      _menuItem(
                        context,
                        GradeTemplateMenuAction.delete,
                        Icons.delete_outline,
                        'Hapus',
                        color: p.danger,
                      ),
                    ];
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  PopupMenuItem<GradeTemplateMenuAction> _menuItem(
    BuildContext context,
    GradeTemplateMenuAction value,
    IconData icon,
    String label, {
    Color? color,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return PopupMenuItem<GradeTemplateMenuAction>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Text(label, style: textTheme.bodyMedium?.copyWith(color: color)),
        ],
      ),
    );
  }
}
