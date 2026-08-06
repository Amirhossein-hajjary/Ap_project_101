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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      home: isLoggedIn ? const SessionLoader() : const RegisterPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SessionLoader extends StatefulWidget {
  const SessionLoader({super.key});

  @override
  State<SessionLoader> createState() => _SessionLoaderState();
}

class _SessionLoaderState extends State<SessionLoader> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final galleryProvider = Provider.of<GalleryProvider>(context, listen: false);

    await authProvider.reloadUsername();
    galleryProvider.setUsername(authProvider.username);
    await galleryProvider.loadAll();

    if (mounted) setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return const MainScaffold();
  }
}