import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'gallery_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AuthService.showToast('Please correct the errors', isError: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));
      await AuthService.setLoggedIn(true, username: _usernameController.text.trim());
      AuthService.showToast('Account created successfully');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GalleryPage()),
        );
      }
    } catch (e) {
      AuthService.showToast('Registration failed. Try again.', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [const Color(0xFFE0E7FF), const Color(0xFFF3F4F6)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Icon(Icons.auto_awesome, size: 60, color: theme.primaryColor),
                    const SizedBox(height: 16),
                    Text('Create Account', style: theme.textTheme.headlineLarge),
                    const SizedBox(height: 8),
                    Text('Email or phone to get started',
                        style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 40),
                    GlassContainer(
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _usernameController,
                            label: 'Email or Mobile',
                            hint: 'name@mail.com or 09...',
                            icon: Icons.person_outline,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'This field is required';
                              }
                              if (!AuthService.isValidUsername(v.trim())) {
                                return 'Enter a valid email or mobile number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline,
                            obscureText: !_isPasswordVisible,
                            textInputAction: TextInputAction.next,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            validator: (v) => AuthService.validatePassword(
                                v ?? '', _usernameController.text.trim()),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: '••••••••',
                            icon: Icons.shield_outlined,
                            obscureText: !_isConfirmVisible,
                            textInputAction: TextInputAction.done,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _isConfirmVisible = !_isConfirmVisible),
                            ),
                            validator: (v) => v != _passwordController.text
                                ? 'Passwords do not match'
                                : null,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _register,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Text('Sign Up',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?',
                            style: theme.textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
