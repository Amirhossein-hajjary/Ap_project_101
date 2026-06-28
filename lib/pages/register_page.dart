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

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      // Mocking server registration
      AuthService.showToast('Account created successfully');
      await AuthService.setLoggedIn(true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GalleryPage()),
        );
      }
    } else {
      AuthService.showToast('Please correct the errors', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: theme.brightness == Brightness.dark 
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
                    Text('Email or Phone to start', style: theme.textTheme.bodyMedium),
                    const SizedBox(height: 40),
                    
                    GlassContainer(
                      child: Column(
                        children: [
                          CustomTextField(
                            controller: _usernameController,
                            label: 'Email or Mobile',
                            hint: 'name@mail.com or 09...',
                            icon: Icons.person_outline,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              if (!AuthService.isValidUsername(v)) return 'Invalid Email or Mobile format';
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
                            suffixIcon: IconButton(
                              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off, size: 20),
                              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                            ),
                            validator: (v) => AuthService.validatePassword(v ?? '', _usernameController.text),
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm Password',
                            hint: '••••••••',
                            icon: Icons.shield_outlined,
                            obscureText: !_isConfirmVisible,
                            suffixIcon: IconButton(
                              icon: Icon(_isConfirmVisible ? Icons.visibility : Icons.visibility_off, size: 20),
                              onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                            ),
                            validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 0,
                              ),
                              child: const Text('Sign Up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?', style: theme.textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                          child: Text('Login', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
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
