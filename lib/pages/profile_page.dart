import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/pressable.dart';
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
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.primaryColor, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 54,
                        backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=User&background=6366F1&color=fff&size=200'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Premium Member', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
                    const Text('member@gallery.app', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              Row(
                children: [
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('$totalPhotos', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.primaryColor)),
                          const Text('Photos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassContainer(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Text('$totalAlbums', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, color: theme.primaryColor)),
                          const Text('Albums', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 40),
              _buildOptionGroup(theme, 'Preferences', [
                _buildOptionTile(
                  context,
                  Icons.palette_rounded,
                  'Dark Mode',
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    activeColor: theme.primaryColor,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),
                ),
                _buildOptionTile(context, Icons.translate_rounded, 'Language', trailing: const Text('English', style: TextStyle(fontSize: 12, color: Colors.grey))),
              ]),
              const SizedBox(height: 24),
              _buildOptionGroup(theme, 'Security', [
                _buildOptionTile(context, Icons.fingerprint_rounded, 'Biometric Lock'),
                _buildOptionTile(context, Icons.lock_outline_rounded, 'Change Password'),
              ]),
              const SizedBox(height: 32),
              Pressable(
                onTap: () async {
                  await AuthService.setLoggedIn(false);
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withAlpha(20),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.redAccent.withAlpha(40)),
                  ),
                  child: const Center(
                    child: Text('Sign Out', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w900, fontSize: 16)),
                  ),
                ),
              ),
              const SizedBox(height: 100), // Padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionGroup(ThemeData theme, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1, color: Colors.grey)),
        ),
        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildOptionTile(BuildContext context, IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.primaryColor, size: 22),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
