import 'package:flutter/material.dart';
import '../themes/app_theme.dart';
import '../widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _acceptTerms = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the terms and conditions'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registration successful! 🎉'),
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
                            Icons.person_add_alt_1,
                            color: AppTheme.goldColor,
                            size: 45,
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          'Create Account',
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join us today and get started',
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),

                        CustomTextField(
                          controller: _nameController,
                          label: 'Full Name',
                          hint: 'Enter your full name',
                          icon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            if (value.length < 3) {
                              return 'Name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

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
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _phoneController,
                          label: 'Phone Number',
                          hint: 'Enter your phone number',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 10) {
                              return 'Please enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Minimum 8 characters',
                          icon: _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          icon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please confirm your password';
                            }
                            if (value != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                            icon: Icon(
                              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                              color: AppTheme.goldColor,
                            ),
                            label: Text(
                              _isPasswordVisible ? 'Hide Password' : 'Show Password',
                              style: const TextStyle(color: AppTheme.goldColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        Row(
                          children: [
                            SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _acceptTerms = value ?? false;
                                  });
                                },
                                activeColor: AppTheme.goldColor,
                                checkColor: AppTheme.blackDark,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'I agree to the Terms and Conditions',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        ElevatedButton(
                          onPressed: _register,
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
                            elevation: 5,
                            shadowColor: AppTheme.goldColor.withOpacity(0.4),
                          ),
                          child: const Text('Sign Up'),
                        ),
                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            TextButton(
                              onPressed: () {
                              },
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  color: AppTheme.goldColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: AppTheme.goldColor.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: AppTheme.goldColor.withOpacity(0.3),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () {
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.blackLight,
                                  border: Border.all(color: Colors.grey[800]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.network(
                                  'https://img.icons8.com/color/48/google-logo.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.blackLight,
                                  border: Border.all(color: Colors.grey[800]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.network(
                                  'https://img.icons8.com/color/48/github.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.blackLight,
                                  border: Border.all(color: Colors.grey[800]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.network(
                                  'https://img.icons8.com/color/48/twitter--v1.png',
                                  height: 30,
                                  width: 30,
                                ),
                              ),
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
        ),
      ),
    );
  }
}