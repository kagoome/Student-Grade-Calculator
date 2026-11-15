import 'package:flutter/material.dart';

import 'screens/calculator_screen.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

void main() {
  runApp(const StudentGradeApp());
}

class StudentGradeApp extends StatefulWidget {
  const StudentGradeApp({super.key});

  @override
  State<StudentGradeApp> createState() => _StudentGradeAppState();
}

class _StudentGradeAppState extends State<StudentGradeApp> {
  final ThemeController _themeController = ThemeController();

  @override
  void initState() {
    super.initState();
    _themeController.load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _themeController,
      child: ListenableBuilder(
        listenable: _themeController,
        builder: (context, _) {
          return MaterialApp(
            title: 'Student Grade Calculator',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _themeController.mode,
            // Transisi tema halus (MaterialApp menganimasikan ThemeData).
            themeAnimationDuration: const Duration(milliseconds: 300),
            themeAnimationCurve: Curves.easeOutCubic,
            home: const CalculatorScreen(),
          );
        },
      ),
    );
  }
}
