import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/pressable.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../themes/app_theme.dart';
import 'album_details_page.dart';
import '../widgets/photo_image.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  void _createNewAlbum() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Album'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter album name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                provider.addAlbum(controller.text);
                Navigator.pop(context);
                AuthService.showToast('Album created');
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAlbumOptions(String name) {
    if (name == 'Favorites') return;
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_rounded),
              title: const Text('Rename Album'),
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(name);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete_rounded, color: Theme.of(context).colorScheme.error),
              title: Text('Delete Album', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteAlbum(name);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Album'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter new name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (controller.text.isNotEmpty && controller.text != oldName) {
                final success = await Provider.of<GalleryProvider>(context, listen: false)
                    .renameAlbum(oldName, controller.text);
                if (context.mounted) Navigator.pop(context);
                AuthService.showToast(success ? 'Album renamed' : 'Failed to rename album', isError: !success);
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAlbum(String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Album'),
        content: Text('Are you sure you want to delete "$name"? The photos will not be deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<GalleryProvider>(context, listen: false).deleteAlbum(name);
              Navigator.pop(context);
              AuthService.showToast('Album deleted');
            },
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl, vertical: AppTheme.spacingMd),
      child: GlassContainer(
        borderRadius: AppTheme.radiusLg,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Collections', style: theme.textTheme.headlineMedium),
                  Text('$count folders', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            Pressable(
              onTap: _createNewAlbum,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: theme.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final albums = galleryProvider.displayAlbums;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(theme, albums.length),
              Expanded(
                child: albums.isEmpty
                    ? _buildEmptyState(theme)
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(AppTheme.spacingXl, AppTheme.spacingSm, AppTheme.spacingXl, 120),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: AppTheme.spacingXl,
                          crossAxisSpacing: AppTheme.spacingXl,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: albums.length,
                        itemBuilder: (context, index) {
                          final albumName = albums[index];
                          final photosInAlbum = galleryProvider.getPhotosForAlbum(albumName);
                          return _buildAlbumCard(context, albumName, photosInAlbum);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing2Xl),
            decoration: BoxDecoration(
              color: theme.primaryColor.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.folder_open_rounded, size: 80, color: theme.primaryColor.withAlpha(60)),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          Text('No albums yet', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppTheme.spacingSm),
          Text('Organize your photos into albums', style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, String title, List<Map<String, dynamic>> photos) {
    final theme = Theme.of(context);
    final hasPhotos = photos.isNotEmpty;
    final lastPhoto = hasPhotos ? photos.first : null;

    return Pressable(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => AlbumDetailsPage(albumName: title)));
      },
      onLongPress: () => _showAlbumOptions(title),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          color: theme.cardTheme.color,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Stack(
            children: [
              Positioned.fill(
                child: hasPhotos
                    ? PhotoImage(imageId: lastPhoto!['id'] as int)
                    : Container(
                  color: theme.primaryColor.withAlpha(10),
                  child: Icon(Icons.image_outlined, color: theme.primaryColor.withAlpha(60), size: 40),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(30),
                        Colors.black.withAlpha(180),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: AppTheme.spacingLg,
                left: AppTheme.spacingLg,
                right: AppTheme.spacingLg,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${photos.length} items',
                      style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
