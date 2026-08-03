import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/pressable.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../themes/app_theme.dart';
import 'photo_details_page.dart';

class AlbumDetailsPage extends StatefulWidget {
  final String albumName;

  const AlbumDetailsPage({super.key, required this.albumName});

  @override
  State<AlbumDetailsPage> createState() => _AlbumDetailsPageState();
}

class _AlbumDetailsPageState extends State<AlbumDetailsPage> {
  String _sortBy = 'Date';
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};

  List<Map<String, dynamic>> _getPhotos(GalleryProvider provider) {
    List<Map<String, dynamic>> photos = provider.getPhotosForAlbum(widget.albumName);

    if (_sortBy == 'Date') {
      photos.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    } else {
      photos.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }
    return photos;
  }

  void _bulkTransfer() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    final photos = _getPhotos(provider);
    String? targetAlbum;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Transfer items'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select destination album:'),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                items: provider.userAlbums
                    .where((a) => a != widget.albumName)
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (val) => setDialogState(() => targetAlbum = val),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: targetAlbum == null ? null : () {
                List<int> ids = _selectedIndices.map((i) => photos[i]['id'] as int).toList();
                for (var id in ids) {
                  provider.transferPhoto(id, widget.albumName, targetAlbum!);
                }
                setState(() {
                  _selectedIndices.clear();
                  _isSelectionMode = false;
                });
                Navigator.pop(context);
                AuthService.showToast('Transferred ${ids.length} items to $targetAlbum');
              },
              child: const Text('Transfer'),
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
    final photos = _getPhotos(galleryProvider);

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
            children: [
              _buildHeader(theme, photos.length),
              if (_isSelectionMode) _buildSelectionToolbar(theme),
              _buildFilterBar(theme),
              Expanded(
                child: photos.isEmpty
                    ? _buildEmptyState(theme)
                    : GridView.builder(
                        padding: const EdgeInsets.all(AppTheme.spacingSm),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                        ),
                        itemCount: photos.length,
                        itemBuilder: (context, index) => _buildPhotoCard(index, photos, theme),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl, vertical: AppTheme.spacingMd),
      child: GlassContainer(
        borderRadius: AppTheme.radiusLg,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingSm),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.albumName, style: theme.textTheme.titleLarge),
                  Text('$count items', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            if (widget.albumName != 'Favorites')
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 22, color: Colors.redAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Album'),
                      content: Text('Are you sure you want to delete "${widget.albumName}"?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () {
                            Provider.of<GalleryProvider>(context, listen: false).deleteAlbum(widget.albumName);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            AuthService.showToast('Album deleted');
                          },
                          child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionToolbar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingSm),
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl, vertical: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(20),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: theme.primaryColor.withAlpha(40)),
      ),
      child: Row(
        children: [
          Text(
            '${_selectedIndices.length} selected', 
            style: TextStyle(fontWeight: FontWeight.w800, color: theme.primaryColor)
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.compare_arrows_rounded, size: 22),
            onPressed: widget.albumName == 'Favorites' ? null : _bulkTransfer,
            color: theme.primaryColor,
            tooltip: 'Transfer to another album',
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 22),
            onPressed: () => setState(() { _selectedIndices.clear(); _isSelectionMode = false; })
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl, vertical: AppTheme.spacingSm),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.sort_rounded, size: 18),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            items: ['Date', 'Name'].map((s) => DropdownMenuItem(
              value: s, 
              child: Text('Sort by $s')
            )).toList(),
            onChanged: (val) => setState(() { _sortBy = val!; }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 64, color: theme.hintColor.withAlpha(80)),
          const SizedBox(height: AppTheme.spacingLg),
          Text('No photos in this album', style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor)),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(int index, List<Map<String, dynamic>> photos, ThemeData theme) {
    final photo = photos[index];
    final bool isSelected = _selectedIndices.contains(index);

    return Pressable(
      onLongPress: () => setState(() { _selectedIndices.add(index); _isSelectionMode = true; }),
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (_selectedIndices.contains(index)) {
              _selectedIndices.remove(index);
            } else {
              _selectedIndices.add(index);
            }
            if (_selectedIndices.isEmpty) _isSelectionMode = false;
          });
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailsPage(
            photos: photos,
            initialIndex: index,
            userAlbums: Provider.of<GalleryProvider>(context, listen: false).userAlbums,
            onDelete: (id) => Provider.of<GalleryProvider>(context, listen: false).deletePhoto(id),
            onUpdateAlbums: (id, albums) => Provider.of<GalleryProvider>(context, listen: false).updatePhotoAlbums(id, albums),
          )));
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              image: DecorationImage(
                image: photo['isLocal'] ? FileImage(File(photo['image'])) : NetworkImage(photo['image']) as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (isSelected) 
            Container(
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(100),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32)
            ),
        ],
      ),
    );
  }
}
