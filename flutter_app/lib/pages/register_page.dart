import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../themes/app_theme.dart';
import 'login_page.dart';
import 'main_scaffold.dart';
import '../services/socket_service.dart';
import '../providers/auth_provider.dart';
import '../providers/gallery_provider.dart';
import 'package:provider/provider.dart';

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
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isContentVisible = true);
      }
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await SocketService().sendRequest(
          method: 'POST',
          route: '/user/signup/',
          payload: {
            'userName': _usernameController.text,
            'password': _passwordController.text,
          },
        );

        final int statusCode = response['statusCode'];

        if (statusCode == 200) {
          AuthService.showToast('Account created successfully');
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.setUsername(_usernameController.text);

          final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);
          galleryProvider.setUsername(_usernameController.text);
          await galleryProvider.loadAll();
          await AuthService.setLoggedIn(true);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainScaffold()),
            );
          }
        } else {
          final String message = response['message'] ?? 'Registration failed';
          AuthService.showToast(message, isError: true);
        }
      } catch (e) {
        AuthService.showToast('Connection error: $e', isError: true);
      }
    } else {
      AuthService.showToast('Please correct the errors', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/regback.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Gradient Overlay for Contrast
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(100),
                    Colors.black.withAlpha(200),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: AppTheme.spacingXl),
                      Hero(
                        tag: 'auth_icon',
                        child: Icon(Icons.auto_awesome_rounded, size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        'Join Us',
                        style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white),
                      ),
                      Text(
                        'Start your visual journey today',
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(180)),
                      ),
                      
                      const SizedBox(height: AppTheme.spacing3Xl),

                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 800),
                        opacity: _isContentVisible ? 1.0 : 0.0,
                        child: Column(
                          children: [
                            GlassContainer(
                              borderRadius: AppTheme.radiusXl,
                              child: Column(
                                children: [
                                  CustomTextField(
                                    controller: _usernameController,
                                    label: 'Email or Mobile',
                                    hint: 'name@mail.com or 09...',
                                    icon: Icons.person_outline_rounded,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (!AuthService.isValidUsername(v)) return 'Invalid format';
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  CustomTextField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    hint: '••••••••',
                                    icon: Icons.lock_outline_rounded,
                                    obscureText: !_isPasswordVisible,
                                    suffixIcon: IconButton(
                                      icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20, color: Colors.white70),
                                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                    ),
                                    validator: (v) => AuthService.validatePassword(v ?? '', _usernameController.text),
                                  ),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  CustomTextField(
                                    controller: _confirmPasswordController,
                                    label: 'Confirm Password',
                                    hint: '••••••••',
                                    icon: Icons.shield_outlined,
                                    obscureText: !_isConfirmVisible,
                                    suffixIcon: IconButton(
                                      icon: Icon(_isConfirmVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20, color: Colors.white70),
                                      onPressed: () => setState(() => _isConfirmVisible = !_isConfirmVisible),
                                    ),
                                    validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null,
                                  ),
                                  const SizedBox(height: AppTheme.spacing2Xl),
                                  ElevatedButton(
                                    onPressed: _register,
                                    child: const Text('Sign Up'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingXl),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ', 
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(180))
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())),
                                  child: Text(
                                    'Login', 
                                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w800)
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
