import 'package:flutter/material.dart';

/// Spacing (kelipatan 4), radius, dan durasi motion.
class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double page = 20;
  static const double section = 28;
}

class AppRadius {
  AppRadius._();

  static const double input = 10;
  static const double button = 12;
  static const double card = 16;
  static const double chip = 8;
}

class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration base = Duration(milliseconds: 250);
  static const Duration page = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 700);

  static const Curve curve = Curves.easeOutCubic;
}

/// Gaya angka akademik dengan tabular figures.
class AppNumberStyle {
  AppNumberStyle._();

  static const List<FontFeature> tabular = [FontFeature.tabularFigures()];
}
