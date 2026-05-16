import 'package:flutter/material.dart';

abstract final class Spacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

abstract final class Radii {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 20;
  static const double xl = 32;
  static const Radius circularMd = Radius.circular(md);
  static const Radius circularLg = Radius.circular(lg);
  static const BorderRadius cardMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius cardLg = BorderRadius.all(Radius.circular(lg));
}

abstract final class AppDurations {
  static const Duration fastest = Duration(milliseconds: 150);
  static const Duration fast = Duration(milliseconds: 250);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration xpCountUp = Duration(milliseconds: 800);
  static const Duration starBurst = Duration(milliseconds: 1200);
  static const Duration milestone = Duration(seconds: 4);
  static const Duration screenTransition = Duration(milliseconds: 250);
}

abstract final class AppColors {
  // Brand palette
  static const Color primary = Color(0xFF4CAF50);
  static const Color primaryDark = Color(0xFF2E7D32);
  static const Color secondary = Color(0xFFFF9800);
  static const Color accent = Color(0xFF2196F3);
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF43A047);

  // Level colors
  static const Color levelA1 = Color(0xFF4CAF50);
  static const Color levelA2 = Color(0xFF2196F3);
  static const Color levelB1 = Color(0xFFFF9800);
  static const Color levelB2 = Color(0xFF9C27B0);

  // Surface
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceVariant = Color(0xFF0F3460);
  static const Color onSurface = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFFB0B0B0);

  // Gamification
  static const Color starGold = Color(0xFFFFD700);
  static const Color starEmpty = Color(0xFF424242);
  static const Color xpColor = Color(0xFF00BCD4);
  static const Color streakFlame = Color(0xFFFF6D00);

  // Exercise feedback
  static const Color correctGreen = Color(0xFF43A047);
  static const Color correctGreenLight = Color(0xFFE8F5E9);
  static const Color incorrectRed = Color(0xFFE53935);
  static const Color incorrectRedLight = Color(0xFFFFEBEE);
}

abstract final class MinTapTarget {
  static const double size = 48.0;
}
