import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/theme_provider.dart';
import '../providers/gallery_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/pressable.dart';
import '../services/auth_service.dart';
import 'photo_details_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  String _selectedAlbum = 'All';
  String _sortBy = 'Date';
  bool _showOnlyFavorites = false;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};
  bool _isLoadingMore = false;

  List<Map<String, dynamic>> _displayedPhotos = [];
  final int _pageSize = 21;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadInitialPhotos());
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialPhotos() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    setState(() {
      _displayedPhotos = _filterAndSort(provider.allPhotos).take(_pageSize).toList();
    });
  }

  void _onScroll() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        _displayedPhotos.length < _filterAndSort(provider.allPhotos).length) {
      _loadMorePhotos();
    }
  }

  Future<void> _loadMorePhotos() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    if (mounted) {
      setState(() {
        int nextBatchSize = _displayedPhotos.length + _pageSize;
        _displayedPhotos = _filterAndSort(provider.allPhotos).take(nextBatchSize).toList();
        _isLoadingMore = false;
      });
    }
  }

  List<Map<String, dynamic>> _filterAndSort(List<Map<String, dynamic>> photos) {
    List<Map<String, dynamic>> list = List.from(photos);
    if (_selectedAlbum != 'All') {
      list = list.where((p) => p['album'] == _selectedAlbum).toList();
    }
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

  Future<void> _pickImage(ImageSource source, {String album = 'Default', String tags = ''}) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file != null && mounted) {
        final provider = Provider.of<GalleryProvider>(context, listen: false);
        final newPhoto = {
          'id': DateTime.now().millisecondsSinceEpoch,
          'name': 'Photo ${DateTime.now().second}',
          'image': file.path,
          'album': album,
          'date': DateTime.now(),
          'isLocal': true,
          'isFavorite': false,
          'tags': tags,
          'captions': [],
          'comments': [],
          'allowComments': true,
        };
        provider.addPhoto(newPhoto);
        _loadInitialPhotos();
        AuthService.showToast('Photo uploaded to $album');
      }
    } catch (e) {
      AuthService.showToast('Failed to pick image', isError: true);
    }
  }

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

  void _bulkMoveToAlbum() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    String selectedMoveAlbum = 'Default';
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Move to Album'),
          content: Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Default'),
                selected: selectedMoveAlbum == 'Default',
                onSelected: (v) => setDialogState(() => selectedMoveAlbum = 'Default'),
              ),
              ...provider.userAlbums.map((a) => ChoiceChip(
                label: Text(a),
                selected: selectedMoveAlbum == a,
                onSelected: (v) => setDialogState(() => selectedMoveAlbum = a),
              )),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                List<int> idsToMove = _selectedIndices.map((i) => _displayedPhotos[i]['id'] as int).toList();
                provider.bulkMove(idsToMove, selectedMoveAlbum);
                setState(() {
                  _selectedIndices.clear();
                  _isSelectionMode = false;
                  _loadInitialPhotos();
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

  void _showAddOptions() {
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    final TextEditingController tagsController = TextEditingController();
    String selectedTargetAlbum = 'Default';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GlassContainer(
          borderRadius: 32,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Upload Photo', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 24),
                const Text('Select Target Album:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Default'),
                      selected: selectedTargetAlbum == 'Default',
                      onSelected: (v) => setModalState(() => selectedTargetAlbum = 'Default'),
                    ),
                    ...provider.userAlbums.map((a) => ChoiceChip(
                      label: Text(a),
                      selected: selectedTargetAlbum == a,
                      onSelected: (v) => setModalState(() => selectedTargetAlbum = a),
                    )),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags',
                    hintText: 'e.g. nature, mountain, sunset',
                    prefixIcon: Icon(Icons.tag_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                  ),
                ),
                const Divider(height: 40),
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded),
                  title: const Text('Gallery'),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery, album: selectedTargetAlbum, tags: tagsController.text); },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt_rounded),
                  title: const Text('Camera'),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera, album: selectedTargetAlbum, tags: tagsController.text); },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final galleryProvider = Provider.of<GalleryProvider>(context);

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
              if (_isSelectionMode) _buildSelectionToolbar(theme),
              _buildFilterBar(theme),
              _buildAlbumSelector(galleryProvider),
              Expanded(
                child: _displayedPhotos.isEmpty 
                  ? _buildEmptyState(theme)
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.fromLTRB(2, 2, 2, 100),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemCount: _displayedPhotos.length + (_isLoadingMore ? 9 : 0),
                      itemBuilder: (context, index) {
                        if (index >= _displayedPhotos.length) return _buildShimmerLoader();
                        return _buildPhotoCard(index, theme);
                      },
                    ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isSelectionMode ? null : Padding(
        padding: const EdgeInsets.only(bottom: 80), // Avoid bottom bar
        child: Pressable(
          scale: 0.9,
          onTap: _showAddOptions,
          child: FloatingActionButton(
            backgroundColor: theme.primaryColor,
            elevation: 8,
            onPressed: null, // Handled by Pressable
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

  Widget _buildSelectionToolbar(ThemeData theme) {
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
          IconButton(icon: const Icon(Icons.drive_file_move_rounded, size: 20), onPressed: _bulkMoveToAlbum),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.redAccent, size: 20),
            onPressed: () {
              List<int> idsToRemove = _selectedIndices.map((i) => _displayedPhotos[i]['id'] as int).toList();
              provider.bulkDelete(idsToRemove);
              setState(() {
                _selectedIndices.clear();
                _isSelectionMode = false;
                _loadInitialPhotos();
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
            onChanged: (val) => setState(() { _sortBy = val!; _loadInitialPhotos(); }),
          ),
          const Spacer(),
          FilterChip(
            label: const Text('Favorites', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            selected: _showOnlyFavorites,
            onSelected: (val) => setState(() { _showOnlyFavorites = val; _loadInitialPhotos(); }),
            selectedColor: theme.primaryColor.withAlpha(50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumSelector(GalleryProvider provider) {
    return SizedBox(
      height: 64,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        children: [
          _buildAlbumChip('All'),
          ...provider.userAlbums.map((a) => _buildAlbumChip(a)),
          Pressable(
            onTap: _createNewAlbum,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(30)),
              ),
              child: const Icon(Icons.add_rounded, size: 20, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumChip(String title) {
    final isSelected = _selectedAlbum == title;
    final theme = Theme.of(context);
    return Pressable(
      onTap: () => setState(() { _selectedAlbum = title; _loadInitialPhotos(); }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected ? [BoxShadow(color: theme.primaryColor.withAlpha(100), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Center(
          child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade500, fontSize: 13, fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index, ThemeData theme) {
    final photo = _displayedPhotos[index];
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
            photos: _displayedPhotos,
            initialIndex: index,
            userAlbums: provider.userAlbums,
            onDelete: (id) {
              provider.deletePhoto(id);
              _loadInitialPhotos();
            },
            onMove: (id, newAlbum) {
              provider.updatePhotoAlbum(id, newAlbum);
              _loadInitialPhotos();
            },
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
