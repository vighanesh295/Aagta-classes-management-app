// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color textColor) {
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge:  GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: textColor),
      displayMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: textColor),
      displaySmall:  GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: textColor),
      headlineLarge: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: textColor),
      headlineMedium:GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: textColor),
      headlineSmall: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
      titleLarge:    GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: textColor),
      titleMedium:   GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      titleSmall:    GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: textColor),
      bodyLarge:     GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w400, color: textColor),
      bodyMedium:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: textColor),
      bodySmall:     GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w400, color: textColor),
      labelLarge:    GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: textColor),
      labelMedium:   GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
      labelSmall:    GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: textColor),
    );
  }

  // ─── Warm Light Premium Theme ─────────────────────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary:    AppColors.primaryOrange,
        onPrimary:  AppColors.cardBackground,
        secondary:  AppColors.accentOrange,
        onSecondary:AppColors.cardBackground,
        surface:    AppColors.cardBackground,
        onSurface:  AppColors.textPrimary,
        surfaceContainerHighest: AppColors.cardBackground,
        error:      AppColors.error,
        onError:    AppColors.cardBackground,
      ),
      scaffoldBackgroundColor: AppColors.appBackground,
      shadowColor: AppColors.textPrimary.withValues(alpha: 0.05),
      textTheme: _buildTextTheme(AppColors.textPrimary),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.headerDark,
        foregroundColor: AppColors.cardBackground,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.cardBackground,
        ),
        iconTheme: const IconThemeData(color: AppColors.cardBackground),
        actionsIconTheme: const IconThemeData(color: AppColors.cardBackground),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        shape: const Border(
          bottom: BorderSide(color: AppColors.headerDark, width: 1),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: AppColors.cardBackground,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryOrange,
          side: const BorderSide(color: AppColors.primaryOrange, width: 1.5),
          backgroundColor: AppColors.cardBackground,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.cardBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryOrange, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 14),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.appBackground,
        selectedColor: AppColors.primaryOrange,
        labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
        secondaryLabelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.cardBackground),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryOrange,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showSelectedLabels: true,
        showUnselectedLabels: true,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.cardBackground,
        elevation: 4,
        shape: CircleBorder(),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1.5,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.primaryOrange : AppColors.textSecondary),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primaryOrange.withValues(alpha: 0.3)
                : AppColors.cardBorder),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryOrange,
        linearTrackColor: AppColors.appBackground,
      ),
    );
  }

  // ─── Warm Premium Dark Theme (Disabled - Forcing Light Mode) ──────────────
  static ThemeData get dark {
    return light;
  }

  // ─── Admin Light Theme ────────────────────────────────────────────────────
  static ThemeData get adminLight {
    final base = ThemeData.light(useMaterial3: true);
    
    // Create Nunito text theme for body
    final nunitoTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge:  GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.adminTextPrimary),
      displayMedium: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.adminTextPrimary),
      displaySmall:  GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.adminTextPrimary),
      headlineLarge: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.adminTextPrimary),
      headlineMedium:GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.adminTextPrimary),
      headlineSmall: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.adminTextPrimary),
      titleLarge:    GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.adminTextPrimary),
      titleMedium:   GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.adminTextPrimary),
      titleSmall:    GoogleFonts.playfairDisplay(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.adminTextPrimary),
      bodyLarge:     GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.adminTextPrimary),
      bodyMedium:    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.adminTextPrimary),
      bodySmall:     GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.adminTextPrimary),
      labelLarge:    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.adminTextPrimary),
      labelMedium:   GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.adminTextPrimary),
      labelSmall:    GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.adminTextPrimary),
    );

    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary:    AppColors.adminPrimary,
        onPrimary:  AppColors.cardBackground,
        secondary:  AppColors.accentOrange,
        onSecondary:AppColors.cardBackground,
        surface:    AppColors.cardBackground,
        onSurface:  AppColors.adminTextPrimary,
        surfaceContainerHighest: AppColors.adminBackground,
        error:      AppColors.error,
        onError:    AppColors.cardBackground,
      ),
      scaffoldBackgroundColor: AppColors.adminBackground,
      shadowColor: AppColors.adminTextPrimary.withValues(alpha: 0.05),
      textTheme: nunitoTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.adminTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.adminTextPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.adminTextPrimary),
        actionsIconTheme: const IconThemeData(color: AppColors.adminTextPrimary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.adminCardBorder, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }

  // ─── Teacher Light Theme ──────────────────────────────────────────────────
  static ThemeData get teacherLight {
    final base = ThemeData.light(useMaterial3: true);
    
    // Create Nunito text theme for body
    final nunitoTheme = GoogleFonts.nunitoTextTheme().copyWith(
      displayLarge:  GoogleFonts.playfairDisplay(fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.teacherTextPrimary),
      displayMedium: GoogleFonts.playfairDisplay(fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary),
      displaySmall:  GoogleFonts.playfairDisplay(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary),
      headlineLarge: GoogleFonts.playfairDisplay(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary),
      headlineMedium:GoogleFonts.playfairDisplay(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary),
      headlineSmall: GoogleFonts.playfairDisplay(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.teacherTextPrimary),
      titleLarge:    GoogleFonts.playfairDisplay(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.teacherTextPrimary),
      titleMedium:   GoogleFonts.playfairDisplay(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teacherTextPrimary),
      titleSmall:    GoogleFonts.playfairDisplay(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.teacherTextPrimary),
      bodyLarge:     GoogleFonts.nunito(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.teacherTextPrimary),
      bodyMedium:    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.teacherTextPrimary),
      bodySmall:     GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.teacherTextPrimary),
      labelLarge:    GoogleFonts.nunito(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary),
      labelMedium:   GoogleFonts.nunito(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary),
      labelSmall:    GoogleFonts.nunito(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teacherTextPrimary),
    );

    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary:    AppColors.teacherPrimary,
        onPrimary:  AppColors.cardBackground,
        secondary:  AppColors.teacherPrimaryLight,
        onSecondary:AppColors.cardBackground,
        surface:    AppColors.cardBackground,
        onSurface:  AppColors.teacherTextPrimary,
        surfaceContainerHighest: AppColors.teacherBackground,
        error:      AppColors.error,
        onError:    AppColors.cardBackground,
      ),
      scaffoldBackgroundColor: AppColors.teacherBackground,
      shadowColor: AppColors.teacherTextPrimary.withValues(alpha: 0.05),
      textTheme: nunitoTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.cardBackground,
        foregroundColor: AppColors.teacherTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.playfairDisplay(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.teacherTextPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.teacherTextSecondary),
        actionsIconTheme: const IconThemeData(color: AppColors.teacherTextSecondary),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(13), // 13px radius for cards
          side: const BorderSide(color: AppColors.teacherCardBorder, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
