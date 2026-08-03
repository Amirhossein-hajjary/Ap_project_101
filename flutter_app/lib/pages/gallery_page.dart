import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/theme_provider.dart';
import '../themes/app_theme.dart';
import '../providers/gallery_provider.dart';
import '../widgets/glass_container.dart';
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

  void _bulkMoveToAlbum() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    if (provider.userAlbums.isEmpty) {
      AuthService.showToast('No albums available. Create one first.', isError: true);
      return;
    }
    String selectedMoveAlbum = provider.userAlbums.first;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Move to Album'),
          content: Wrap(
            spacing: AppTheme.spacingSm,
            children: provider.userAlbums.map((a) => ChoiceChip(
              label: Text(a),
              selected: selectedMoveAlbum == a,
              onSelected: (v) => setDialogState(() => selectedMoveAlbum = a),
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                List<int> idsToMove = _selectedIndices.map((i) => _getFilteredPhotos(provider.allPhotos)[i]['id'] as int).toList();
                provider.bulkMove(idsToMove, selectedMoveAlbum);
                setState(() {
                  _selectedIndices.clear();
                  _isSelectionMode = false;
                });
                Navigator.pop(context);
                AuthService.showToast('Moved to $selectedMoveAlbum');
              },
              child: const Text('Move'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeProvider provider, ThemeData theme) {
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
                  Text('Gallery', style: theme.textTheme.headlineMedium),
                  Text('Captured Memories', style: theme.textTheme.labelMedium),
                ],
              ),
            ),
            Pressable(
              onTap: () => provider.toggleTheme(!provider.isDarkMode),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  provider.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, 
                  size: 22, 
                  color: theme.primaryColor
                ),
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
                ? [AppTheme.darkBg, AppTheme.darkSurface]
                : [AppTheme.lightBg, AppTheme.lightBg.withAlpha(220)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(themeProvider, theme),
              if (_isSelectionMode) _buildSelectionToolbar(theme, filteredPhotos),
              _buildFilterBar(theme),
              Expanded(
                child: photosToShow.isEmpty 
                  ? _buildEmptyState(theme)
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(AppTheme.spacingSm, AppTheme.spacingSm, AppTheme.spacingSm, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
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
            elevation: 4,
            onPressed: null,
            child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: TweenAnimationBuilder<double>(
        duration: const Duration(seconds: 1),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing2Xl),
              decoration: BoxDecoration(
                color: theme.primaryColor.withAlpha(10),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.photo_library_outlined, size: 80, color: theme.primaryColor.withAlpha(60)),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            Text('No photos found', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Add your first memory to get started', 
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionToolbar(ThemeData theme, List<Map<String, dynamic>> filteredPhotos) {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
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
          Text('${_selectedIndices.length} selected', style: TextStyle(fontWeight: FontWeight.w800, color: theme.primaryColor)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.drive_file_move_rounded, size: 22), 
            onPressed: _bulkMoveToAlbum,
            color: theme.primaryColor,
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, size: 22),
            color: theme.colorScheme.error,
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
          IconButton(icon: const Icon(Icons.close_rounded, size: 22), onPressed: () => setState(() { _selectedIndices.clear(); _isSelectionMode = false; })),
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
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            items: ['Date', 'Name'].map((s) => DropdownMenuItem(value: s, child: Text('Sort by $s'))).toList(),
            onChanged: (val) => setState(() { _sortBy = val!; }),
          ),
          const Spacer(),
          FilterChip(
            label: const Text('Favorites'),
            selected: _showOnlyFavorites,
            onSelected: (val) => setState(() { _showOnlyFavorites = val; }),
            selectedColor: theme.primaryColor.withAlpha(30),
            checkmarkColor: theme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusSm)),
            side: BorderSide.none,
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
            userAlbums: provider.userAlbums,
            onDelete: (id) => provider.deletePhoto(id),
            onUpdateAlbums: (id, albums) => provider.updatePhotoAlbums(id, albums),
          )));
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: photo['id'] ?? photo['image'],
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                image: DecorationImage(
                  image: photo['isLocal'] ? FileImage(File(photo['image'])) : NetworkImage(photo['image']) as ImageProvider,
                  fit: BoxFit.cover,
                ),
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
          if (photo['isFavorite'] == true) 
            Positioned(
              top: 6, 
              right: 6, 
              child: Icon(Icons.favorite_rounded, color: theme.colorScheme.error, size: 16)
            ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoader() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withAlpha(50),
      highlightColor: Colors.grey.withAlpha(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
      ),
    );
  }
}
