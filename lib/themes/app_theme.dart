import 'package:flutter/material.dart';

class AppTheme {
  static const Color blackColor = Color(0xFF1A1A1A);
  static const Color blackLight = Color(0xFF2D2D2D);
  static const Color blackDark = Color(0xFF0D0D0D);
  static const Color goldColor = Color(0xFFFFD700);
  static const Color goldLight = Color(0xFFFFF176);
  static const Color goldDark = Color(0xFFF9A825);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFFB0B0B0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: goldColor,
      hintColor: goldColor,
      scaffoldBackgroundColor: backgroundColor,

      appBarTheme: const AppBarTheme(
        backgroundColor: blackColor,
        foregroundColor: goldColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: goldColor,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          foregroundColor: blackDark,
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          elevation: 3,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: blackLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: goldColor, width: 2.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: const TextStyle(color: goldColor),
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIconColor: goldColor,
        suffixIconColor: goldColor,
      ),

      cardTheme: CardThemeData(
        color: blackLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: goldColor.withOpacity(0.2),
      ),

      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: goldColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: goldLight,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: white,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: grey,
          fontSize: 14,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: goldColor,
        ),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.all(goldColor),
        checkColor: WidgetStateProperty.all(blackDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}