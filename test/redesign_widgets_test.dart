import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:student_grade_calculator/main.dart';
import 'package:student_grade_calculator/theme/app_theme.dart';
import 'package:student_grade_calculator/widgets/weight_summary.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> pumpSummary(WidgetTester tester, double total) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: WeightSummary(totalWeight: total)),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('WeightSummary', () {
    testWidgets('bobot kurang menampilkan sisa bobot', (tester) async {
      await pumpSummary(tester, 70);

      expect(find.text('Bobot masih kurang 30%.'), findsOneWidget);
      expect(find.text('70%'), findsOneWidget);
    });

    testWidgets('bobot tepat 100 dinyatakan lengkap', (tester) async {
      await pumpSummary(tester, 100);

      expect(find.text('Bobot sudah lengkap.'), findsOneWidget);
    });

    testWidgets('bobot lebih dari 100 dinyatakan melebihi batas', (
      tester,
    ) async {
      await pumpSummary(tester, 110);

      expect(find.text('Bobot melebihi batas 10%.'), findsOneWidget);
    });
  });

  group('Calculator Screen', () {
    testWidgets('tombol Tambah Komponen menambah komponen', (tester) async {
      await tester.pumpWidget(const StudentGradeApp());
      await tester.pumpAndSettle();

      expect(find.text('3 komponen'), findsOneWidget);

      final addButton = find.text('Tambah Komponen');
      await tester.ensureVisible(addButton);
      await tester.pumpAndSettle();
      await tester.tap(addButton);
      await tester.pumpAndSettle();

      expect(find.text('4 komponen'), findsOneWidget);
    });
  });
}
