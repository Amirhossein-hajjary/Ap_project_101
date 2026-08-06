import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_auth_service.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _biometricEnabled = false;
  bool get biometricEnabled => _biometricEnabled;

  String _username = '';
  String get username => _username;

  AuthProvider() {
    _loadBiometricStatus();
    _loadUsername();
  }

  Future<void> _loadBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    notifyListeners();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    notifyListeners();
  }

  Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    _username = username;
    notifyListeners();
  }

  Future<bool> setBiometricEnabled(bool value) async {
    if (value) {
      final available = await LocalAuthService.isBiometricAvailable();
      if (!available) {
        AuthService.showToast('This device does not support biometric authentication', isError: true);
        return false;
      }
      final confirmed = await LocalAuthService.authenticate();
      if (!confirmed) {
        AuthService.showToast('Authentication failed', isError: true);
        return false;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', value);
    _biometricEnabled = value;
    notifyListeners();
    return true;
  }

  Future<bool> loginWithBiometrics() async {
    if (!_biometricEnabled) return false;
    if (_username.isEmpty) return false;

    final available = await LocalAuthService.isBiometricAvailable();
    if (!available) return false;

    bool authenticated = await LocalAuthService.authenticate();
    if (authenticated) {
      await AuthService.setLoggedIn(true, username: _username);
    }
    return authenticated;
  }

  Future<void> reloadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('username') ?? '';
    notifyListeners();
  }
}