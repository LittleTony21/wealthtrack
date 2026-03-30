import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF05C293);
  static const Color backgroundDark = Color(0xFF0F1117);
  static const Color cardDark = Color(0xFF1E2026);
  static const Color surfaceDark = Color(0xFF1E2028);
  static const Color surfaceHighlight = Color(0xFF2A2D35);
  static const Color danger = Color(0xFFFF5C5C);
  static const Color greyText = Color(0xFF8A8F9E);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color welcomeBg = Color(0xFF091a12);
}

class AppTheme {
  static TextTheme _boldTextTheme(TextTheme base) {
    FontWeight _bump(FontWeight? w) {
      if (w == null || w == FontWeight.w400 || w == FontWeight.w500) return FontWeight.w600;
      if (w == FontWeight.w600) return FontWeight.w700;
      return w;
    }
    TextStyle _b(TextStyle? s) => (s ?? const TextStyle()).copyWith(fontWeight: _bump(s?.fontWeight));
    return base.copyWith(
      displayLarge: _b(base.displayLarge),
      displayMedium: _b(base.displayMedium),
      displaySmall: _b(base.displaySmall),
      headlineLarge: _b(base.headlineLarge),
      headlineMedium: _b(base.headlineMedium),
      headlineSmall: _b(base.headlineSmall),
      titleLarge: _b(base.titleLarge),
      titleMedium: _b(base.titleMedium),
      titleSmall: _b(base.titleSmall),
      bodyLarge: _b(base.bodyLarge),
      bodyMedium: _b(base.bodyMedium),
      bodySmall: _b(base.bodySmall),
      labelLarge: _b(base.labelLarge),
      labelMedium: _b(base.labelMedium),
      labelSmall: _b(base.labelSmall),
    );
  }

  static ThemeData darkTheme({Color accent = const Color(0xFF05C293)}) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        surface: AppColors.cardDark,
        onSurface: Colors.white,
        error: AppColors.danger,
      ),
      textTheme: _boldTextTheme(GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme)),
      cardColor: AppColors.cardDark,
      dividerColor: AppColors.surfaceHighlight,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.surfaceHighlight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.surfaceHighlight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        labelStyle: TextStyle(color: AppColors.greyText, fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: AppColors.greyText, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  static ThemeData lightTheme({Color accent = const Color(0xFF05C293)}) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: accent,
      colorScheme: ColorScheme.light(
        primary: accent,
        surface: Colors.white,
        onSurface: const Color(0xFF0F1117),
        error: AppColors.danger,
      ),
      textTheme: _boldTextTheme(GoogleFonts.manropeTextTheme(ThemeData.light().textTheme)),
      cardColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F1117)),
        titleTextStyle: GoogleFonts.manrope(
          color: const Color(0xFF0F1117),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  static ThemeData neonTheme({Color accent = const Color(0xFF00FFB3)}) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF08070F),
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        surface: const Color(0xFF100F1A),
        onSurface: Colors.white,
        error: AppColors.danger,
        secondary: const Color(0xFF9B59B6),
      ),
      textTheme: _boldTextTheme(GoogleFonts.ibmPlexSansTextTheme(ThemeData.dark().textTheme)),
      cardColor: const Color(0xFF100F1A),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF08070F),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: accent),
        titleTextStyle: GoogleFonts.ibmPlexSans(
          color: accent,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF100F1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accent, width: 1.5),
        ),
        labelStyle: TextStyle(color: accent.withValues(alpha: 0.7), fontWeight: FontWeight.w600),
        hintStyle: TextStyle(color: AppColors.greyText, fontWeight: FontWeight.w600),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: const Color(0xFF08070F),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.ibmPlexSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
