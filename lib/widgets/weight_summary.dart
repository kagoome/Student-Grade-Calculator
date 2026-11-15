import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/display_format.dart';

/// Ringkasan total bobot komponen penilaian terhadap target 100%.
///
/// Status disampaikan lewat teks + ikon + warna (tidak hanya warna).
/// Toleransi "tepat 100%" sama dengan yang dipakai AssessmentValidator.
class WeightSummary extends StatelessWidget {
  const WeightSummary({super.key, required this.totalWeight});

  final double totalWeight;

  static const double target = 100;
  static const double tolerance = 0.000001;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    final difference = target - totalWeight;
    final isComplete = difference.abs() < tolerance;
    final isOver = !isComplete && totalWeight > target;

    final Color color;
    final Color containerColor;
    final IconData icon;
    final String status;

    if (isComplete) {
      color = p.success;
      containerColor = p.successContainer;
      icon = Icons.check_circle_outline;
      status = 'Bobot sudah lengkap.';
    } else if (isOver) {
      color = p.danger;
      containerColor = p.dangerContainer;
      icon = Icons.error_outline;
      status = 'Bobot melebihi batas ${formatDecimal(-difference)}%.';
    } else {
      color = p.warning;
      containerColor = p.warningContainer;
      icon = Icons.info_outline;
      status = 'Bobot masih kurang ${formatDecimal(difference)}%.';
    }

    final progress = (totalWeight / target).clamp(0.0, 1.0);

    return Semantics(
      container: true,
      label:
          'Total bobot ${formatDecimal(totalWeight)} persen '
          'dari target 100 persen. $status',
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          border: Border.all(color: p.border),
        ),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total bobot', style: textTheme.labelMedium),
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: AppMotion.base,
                          style: textTheme.titleLarge!.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: color,
                            height: 1.1,
                            fontFeatures: AppNumberStyle.tabular,
                          ),
                          child: Text('${formatDecimal(totalWeight)}%'),
                        ),
                      ],
                    ),
                  ),
                  Text('Target 100%', style: textTheme.bodySmall),
                ],
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      Container(
                        height: 8,
                        decoration: BoxDecoration(
                          color: p.border,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedContainer(
                        duration: AppMotion.base,
                        curve: AppMotion.curve,
                        height: 8,
                        width: constraints.maxWidth * progress,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              AnimatedContainer(
                duration: AppMotion.base,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: containerColor,
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
                child: Row(
                  children: [
                    Icon(icon, size: 18, color: color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status,
                        style: textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
