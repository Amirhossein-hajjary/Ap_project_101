import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/pressable.dart';
import 'album_details_page.dart';
import '../widgets/photo_image.dart';

class AlbumsOverviewPage extends StatelessWidget {
  const AlbumsOverviewPage({super.key});

  void _showCreateAlbumDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Album'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter album name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Provider.of<GalleryProvider>(context, listen: false).addAlbum(controller.text);
                Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final theme = Theme.of(context);
    
    // Using displayAlbums which handles the logic for 'Favorites' and hiding unassigned
    final albums = galleryProvider.displayAlbums;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Collections', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                  Pressable(
                    onTap: () => _showCreateAlbumDialog(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withAlpha(40),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add_rounded, color: theme.primaryColor),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: albums.isEmpty 
                ? _buildEmptyState(theme)
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: albums.length,
                    itemBuilder: (context, index) {
                      final albumName = albums[index];
                      final albumPhotos = galleryProvider.getPhotosForAlbum(albumName);
                      
                      return Pressable(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => AlbumDetailsPage(albumName: albumName)),
                        ),
                        child: GlassContainer(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor.withAlpha(20),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                  ),
                                  child: albumPhotos.isNotEmpty
                                      ? ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                                    child: PhotoImage(imageId: albumPhotos.first['id'] as int),
                                  )
                                      : Icon(albumName == 'Favorites' ? Icons.favorite_rounded : Icons.folder_open_rounded,
                                      size: 48, color: theme.primaryColor.withAlpha(100)),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      albumName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${albumPhotos.length} items',
                                      style: TextStyle(color: theme.hintColor, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_motion_rounded, size: 80, color: theme.hintColor.withAlpha(50)),
          const SizedBox(height: 16),
          Text('No albums yet', style: TextStyle(color: theme.hintColor, fontWeight: FontWeight.bold)),
          const Text('Create a collection to organize photos', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
