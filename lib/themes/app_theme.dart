import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Global Radii
  static const double borderRadius = 32.0;

  // Light Mode Colors
  static const Color lightAccent = Color(0xFF008080);
  static const Color lightBg = Color(0xFFF0F4F4);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1A1C1E);

  // Dark Mode Colors - Layered Slate
  static const Color darkAccent = Color(0xFF818CF8); // Softer Indigo
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B); // Level 1
  static const Color darkSurfaceL2 = Color(0xFF334155); // Level 2
  static const Color darkText = Color(0xFFF1F5F9);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: lightAccent,
      scaffoldBackgroundColor: lightBg,
      colorScheme: ColorScheme.light(
        primary: lightAccent,
        secondary: lightAccent,
        surface: lightSurface,
        onSurface: lightText,
        background: lightBg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: lightText,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(const TextTheme(
        headlineLarge: TextStyle(color: lightText, fontSize: 32, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(color: lightText, fontSize: 24, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: lightText, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.black87, fontSize: 14),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: 0,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: darkAccent,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        primary: darkAccent,
        secondary: darkAccent,
        surface: darkSurface,
        onSurface: darkText,
        background: darkBg,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          color: darkText,
          fontSize: 22,
          fontWeight: FontWeight.w800,
        ),
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(const TextTheme(
        headlineLarge: TextStyle(color: darkText, fontSize: 32, fontWeight: FontWeight.w900),
        headlineMedium: TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.w700),
        bodyLarge: TextStyle(color: darkText, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
      )),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          elevation: 0,
        ),
      ),
    );
  }
}
