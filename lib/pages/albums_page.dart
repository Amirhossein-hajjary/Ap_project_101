import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../themes/theme_provider.dart';

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  final List<Map<String, dynamic>> _albums = [
    {
      'title': 'Nature & Mountains',
      'count': '1,240',
      'image': 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&q=80&w=500',
      'isLocal': false,
    },
    {
      'title': 'Modern Architecture',
      'count': '452',
      'image': 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?auto=format&fit=crop&q=80&w=500',
      'isLocal': false,
    },
    {
      'title': 'Ocean & Blue',
      'count': '891',
      'image': 'https://images.unsplash.com/photo-1505118380757-91f5f45d8de4?auto=format&fit=crop&q=80&w=500',
      'isLocal': false,
    },
    {
      'title': 'Forest Secrets',
      'count': '125',
      'image': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?auto=format&fit=crop&q=80&w=500',
      'isLocal': false,
    },
    {
      'title': 'Night Cityscape',
      'count': '342',
      'image': 'https://images.unsplash.com/photo-1477959858617-67f85cf4f1df?auto=format&fit=crop&q=80&w=500',
      'isLocal': false,
    },
    {
      'title': 'Abstract Art',
      'count': '670',
      'image': 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?auto=format&fit=crop&q=80&w=500',
      'isLocal': false,
    },
  ];

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _albums.insert(0, {
            'title': 'New Capture',
            'count': '1',
            'image': pickedFile.path,
            'isLocal': true,
          });
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Image added to gallery!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Add New Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('MY ALBUMS'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: _albums.length,
        itemBuilder: (context, index) => _buildAlbumCard(context, _albums[index]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: theme.primaryColor,
        onPressed: _showPickerOptions,
        icon: Icon(Icons.add_photo_alternate_outlined, color: Colors.white),
        label: const Text('Add Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildAlbumCard(BuildContext context, Map<String, dynamic> album) {
    final theme = Theme.of(context);
    final bool isLocal = album['isLocal'] ?? false;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            Positioned.fill(
              child: isLocal 
                ? Image.file(
                    File(album['image']),
                    fit: BoxFit.cover,
                  )
                : Image.network(
                    album['image'],
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: theme.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: theme.brightness == Brightness.dark ? Colors.white10 : Colors.black12,
                        child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                      );
                    },
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
                      Colors.black.withAlpha(20),
                      Colors.black.withAlpha(180),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${album['count']} Photos',
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {},
                  splashColor: theme.primaryColor.withAlpha(50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
