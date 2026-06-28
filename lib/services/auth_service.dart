import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';

  // Save login state
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  // Check login state
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  // Toast Helper
  static void showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  // Validation Logic
  static bool isValidUsername(String username) {
    // Mobile or Email Regex
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^\+?0?9\d{9}$'); // Sample for mobile number
    return emailRegex.hasMatch(username) || phoneRegex.hasMatch(username);
  }

  static String? validatePassword(String password, String username) {
    if (password.length < 8) return 'Password must be at least 8 characters';
    
    // Uppercase, lowercase, numbers
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));

    if (!hasUpper || !hasLower || !hasDigit) {
      return 'Password must include uppercase, lowercase, and numbers';
    }

    if (username.isNotEmpty && password.toLowerCase().contains(username.toLowerCase())) {
      return 'Password cannot contain the username';
    }

    return null;
  }
}
