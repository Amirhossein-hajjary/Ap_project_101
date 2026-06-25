import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'register_page.dart'; // وارد کردن صفحه ثبت‌نام برای جابه‌جایی

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // در اینجا منطق اتصال به API یا سرور قرار می‌گیرد
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Login Successful! Welcome back 🎉'),
          backgroundColor: AppTheme.goldColor,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.blackColor.withOpacity(0.9),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Card(
                elevation: 15,
                shadowColor: AppTheme.goldColor.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(
                    color: AppTheme.goldColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // آیکون بالای صفحه (تغییر یافته به قفل)
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.goldColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.goldColor,
                              width: 3,
                            ),
                          ),
                          child: Icon(
                            Icons.lock_person_outlined,
                            color: AppTheme.goldColor,
                            size: 45,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Welcome Back',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please sign in to continue',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        // فیلد ایمیل
                        CustomTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email address',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // فیلد رمز عبور
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          icon: _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),

                        // ردیف فراموشی رمز عبور و نمایش پسورد
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isPasswordVisible = !_isPasswordVisible;
                                });
                              },
                              child: Text(
                                _isPasswordVisible ? 'Hide' : 'Show',
                                style: const TextStyle(color: AppTheme.goldColor),
                              ),
                            ),
                            TextButton(
                              onPressed: () {},
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // دکمه ورود
                        ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.goldColor,
                            foregroundColor: AppTheme.blackDark,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                        const SizedBox(height: 16),

                        // لینک به صفحه ثبت‌نام
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Don't have an account?",
                              style: TextStyle(color: Colors.white70),
                            ),
                            TextButton(
                              onPressed: () {
                                // برگشت به صفحه ثبت نام
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppTheme.goldColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        // جداکننده OR
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppTheme.goldColor.withOpacity(0.3))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text('OR', style: TextStyle(color: Colors.grey)),
                            ),
                            Expanded(child: Divider(color: AppTheme.goldColor.withOpacity(0.3))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // دکمه‌های شبکه‌های اجتماعی (کپی شده از استایل شما)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _socialButton('https://img.icons8.com/color/48/google-logo.png'),
                            const SizedBox(width: 12),
                            _socialButton('https://img.icons8.com/color/48/github.png'),
                            const SizedBox(width: 12),
                            _socialButton('https://img.icons8.com/color/48/twitter--v1.png'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton(String imageUrl) {
    return IconButton(
      onPressed: () {},
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.blackLight,
          border: Border.all(color: Colors.grey[800]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Image.network(imageUrl, height: 25, width: 25),
      ),
    );
  }
}
