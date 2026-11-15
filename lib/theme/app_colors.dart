import 'package:flutter/material.dart';

/// Token warna "Academic Instrument".
///
/// Seluruh warna UI harus berasal dari sini (langsung atau melalui
/// [AppPalette] yang mengikuti tema aktif), bukan hardcoded di screen.
class AppColors {
  AppColors._();

  // Light
  static const Color deepNavy = Color(0xFF172554);
  static const Color cobalt = Color(0xFF315EFB);
  static const Color softBlue = Color(0xFFE8EEFF);
  static const Color warmCanvas = Color(0xFFF5F5F0);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color mutedSlate = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFE3E3DC);

  // Semantic (light)
  static const Color success = Color(0xFF15856B);
  static const Color warning = Color(0xFFD97706);
  static const Color danger = Color(0xFFDC5353);

  // Dark
  static const Color darkBackground = Color(0xFF0B1120);
  static const Color darkSurface = Color(0xFF111C32);
  static const Color darkElevated = Color(0xFF1A2740);
  static const Color darkPrimary = Color(0xFF7C9BFF);
  static const Color darkSecondaryText = Color(0xFF9BAAC3);
  static const Color darkPrimaryText = Color(0xFFF1F5F9);
  static const Color darkBorder = Color(0xFF283650);

  // Semantic (dark) - dicerahkan agar kontras pada surface gelap.
  static const Color darkSuccess = Color(0xFF3FBF9F);
  static const Color darkWarning = Color(0xFFF2A33A);
  static const Color darkDanger = Color(0xFFF08585);
}

/// Palet turunan yang mengikuti tema aktif.
/// Akses melalui `AppPalette.of(context)`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.background,
    required this.surface,
    required this.elevated,
    required this.border,
    required this.heading,
    required this.body,
    required this.muted,
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
    required this.danger,
    required this.dangerContainer,
  });

  final Color background;
  final Color surface;
  final Color elevated;
  final Color border;
  final Color heading;
  final Color body;
  final Color muted;
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;
  final Color danger;
  final Color dangerContainer;

  static const AppPalette light = AppPalette(
    background: AppColors.warmCanvas,
    surface: AppColors.surfaceWhite,
    elevated: AppColors.surfaceWhite,
    border: AppColors.lightBorder,
    heading: AppColors.deepNavy,
    body: Color(0xFF1E293B),
    muted: AppColors.mutedSlate,
    primary: AppColors.cobalt,
    onPrimary: Colors.white,
    primaryContainer: AppColors.softBlue,
    onPrimaryContainer: AppColors.deepNavy,
    success: AppColors.success,
    successContainer: Color(0xFFE3F4EF),
    warning: Color(0xFFB45309),
    warningContainer: Color(0xFFFDF1DC),
    danger: Color(0xFFC53D3D),
    dangerContainer: Color(0xFFFBE9E9),
  );

  static const AppPalette dark = AppPalette(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    elevated: AppColors.darkElevated,
    border: AppColors.darkBorder,
    heading: AppColors.darkPrimaryText,
    body: AppColors.darkPrimaryText,
    muted: AppColors.darkSecondaryText,
    primary: AppColors.darkPrimary,
    onPrimary: Color(0xFF0B1120),
    primaryContainer: Color(0xFF1F2F55),
    onPrimaryContainer: Color(0xFFDCE5FF),
    success: AppColors.darkSuccess,
    successContainer: Color(0xFF123A33),
    warning: AppColors.darkWarning,
    warningContainer: Color(0xFF3D2C12),
    danger: AppColors.darkDanger,
    dangerContainer: Color(0xFF402024),
  );

  static AppPalette of(BuildContext context) {
    return Theme.of(context).extension<AppPalette>() ?? AppPalette.light;
  }

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;

    return AppPalette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      heading: Color.lerp(heading, other.heading, t)!,
      body: Color.lerp(body, other.body, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      primaryContainer: Color.lerp(
        primaryContainer,
        other.primaryContainer,
        t,
      )!,
      onPrimaryContainer: Color.lerp(
        onPrimaryContainer,
        other.onPrimaryContainer,
        t,
      )!,
      success: Color.lerp(success, other.success, t)!,
      successContainer: Color.lerp(
        successContainer,
        other.successContainer,
        t,
      )!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningContainer: Color.lerp(
        warningContainer,
        other.warningContainer,
        t,
      )!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
    );
  }
}
