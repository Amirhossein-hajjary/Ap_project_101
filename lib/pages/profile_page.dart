import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final int totalPhotos;
  final int totalAlbums;

  const ProfilePage({super.key, required this.totalPhotos, required this.totalAlbums});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=User&size=200'),
            ),
            const SizedBox(height: 20),
            Text('User Account', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 40),
            
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    child: Column(
                      children: [
                        Text('$totalPhotos', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('Photos'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassContainer(
                    child: Column(
                      children: [
                        Text('$totalAlbums', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const Text('Albums'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 40),
            _buildOptionTile(
              context,
              Icons.dark_mode,
              'Dark Mode',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (val) => themeProvider.toggleTheme(val),
              ),
            ),
            _buildOptionTile(context, Icons.person, 'Change Username', onTap: () {}),
            _buildOptionTile(context, Icons.lock, 'Change Password', onTap: () {}),
            const Divider(height: 40),
            _buildOptionTile(
              context,
              Icons.logout,
              'Logout',
              color: Colors.redAccent,
              onTap: () async {
                await AuthService.setLoggedIn(false);
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, {Widget? trailing, VoidCallback? onTap, Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
