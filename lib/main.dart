import 'package:flutter/material.dart';
import 'pages/register_page.dart';
import 'themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register',
      theme: AppTheme.darkTheme,
      home: const RegisterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}