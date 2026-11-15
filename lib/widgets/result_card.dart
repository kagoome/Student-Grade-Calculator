import 'package:flutter/material.dart';

import '../models/assessment_component.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/display_format.dart';
import '../utils/grade_calculator.dart';

/// Hasil perhitungan: nilai akhir sebagai focal point, ringkasan grade,
/// dan rincian kontribusi tiap komponen.
///
/// Kontribusi memakai rumus yang sama dengan
/// `GradeCalculator.calculateDynamic`: nilai × bobot / 100.
class ResultCard extends StatefulWidget {
  final String studentName;
  final GradeResult result;
  final List<AssessmentComponent> components;
  final VoidCallback onReset;

  const ResultCard({
    super.key,
    required this.studentName,
    required this.result,
    required this.components,
    required this.onReset,
  });

  @override
  State<ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<ResultCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scoreAnimation;
  late final Animation<double> _gradeAnimation;
  late final Animation<double> _gradeFadeAnimation;
  late final Animation<double> _detailAnimation;
  late final Animation<double> _breakdownAnimation;

  bool _started = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    Animation<double> interval(double begin, double end, Curve curve) {
      return CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve),
      );
    }

    _scoreAnimation = interval(0.0, 0.5, Curves.easeOutCubic);
    _gradeAnimation = interval(0.3, 0.6, Curves.easeOutBack);
    _gradeFadeAnimation = interval(0.3, 0.55, Curves.easeOutCubic);
    _detailAnimation = interval(0.5, 0.8, Curves.easeOutCubic);
    _breakdownAnimation = interval(0.65, 1.0, Curves.easeOutCubic);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_started) return;
    _started = true;

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1;
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Kontribusi komponen terhadap nilai akhir (rumus sama dengan kalkulator).
  double _contribution(AssessmentComponent component) {
    return component.score * component.weight / 100;
  }

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final result = widget.result;

    final gradeNotFound =
        result.grade == '-' && result.description == 'Grade tidak ditemukan';

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppRadius.card + 2),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- Focal area: status, mahasiswa, nilai akhir ----
          Container(
            width: double.infinity,
            color: p.primaryContainer,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      gradeNotFound
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                      size: 18,
                      color: gradeNotFound ? p.warning : p.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      gradeNotFound
                          ? 'Perhitungan selesai, grade tidak ditemukan'
                          : 'Perhitungan selesai',
                      style: textTheme.labelLarge?.copyWith(
                        color: gradeNotFound ? p.warning : p.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Mahasiswa',
                  style: textTheme.labelMedium?.copyWith(
                    color: p.onPrimaryContainer.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.studentName,
                  style: textTheme.titleMedium?.copyWith(
                    color: p.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: 'Nilai akhir ${formatExact(result.finalScore)}',
                  child: ExcludeSemantics(
                    child: AnimatedBuilder(
                      animation: _scoreAnimation,
                      builder: (context, _) {
                        final progress = _scoreAnimation.value;
                        final text = progress >= 1
                            ? formatExact(result.finalScore)
                            : (result.finalScore * progress)
                                  .toStringAsFixed(2)
                                  .replaceAll('.', ',');

                        return Text(text, style: textTheme.displayMedium);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nilai Akhir · skala 0–100',
                  style: textTheme.labelMedium?.copyWith(
                    color: p.onPrimaryContainer.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),

          // ---- Grade summary ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: FadeTransition(
              opacity: _gradeFadeAnimation,
              child: ScaleTransition(
                scale: _gradeAnimation.drive(
                  Tween<double>(begin: 0.92, end: 1),
                ),
                alignment: Alignment.centerLeft,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _Metric(label: 'Grade', value: result.grade),
                      ),
                      VerticalDivider(color: p.border, width: 24),
                      Expanded(
                        child: _Metric(
                          label: 'Bobot Grade',
                          value: formatExact(result.gradeWeight),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: _Reveal(
              animation: _detailAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Keterangan', style: textTheme.labelMedium),
                  const SizedBox(height: 2),
                  Text(
                    result.description,
                    style: textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: p.heading,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- Assessment breakdown ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _Reveal(
              animation: _breakdownAnimation,
              child: _buildBreakdown(context),
            ),
          ),

          // ---- Actions ----
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: p.border),
                const SizedBox(height: 12),
                Text(
                  'Hasil ini merupakan perhitungan matematis '
                  'berdasarkan komponen dan template grade yang dipilih.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: widget.onReset,
                    icon: const Icon(Icons.refresh, size: 20),
                    label: const Text('Hitung Ulang'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdown(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;
    final numberStyle = textTheme.bodyMedium?.copyWith(
      fontFeatures: AppNumberStyle.tabular,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text('Rincian Komponen', style: textTheme.titleSmall),
            ),
            Text(
              '${widget.components.length} komponen',
              style: textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text('Kontribusi = nilai × bobot / 100', style: textTheme.bodySmall),
        const SizedBox(height: 14),
        for (int i = 0; i < widget.components.length; i++) ...[
          _buildBreakdownRow(
            context,
            index: i,
            component: widget.components[i],
            numberStyle: numberStyle,
          ),
          if (i != widget.components.length - 1) const SizedBox(height: 16),
        ],
        const SizedBox(height: 14),
        Divider(color: p.border),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Total = nilai akhir',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              formatDecimal(widget.result.finalScore),
              style: numberStyle?.copyWith(
                fontWeight: FontWeight.w700,
                color: p.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context, {
    required int index,
    required AssessmentComponent component,
    required TextStyle? numberStyle,
  }) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    final contribution = _contribution(component);
    final maxContribution = component.weight;
    final ratio = maxContribution <= 0
        ? 0.0
        : (contribution / maxContribution).clamp(0.0, 1.0);

    return Semantics(
      container: true,
      label:
          '${component.name}: nilai ${formatDecimal(component.score)}, '
          'bobot ${formatDecimal(component.weight)} persen, '
          'kontribusi ${formatDecimal(contribution)}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  twoDigits(index + 1),
                  style: textTheme.labelMedium?.copyWith(
                    color: p.primary,
                    fontWeight: FontWeight.w600,
                    fontFeatures: AppNumberStyle.tabular,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    component.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: p.heading,
                    ),
                  ),
                ),
                Text(
                  '+${formatDecimal(contribution)}',
                  style: numberStyle?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: p.heading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _breakdownAnimation,
              builder: (context, _) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: p.border,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        Container(
                          height: 6,
                          width:
                              constraints.maxWidth *
                              ratio *
                              _breakdownAnimation.value,
                          decoration: BoxDecoration(
                            color: p.primary,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 6),
            Text(
              'Nilai ${formatDecimal(component.score)} × '
              'bobot ${formatDecimal(component.weight)}%'
              '  ·  maks. ${formatDecimal(maxContribution)}',
              style: textTheme.bodySmall?.copyWith(
                fontFeatures: AppNumberStyle.tabular,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = AppPalette.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: p.heading,
            height: 1.1,
            fontFeatures: AppNumberStyle.tabular,
          ),
        ),
      ],
    );
  }
}

/// Fade + slide tipis untuk informasi yang muncul bertahap.
class _Reveal extends StatelessWidget {
  const _Reveal({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero),
        ),
        child: child,
      ),
    );
  }
}
