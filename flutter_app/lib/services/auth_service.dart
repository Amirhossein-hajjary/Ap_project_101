import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';

class AuthService {
  static const String _isLoggedInKey = 'isLoggedIn';
  static const String _usernameKey = 'username';

  static SharedPreferences? _prefs;

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> setLoggedIn(bool value, {String? username}) async {
    final prefs = await _instance;
    await prefs.setBool(_isLoggedInKey, value);
    if (username != null) {
      await prefs.setString(_usernameKey, username);
    }
    if (!value) {
      await prefs.remove(_usernameKey);
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await _instance;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<String?> getUsername() async {
    final prefs = await _instance;
    return prefs.getString(_usernameKey);
  }

  static void showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  static bool isValidUsername(String username) {
    final emailRegex = RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegex = RegExp(r'^\+?0?9\d{9}$');
    return emailRegex.hasMatch(username) || phoneRegex.hasMatch(username);
  }

  static String? validatePassword(String password, String username) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));

    if (!hasUpper || !hasLower || !hasDigit) {
      return 'Must include uppercase, lowercase, and a number';
    }
    if (username.isNotEmpty &&
        password.toLowerCase().contains(username.toLowerCase())) {
      return 'Password cannot contain your username';
    }
    return null;
  }
}
