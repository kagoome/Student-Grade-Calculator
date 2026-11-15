import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_tokens.dart';

/// Font utama: IBM Plex Sans.
///
/// Jika berkas font belum disertakan pada `pubspec.yaml`, Flutter otomatis
/// memakai fallback di bawah, sehingga aplikasi tetap berjalan normal.
const String kFontFamily = 'IBMPlexSans';
const List<String> kFontFallback = ['Roboto', 'Noto Sans', 'sans-serif'];

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(Brightness.light, AppPalette.light);
  static ThemeData get dark => _build(Brightness.dark, AppPalette.dark);

  // ---- Shared text theme ------------------------------------------------
  static TextTheme _textTheme(AppPalette p) {
    TextStyle base(
      double size,
      FontWeight weight,
      Color color, {
      double? height,
      double? letterSpacing,
    }) {
      return TextStyle(
        fontFamily: kFontFamily,
        fontFamilyFallback: kFontFallback,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    }

    return TextTheme(
      // Main Heading
      headlineMedium: base(26, FontWeight.w600, p.heading, height: 1.2),
      // Section Heading
      titleLarge: base(19, FontWeight.w600, p.heading, height: 1.25),
      // Card Heading
      titleMedium: base(16, FontWeight.w600, p.heading, height: 1.3),
      titleSmall: base(15, FontWeight.w600, p.heading, height: 1.3),
      // Body
      bodyMedium: base(14, FontWeight.w400, p.body, height: 1.5),
      bodyLarge: base(15, FontWeight.w400, p.body, height: 1.5),
      // Supporting text
      bodySmall: base(12.5, FontWeight.w400, p.muted, height: 1.45),
      // Input label / overline
      labelMedium: base(12, FontWeight.w500, p.muted, letterSpacing: 0.2),
      labelLarge: base(14, FontWeight.w600, p.body),
      labelSmall: base(11, FontWeight.w500, p.muted, letterSpacing: 0.4),
      // Main score
      displayMedium: base(
        46,
        FontWeight.w700,
        p.primary,
        height: 1.0,
      ).copyWith(fontFeatures: AppNumberStyle.tabular),
    );
  }

  // ---- Shared component theme ------------------------------------------
  static ThemeData _build(Brightness brightness, AppPalette p) {
    final isDark = brightness == Brightness.dark;
    final textTheme = _textTheme(p);

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: p.primaryContainer,
      onPrimaryContainer: p.onPrimaryContainer,
      secondary: p.muted,
      onSecondary: p.surface,
      secondaryContainer: p.primaryContainer,
      onSecondaryContainer: p.onPrimaryContainer,
      error: p.danger,
      onError: isDark ? AppColors.darkBackground : Colors.white,
      errorContainer: p.dangerContainer,
      onErrorContainer: p.danger,
      surface: p.surface,
      onSurface: p.body,
      onSurfaceVariant: p.muted,
      outline: p.border,
      outlineVariant: p.border,
      surfaceContainerLowest: p.background,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.elevated,
      surfaceContainerHighest: p.elevated,
      shadow: Colors.black,
      scrim: Colors.black,
    );

    OutlineInputBorder inputBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.button),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: p.background,
      canvasColor: p.background,
      fontFamily: kFontFamily,
      fontFamilyFallback: kFontFallback,
      textTheme: textTheme,
      extensions: [p],
      splashFactory: InkRipple.splashFactory,
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        foregroundColor: p.heading,
        iconTheme: IconThemeData(color: p.heading, size: 22),
        titleTextStyle: textTheme.titleMedium,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: p.border),
        ),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: p.surface,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(fontSize: 13),
        floatingLabelStyle: textTheme.labelMedium?.copyWith(
          color: p.primary,
          fontSize: 13,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: p.muted.withValues(alpha: 0.7),
        ),
        helperStyle: textTheme.bodySmall,
        errorStyle: textTheme.bodySmall?.copyWith(color: p.danger),
        errorMaxLines: 3,
        prefixIconColor: p.muted,
        suffixStyle: textTheme.bodySmall,
        border: inputBorder(p.border),
        enabledBorder: inputBorder(p.border),
        focusedBorder: inputBorder(p.primary, width: 1.8),
        errorBorder: inputBorder(p.danger),
        focusedErrorBorder: inputBorder(p.danger, width: 1.8),
        disabledBorder: inputBorder(p.border.withValues(alpha: 0.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 50),
          shape: buttonShape,
          backgroundColor: p.primary,
          foregroundColor: p.onPrimary,
          disabledBackgroundColor: p.border,
          disabledForegroundColor: p.muted,
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(64, 48),
          shape: buttonShape,
          foregroundColor: p.primary,
          side: BorderSide(color: p.border),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 44),
          shape: buttonShape,
          foregroundColor: p.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(48, 48),
          foregroundColor: p.muted,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.elevated,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card + 2),
          side: BorderSide(color: p.border),
        ),
        titleTextStyle: textTheme.titleMedium?.copyWith(fontSize: 18),
        contentTextStyle: textTheme.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.elevated,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.elevated,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
          side: BorderSide(color: p.border),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? p.elevated : AppColors.deepNavy,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? p.body : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.border,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FadeSlideTransitionsBuilder(),
          TargetPlatform.iOS: _FadeSlideTransitionsBuilder(),
        },
      ),
    );
  }
}

/// Transisi halaman: fade + sedikit slide (±300 ms).
class _FadeSlideTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeSlideTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: AppMotion.curve,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}
