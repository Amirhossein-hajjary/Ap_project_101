import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';
import '../themes/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/pressable.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final int totalPhotos;
  final int totalAlbums;

  const ProfilePage({super.key, required this.totalPhotos, required this.totalAlbums});

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl, vertical: AppTheme.spacingMd),
      child: GlassContainer(
        borderRadius: AppTheme.radiusLg,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
        child: Row(
          children: [
            Text('Profile', style: theme.textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [AppTheme.darkBg, AppTheme.darkSurface]
                : [AppTheme.lightBg, AppTheme.lightBg.withAlpha(220)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: AppTheme.spacingLg),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacingXs),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.primaryColor, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: theme.primaryColor.withAlpha(20),
                          backgroundImage: const NetworkImage('https://ui-avatars.com/api/?name=User&background=6366F1&color=fff&size=200'),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      Text('Premium Member', style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w900, fontSize: 18)),
                      Text('member@gallery.app', style: theme.textTheme.labelMedium),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing3Xl),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                  child: Row(
                    children: [
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(AppTheme.spacingLg),
                          child: Column(
                            children: [
                              Text('$totalPhotos', style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w900)),
                              Text('Photos', style: theme.textTheme.labelMedium),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingLg),
                      Expanded(
                        child: GlassContainer(
                          padding: const EdgeInsets.all(AppTheme.spacingLg),
                          child: Column(
                            children: [
                              Text('$totalAlbums', style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.w900)),
                              const Text('Albums', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppTheme.spacing3Xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                  child: _buildOptionGroup(theme, 'PREFERENCES', [
                    _buildOptionTile(
                      context,
                      Icons.palette_rounded,
                      'Dark Mode',
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        activeThumbColor: theme.primaryColor,
                        onChanged: (val) => themeProvider.toggleTheme(val),
                      ),
                    ),
                    _buildOptionTile(context, Icons.translate_rounded, 'Language', trailing: Text('English', style: theme.textTheme.labelMedium)),
                  ]),
                ),
                const SizedBox(height: AppTheme.spacingXl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                  child: _buildOptionGroup(theme, 'SECURITY', [
                    _buildOptionTile(
                      context,
                      Icons.fingerprint_rounded,
                      'Biometric Lock',
                      trailing: Switch(
                        value: authProvider.biometricEnabled,
                        activeThumbColor: theme.primaryColor,
                        onChanged: (val) => authProvider.setBiometricEnabled(val),
                      ),
                    ),
                    _buildOptionTile(context, Icons.lock_outline_rounded, 'Change Password'),
                  ]),
                ),
                const SizedBox(height: AppTheme.spacing2Xl),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                  child: Pressable(
                    onTap: () async {
                      await AuthService.setLoggedIn(false);
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginPage()), (r) => false);
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withAlpha(20),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: theme.colorScheme.error.withAlpha(40)),
                      ),
                      child: Center(
                        child: Text('Sign Out', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.w900, fontSize: 16)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
          padding: const EdgeInsets.only(left: AppTheme.spacingSm, bottom: AppTheme.spacingMd),
          child: Text(title, style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 1.5, fontWeight: FontWeight.w900)),
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
      title: Text(title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, size: 20, color: theme.hintColor),
      onTap: onTap,
    );
  }
}
