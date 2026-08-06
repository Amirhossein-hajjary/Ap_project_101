import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color brandPrimary = Color(0xFF6366F1);
  
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 24.0;
  static const double spacing2Xl = 32.0;
  static const double spacing3Xl = 48.0;

  static const double radiusSm = 12.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;
  static const double radiusFull = 500.0;

  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightHint = Color(0xFF64748B);

  static const Color darkBg = Color(0xFF020617);
  static const Color darkSurface = Color(0xFF0F172A);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkHint = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: brandPrimary,
      scaffoldBackgroundColor: lightBg,
      hintColor: lightHint,
      colorScheme: ColorScheme.light(
        primary: brandPrimary,
        secondary: brandPrimary,
        surface: lightSurface,
        onSurface: lightText,
        background: lightBg,
        error: Colors.redAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: lightText),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: lightText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(const TextTheme(
        headlineLarge: TextStyle(color: lightText, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: lightText, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: TextStyle(color: lightText, fontSize: 18, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: lightText, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: lightText, fontSize: 14, height: 1.5),
        labelMedium: TextStyle(color: lightHint, fontSize: 12, fontWeight: FontWeight.w600),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        elevation: 0,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: brandPrimary,
      scaffoldBackgroundColor: darkBg,
      hintColor: darkHint,
      colorScheme: ColorScheme.dark(
        primary: brandPrimary,
        secondary: brandPrimary,
        surface: darkSurface,
        onSurface: darkText,
        background: darkBg,
        error: Colors.redAccent,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: darkText),
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(const TextTheme(
        headlineLarge: TextStyle(color: darkText, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
        headlineMedium: TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.5),
        titleLarge: TextStyle(color: darkText, fontSize: 18, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: darkText, fontSize: 16, height: 1.5),
        bodyMedium: TextStyle(color: darkText, fontSize: 14, height: 1.5),
        labelMedium: TextStyle(color: darkHint, fontSize: 12, fontWeight: FontWeight.w600),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusMd)),
        elevation: 0,
      ),
    );
  }
}
