import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'gallery_page.dart';
import 'albums_page.dart';
import 'search_page.dart';
import 'profile_page.dart';
import '../providers/gallery_provider.dart';
import '../widgets/pressable.dart';
import '../themes/app_theme.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final galleryProvider = Provider.of<GalleryProvider>(context);

    final List<Widget> pages = [
      const GalleryPage(),
      const AlbumsPage(),
      SearchPage(
        allPhotos: galleryProvider.allPhotos,
        userAlbums: galleryProvider.userAlbums,
        onDelete: galleryProvider.deletePhoto,
        onUpdateAlbums: galleryProvider.updatePhotoAlbums,
      ),
      ProfilePage(
        totalPhotos: galleryProvider.allPhotos.length,
        totalAlbums: galleryProvider.displayAlbums.length,
      ),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(AppTheme.spacingXl, 0, AppTheme.spacingXl, AppTheme.spacing2Xl),
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(isDark ? 80 : 20),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              color: (isDark ? const Color(0xFF0F172A) : Colors.white).withAlpha(180),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(0, Icons.grid_view_rounded, 'Gallery'),
                  _buildNavItem(1, Icons.collections_bookmark_rounded, 'Albums'),
                  _buildNavItem(2, Icons.search_rounded, 'Search'),
                  _buildNavItem(3, Icons.person_outline_rounded, 'Profile'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    final theme = Theme.of(context);
    
    return Pressable(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingSm),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withAlpha(30) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? theme.primaryColor : theme.hintColor.withAlpha(150),
              size: 26,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
