import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final int totalPhotos;
  final int totalAlbums;

  const ProfilePage({
    super.key,
    required this.totalPhotos,
    required this.totalAlbums,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 12),
            CircleAvatar(
              radius: 56,
              backgroundColor: theme.primaryColor.withAlpha(30),
              child: Icon(Icons.person, size: 56, color: theme.primaryColor),
            ),
            const SizedBox(height: 16),
            Text('User Account', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 32),

            // Stats row
            Row(
              children: [
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          '$totalPhotos',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        const Text('Photos',
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GlassContainer(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          '$totalAlbums',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor),
                        ),
                        const SizedBox(height: 4),
                        const Text('Albums',
                            style: TextStyle(fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Settings section
            _buildSectionHeader('Settings', theme),
            _buildOptionTile(
              context,
              Icons.dark_mode,
              'Dark Mode',
              trailing: Switch(
                value: themeProvider.isDarkMode,
                activeColor: theme.primaryColor,
                onChanged: (val) => themeProvider.toggleTheme(val),
              ),
            ),

            const SizedBox(height: 8),
            _buildSectionHeader('Account', theme),
            _buildOptionTile(
              context,
              Icons.person_outline,
              'Change Username',
              onTap: () => _showComingSoon(context),
            ),
            _buildOptionTile(
              context,
              Icons.lock_outline,
              'Change Password',
              onTap: () => _showComingSoon(context),
            ),

            const Divider(height: 40),

            _buildOptionTile(
              context,
              Icons.logout,
              'Logout',
              color: Colors.redAccent,
              onTap: () async {
                final confirmed = await _confirmLogout(context);
                if (confirmed && context.mounted) {
                  await AuthService.setLoggedIn(false);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (r) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: theme.hintColor,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    VoidCallback? onTap,
    Color? color,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: trailing ??
          const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }

  Future<bool> _confirmLogout(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Logout',
                      style: TextStyle(color: Colors.redAccent))),
            ],
          ),
        ) ??
        false;
  }
}
