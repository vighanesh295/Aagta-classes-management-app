// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Golden Palette ────────────────────────────────────────────────────────
  static const Color gold         = Color(0xFFD4A017);
  static const Color goldLight    = Color(0xFFF5C842);
  static const Color goldDark     = Color(0xFFA07810);
  static const Color goldAccent   = Color(0xFFFFD700);
  static const Color goldMuted    = Color(0xFFE8C97E);
  static const Color goldSurface  = Color(0xFFFFF8E7);
  static const Color goldBorder   = Color(0xFFEDD87A);

  // ── Neutrals ──────────────────────────────────────────────────────────────
  static const Color white        = Color(0xFFFFFFFF);
  static const Color offWhite     = Color(0xFFFAF8F3);
  static const Color cream        = Color(0xFFF5EDD6);
  static const Color lightGrey    = Color(0xFFF0EDE6);
  static const Color borderGrey   = Color(0xFFE0D8C8);
  static const Color textLight    = Color(0xFF9E9078);
  static const Color textMedium   = Color(0xFF6B5E45);
  static const Color textDark     = Color(0xFF3D2E10);
  static const Color black        = Color(0xFF1A1208);

  // ── Splash / Background ───────────────────────────────────────────────────
  static const Color splashBg     = Color(0xFF0D0A04);
  static const Color darkBg       = Color(0xFF1A1208);
  static const Color darkSurface  = Color(0xFF241C0E);
  static const Color darkCard     = Color(0xFF2E2310);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning      = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color error        = Color(0xFFC62828);
  static const Color errorLight   = Color(0xFFFFEBEE);
  static const Color info         = Color(0xFF1565C0);
  static const Color infoLight    = Color(0xFFE3F2FD);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient goldenGradient = LinearGradient(
    colors: [goldLight, gold, goldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [Color(0xFF1A1208), Color(0xFF0D0A04)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [white, goldSurface],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGoldGradient = LinearGradient(
    colors: [goldDark, gold],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
