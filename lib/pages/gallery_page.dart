import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/theme_provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/pressable.dart';
import '../services/auth_service.dart';
import 'photo_details_page.dart';
import 'upload_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ScrollController _scrollController = ScrollController();
  
  String _sortBy = 'Date';
  bool _showOnlyFavorites = false;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};
  bool _isLoadingMore = false;

  int _currentLimit = 21;
  final int _pageSize = 21;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    final filteredCount = _getFilteredPhotos(provider.allPhotos).length;
    
    if (_currentLimit < filteredCount) {
      setState(() => _isLoadingMore = true);
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _currentLimit += _pageSize;
          _isLoadingMore = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _getFilteredPhotos(List<Map<String, dynamic>> allPhotos) {
    List<Map<String, dynamic>> list = List.from(allPhotos);
    
    if (_showOnlyFavorites) {
      list = list.where((p) => p['isFavorite'] == true).toList();
    }
    
    if (_sortBy == 'Date') {
      list.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    } else if (_sortBy == 'Name') {
      list.sort((a, b) => (a['name'] as String).compareTo(b['name'] as String));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final galleryProvider = Provider.of<GalleryProvider>(context);
    
    final filteredPhotos = _getFilteredPhotos(galleryProvider.allPhotos);
    final photosToShow = filteredPhotos.take(_currentLimit).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
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
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(themeProvider, theme),
              if (_isSelectionMode) _buildSelectionToolbar(theme, filteredPhotos),
              _buildFilterBar(theme),
              // Album selector REMOVED from Home Screen
              Expanded(
                child: photosToShow.isEmpty 
                  ? _buildEmptyState(theme)
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(2, 2, 2, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemCount: photosToShow.length + (_isLoadingMore ? 9 : 0),
                      itemBuilder: (context, index) {
                        if (index >= photosToShow.length) return _buildShimmerLoader();
                        return _buildPhotoCard(index, theme, photosToShow);
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isSelectionMode ? null : Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Pressable(
          scale: 0.9,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadPage())),
          child: FloatingActionButton(
            backgroundColor: theme.primaryColor,
            elevation: 8,
            onPressed: null,
            child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
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
          Icon(Icons.photo_library_outlined, size: 80, color: theme.hintColor.withAlpha(100)),
          const SizedBox(height: 16),
          const Text('No photos found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Add your first memory', style: TextStyle(color: theme.hintColor.withAlpha(150))),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeProvider provider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gallery', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                Text('Captured Memories', style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withAlpha(150))),
              ],
            ),
          ),
          Pressable(
            onTap: () => provider.toggleTheme(!provider.isDarkMode),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(30),
                shape: BoxShape.circle,
              ),
              child: Icon(provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20, color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionToolbar(ThemeData theme, List<Map<String, dynamic>> filteredPhotos) {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.primaryColor.withAlpha(60)),
      ),
      child: Row(
        children: [
          Text('${_selectedIndices.length} selected', style: TextStyle(fontWeight: FontWeight.w800, color: theme.primaryColor)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              List<int> idsToRemove = _selectedIndices.map((i) => filteredPhotos[i]['id'] as int).toList();
              provider.bulkDelete(idsToRemove);
              setState(() {
                _selectedIndices.clear();
                _isSelectionMode = false;
              });
              AuthService.showToast('Deleted selected');
            },
          ),
          IconButton(icon: const Icon(Icons.close_rounded, size: 20), onPressed: () => setState(() { _selectedIndices.clear(); _isSelectionMode = false; })),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            items: ['Date', 'Name'].map((s) => DropdownMenuItem(value: s, child: Text('Sort by $s', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
            onChanged: (val) => setState(() { _sortBy = val!; }),
          ),
          const Spacer(),
          FilterChip(
            label: const Text('Favorites', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            selected: _showOnlyFavorites,
            onSelected: (val) => setState(() { _showOnlyFavorites = val; }),
            selectedColor: theme.primaryColor.withAlpha(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(int index, ThemeData theme, List<Map<String, dynamic>> photos) {
    final photo = photos[index];
    final bool isSelected = _selectedIndices.contains(index);
    final provider = Provider.of<GalleryProvider>(context, listen: false);

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
            userAlbums: provider.displayAlbums,
            onDelete: (id) => provider.deletePhoto(id),
            onMove: (id, newAlbum) => provider.addPhotoToAlbum(id, newAlbum),
          )));
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: photo['id'] ?? photo['image'],
            child: photo['isLocal'] ? Image.file(File(photo['image']), fit: BoxFit.cover) : Image.network(photo['image'], fit: BoxFit.cover),
          ),
          if (isSelected) Positioned.fill(child: Container(color: theme.primaryColor.withAlpha(100), child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 32))),
          if (photo['isFavorite'] == true) const Positioned(top: 6, right: 6, child: Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 16)),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withAlpha(50),
      highlightColor: Colors.grey.withAlpha(20),
      child: Container(color: Colors.white),
    );
  }
}
