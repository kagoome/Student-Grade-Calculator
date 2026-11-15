import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

import 'package:student_grade_calculator/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('Student Grade Calculator tampil', (WidgetTester tester) async {
    await tester.pumpWidget(const StudentGradeApp());

    // Memproses proses async pemuatan template.
    await tester.pumpAndSettle();

    expect(find.text('Hitung Nilai Akademik'), findsOneWidget);
  });
}
