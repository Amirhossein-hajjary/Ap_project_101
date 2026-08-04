import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'pages/register_page.dart';
import 'themes/app_theme.dart';
import 'themes/theme_provider.dart';
import 'services/auth_service.dart';

import 'providers/gallery_provider.dart';
import 'providers/auth_provider.dart';
import 'pages/main_scaffold.dart';
import 'pages/test_connection_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final bool loggedIn = await AuthService.isLoggedIn();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => GalleryProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(isLoggedIn: loggedIn),
    ),
  );
}


class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Glass Gallery',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const TestConnectionPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
