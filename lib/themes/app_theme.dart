import 'package:flutter/material.dart';

class AppTheme {
  // Light Mode
  static const Color lightAccent = Color(0xFF008080);
  static const Color lightBg = Color(0xFFF0F4F4);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF2C3E50);

  // Dark Mode
  static const Color darkAccent = Color(0xFF6366F1);
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkText = Colors.white;

  static const _sharedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: lightAccent,
        scaffoldBackgroundColor: lightBg,
        colorScheme: const ColorScheme.light(
          primary: lightAccent,
          secondary: lightAccent,
          surface: lightSurface,
          onSurface: lightText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: lightText),
          titleTextStyle: TextStyle(
            color: lightText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge:
              TextStyle(color: lightText, fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium:
              TextStyle(color: lightText, fontSize: 24, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: lightText, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.black54, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: lightAccent,
            foregroundColor: Colors.white,
            shape: _sharedShape,
            elevation: 0,
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: lightAccent.withAlpha(50),
          shape: const StadiumBorder(),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: _sharedShape,
        ),
      );

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: darkAccent,
        scaffoldBackgroundColor: darkBg,
        colorScheme: const ColorScheme.dark(
          primary: darkAccent,
          secondary: darkAccent,
          surface: darkSurface,
          onSurface: darkText,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: darkText),
          titleTextStyle: TextStyle(
            color: darkText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        textTheme: const TextTheme(
          headlineLarge:
              TextStyle(color: darkText, fontSize: 32, fontWeight: FontWeight.bold),
          headlineMedium:
              TextStyle(color: darkText, fontSize: 24, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: darkText, fontSize: 16),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: darkAccent,
            foregroundColor: Colors.white,
            shape: _sharedShape,
            elevation: 0,
          ),
        ),
        chipTheme: ChipThemeData(
          selectedColor: darkAccent.withAlpha(60),
          shape: const StadiumBorder(),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: _sharedShape,
        ),
      );
}
