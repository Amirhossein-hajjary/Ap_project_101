import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import 'register_page.dart';
import 'main_scaffold.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isContentVisible = false; // وضعیت نمایش محتوا

  @override
  void initState() {
    super.initState();
    // ایجاد تاخیر یک ثانیه‌ای برای نمایش باکس لاگین
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isContentVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      AuthService.showToast('Login Successful');
      await AuthService.setLoggedIn(true);
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScaffold()),
        );
      }
    } else {
      AuthService.showToast('Invalid input data', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/logback.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    Icon(Icons.lock_person_outlined, size: 60, color: Colors.white),
                    const SizedBox(height: 8),
                    Text('Welcome Back', style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white)),
                    Text('Sign in to continue', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                    
                    // انیمیشن برای باکس ورود
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: _isContentVisible ? 1.0 : 0.0,
                      child: AnimatedPadding(
                        duration: const Duration(milliseconds: 800),
                        padding: EdgeInsets.only(top: _isContentVisible ? 150 : 200),
                        child: Column(
                          children: [
                            GlassContainer(
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _usernameController,
                                    label: 'Username',
                                    hint: 'Email or Phone',
                                    icon: Icons.person_outline,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (!AuthService.isValidUsername(v)) return 'Invalid format';
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
                                    validator: (v) => v!.isEmpty ? 'Password required' : null,
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: theme.primaryColor,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        elevation: 0,
                                      ),
                                      child: const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Don't have an account?", style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                                  child: Text('Sign Up', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
