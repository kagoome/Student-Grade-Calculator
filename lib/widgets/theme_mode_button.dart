import 'package:flutter/material.dart';

import '../theme/theme_controller.dart';

/// Tombol pengaturan tema (Ikut sistem / Terang / Gelap) pada AppBar.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  static IconData _iconFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode_outlined;
      case ThemeMode.dark:
        return Icons.dark_mode_outlined;
      case ThemeMode.system:
        return Icons.brightness_auto_outlined;
    }
  }

  static String _labelFor(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Terang';
      case ThemeMode.dark:
        return 'Gelap';
      case ThemeMode.system:
        return 'Ikut sistem';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ThemeScope.maybeOf(context);

    if (controller == null) return const SizedBox.shrink();

    final current = controller.mode;

    return PopupMenuButton<ThemeMode>(
      tooltip: 'Tema tampilan',
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Icon(_iconFor(current), key: ValueKey(current)),
      ),
      initialValue: current,
      onSelected: controller.setMode,
      itemBuilder: (context) {
        return [
          for (final mode in ThemeMode.values)
            CheckedPopupMenuItem<ThemeMode>(
              value: mode,
              checked: mode == current,
              child: Text(_labelFor(mode)),
            ),
        ];
      },
    );
  }
}
