import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/local_auth_service.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  bool _biometricEnabled = false;
  bool get biometricEnabled => _biometricEnabled;

  AuthProvider() {
    _loadBiometricStatus();
  }

  Future<void> _loadBiometricStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
    notifyListeners();
  }

  Future<void> setBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometricEnabled', value);
    _biometricEnabled = value;
    notifyListeners();
  }

  Future<bool> loginWithBiometrics() async {
    if (!_biometricEnabled) return false;
    
    bool authenticated = await LocalAuthService.authenticate();
    if (authenticated) {
      await AuthService.setLoggedIn(true);
    }
    return authenticated;
  }
}
