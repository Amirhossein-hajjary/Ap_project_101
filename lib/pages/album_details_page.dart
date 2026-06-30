import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/pressable.dart';
import 'photo_details_page.dart';

class AlbumDetailsPage extends StatefulWidget {
  final String albumName;
  const AlbumDetailsPage({super.key, required this.albumName});

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  String _sortBy = 'Date';

  void _deleteAlbum(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Album'),
        content: Text('Are you sure you want to delete "${widget.albumName}"? Photos will remain in your gallery.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Provider.of<GalleryProvider>(context, listen: false).deleteAlbum(widget.albumName);
              Navigator.pop(context); 
              Navigator.pop(context); 
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final galleryProvider = Provider.of<GalleryProvider>(context);
    final theme = Theme.of(context);
    
    // Use provider method for consistency
    final albumPhotos = galleryProvider.getPhotosForAlbum(widget.albumName);

    // Sorting functionality within album
    if (_sortBy == 'Date') {
      albumPhotos.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    } else {
      albumPhotos.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.albumName.toUpperCase()),
        actions: [
          if (widget.albumName != 'Favorites')
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              onPressed: () => _deleteAlbum(context),
            ),
        ],
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.brightness == Brightness.dark
                ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                : [theme.scaffoldBackgroundColor, theme.scaffoldBackgroundColor.withAlpha(200)],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  DropdownButton<String>(
                    value: _sortBy,
                    underline: const SizedBox(),
                    items: ['Date', 'Name'].map((s) => DropdownMenuItem(value: s, child: Text('Sort by $s', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                    onChanged: (val) => setState(() { _sortBy = val!; }),
                  ),
                  const Spacer(),
                  Text('${albumPhotos.length} items', style: TextStyle(color: theme.hintColor, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: albumPhotos.isEmpty
                  ? Center(child: Text('No photos here', style: TextStyle(color: theme.hintColor)))
                  : GridView.builder(
                      padding: const EdgeInsets.all(4),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                      ),
                      itemCount: albumPhotos.length,
                      itemBuilder: (context, index) {
                        final photo = albumPhotos[index];
                        return Pressable(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PhotoDetailsPage(
                                photos: albumPhotos,
                                initialIndex: index,
                                userAlbums: galleryProvider.displayAlbums,
                                onDelete: (id) => galleryProvider.deletePhoto(id),
                                onMove: (id, newAlbum) {
                                  // Requirement: Transfer (move) image from CURRENT album to ANOTHER
                                  galleryProvider.transferPhoto(id, widget.albumName, newAlbum);
                                },
                              ),
                            ),
                          ),
                          child: Hero(
                            tag: photo['id'],
                            child: Image.file(File(photo['image']), fit: BoxFit.cover),
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
}
