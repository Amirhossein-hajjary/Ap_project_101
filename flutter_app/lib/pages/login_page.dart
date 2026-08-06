import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../themes/app_theme.dart';
import 'register_page.dart';
import 'main_scaffold.dart';
import '../services/socket_service.dart';
import '../providers/auth_provider.dart';
import '../providers/gallery_provider.dart';

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
  bool _isContentVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isContentVisible = true);
        _checkBiometrics();
      }
    });
  }

  Future<void> _checkBiometrics() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    if (authProvider.biometricEnabled && authProvider.username.isNotEmpty) {
      bool success = await authProvider.loginWithBiometrics();
      if (success && mounted) {
        final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);
        galleryProvider.setUsername(authProvider.username);
        await galleryProvider.loadAll();
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScaffold()),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await SocketService().sendRequest(
          method: 'POST',
          route: '/user/login/',
          payload: {
            'userName': _usernameController.text,
            'password': _passwordController.text,
          },
        );

        final int statusCode = response['statusCode'];

        if (statusCode == 200) {
          AuthService.showToast('Login Successful');
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
          final String message = response['message'] ?? 'Invalid credentials';
          AuthService.showToast(message, isError: true);
        }
      } catch (e) {
        AuthService.showToast('Connection error: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/logback.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withAlpha(80),
                    Colors.black.withAlpha(180),
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
                      const SizedBox(height: AppTheme.spacingLg),
                      Hero(
                        tag: 'auth_icon',
                        child: Icon(Icons.lock_person_rounded, size: 64, color: Colors.white),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        'Welcome Back', 
                        style: theme.textTheme.headlineLarge?.copyWith(color: Colors.white)
                      ),
                      Text(
                        'Sign in to your secure gallery', 
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(180))
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
                                    label: 'Username',
                                    hint: 'Email or Phone',
                                    icon: Icons.person_outline_rounded,
                                    isDarkBackground: true,
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
                                    isDarkBackground: true,
                                    suffixIcon: IconButton(
                                      icon: Icon(_isPasswordVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded, size: 20, color: Colors.white70),
                                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                    ),
                                    validator: (v) => (v == null || v.isEmpty) ? 'Password required' : null,
                                  ),
                                  const SizedBox(height: AppTheme.spacingXl),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: _login,
                                          child: const Text('Login'),
                                        ),
                                      ),
                                      if (authProvider.biometricEnabled) ...[
                                        const SizedBox(width: AppTheme.spacingMd),
                                        InkWell(
                                          onTap: _checkBiometrics,
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                          child: Container(
                                            height: 56,
                                            width: 56,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withAlpha(30),
                                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                              border: Border.all(color: Colors.white.withAlpha(50)),
                                            ),
                                            child: const Icon(Icons.fingerprint_rounded, color: Colors.white, size: 32),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingXl),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Don't have an account? ", 
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withAlpha(180))
                                ),
                                TextButton(
                                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())),
                                  child: Text(
                                    'Sign Up', 
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
