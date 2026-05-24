// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Brand Colors ──────────────────────────────────────────────────
  static const Color primaryOrange    = Color(0xFFF97316);   // Primary Orange
  static const Color accentOrange     = Color(0xFFFB923C);   // Accent Orange

  // ── Surfaces & Backgrounds ────────────────────────────────────────────────
  static const Color appBackground    = Color(0xFFF1F1F1);   // Main App Background
  static const Color cardBackground   = Color(0xFFFFFFFF);   // White Cards
  static const Color cardBorder       = Color(0xFFE5E5E5);   // Light Gray Borders
  static const Color headerDark       = Color(0xFF1F2937);   // Dark Gray Header
  
  // ── Text Colors ───────────────────────────────────────────────────────────
  static const Color textPrimary      = Color(0xFF2B2B2B);
  static const Color textSecondary    = Color(0xFF7A7A7A);
  
  // ── Supporting Colors ─────────────────────────────────────────────────────
  static const Color error            = Color(0xFFFF3B30);   // Error Red
  static const Color success          = Color(0xFF34C759);   // Success Green
  
  // ── Admin Specific Colors ──────────────────────────────────────────────────
  static const Color adminPrimary     = Color(0xFFE8650A);
  static const Color adminPrimaryLight= Color(0xFFF28234);
  static const Color adminBackground  = Color(0xFFF5F5F5);
  static const Color adminCardBorder  = Color(0xFFEBEBEB);
  static const Color adminTextPrimary = Color(0xFF1E1E1E);
  static const Color adminTextSecondary = Color(0xFF9A9A9A);
  
  // ── Teacher Specific Colors ────────────────────────────────────────────────
  static const Color teacherPrimary     = Color(0xFFF97316);
  static const Color teacherPrimaryLight= Color(0xFFFB923C);
  static const Color teacherPrimaryPale = Color(0xFFFFF0E6);
  static const Color teacherBackground  = Color(0xFFF1F1F1);
  static const Color teacherCardBorder  = Color(0xFFE5E5E5);
  static const Color teacherTextPrimary = Color(0xFF1F2937);
  static const Color teacherTextSecondary = Color(0xFF9A9A9A);
  static const Color teacherGrayBorder  = Color(0xFFBDBDBD);
  static const Color teacherBluePale    = Color(0xFFEAF2FF);
  static const Color teacherBlueIcon    = Color(0xFF3A7BD5);
  static const Color teacherGreenPale   = Color(0xFFE8F8EE);
  static const Color teacherGreenIcon   = Color(0xFF2EA86B);
  static const Color teacherTealPale    = Color(0xFFE5F7F6);
  static const Color teacherTealIcon    = Color(0xFF1A9E94);
  
  // ── Backward Compatibility Aliases ────────────────────────────────────────
  static const Color charcoalSlate    = textPrimary;
  static const Color premiumOrange    = primaryOrange;
  static const Color pureWhite        = cardBackground;
  static const Color lightOrangeSurface = cardBackground;
  static const Color softOrangeBorder = cardBorder;
  static const Color secondarySurface = Color(0xFFF9F9F9);
  static const Color white            = Colors.white;

  // ── Dark Mode Surfaces (Nullified) ────────────────────────────────────────
  static const Color darkSurface      = appBackground;
  static const Color darkCard         = cardBackground;
  static const Color darkTextSecondary = textSecondary;
}
