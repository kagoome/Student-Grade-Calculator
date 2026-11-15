import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Mengelola preferensi tema (terang / gelap / ikut sistem) dan
/// menyimpannya dengan key baru yang tidak bentrok dengan data template.
class ThemeController extends ChangeNotifier {
  ThemeController({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const String _themeModeKey = 'app_theme_mode';

  final SharedPreferencesAsync _preferences;

  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    try {
      final stored = await _preferences.getString(_themeModeKey);
      final loaded = _decode(stored);

      if (loaded != _mode) {
        _mode = loaded;
        notifyListeners();
      }
    } catch (_) {
      // Jika gagal membaca, tetap gunakan ikut sistem.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (mode == _mode) return;

    _mode = mode;
    notifyListeners();

    try {
      await _preferences.setString(_themeModeKey, _encode(mode));
    } catch (_) {
      // Tema tetap berubah untuk sesi ini walau gagal disimpan.
    }
  }

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _decode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

/// Menyediakan [ThemeController] ke seluruh pohon widget.
class ThemeScope extends InheritedNotifier<ThemeController> {
  const ThemeScope({
    super.key,
    required ThemeController controller,
    required super.child,
  }) : super(notifier: controller);

  static ThemeController? maybeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ThemeScope>();
    return scope?.notifier;
  }
}
