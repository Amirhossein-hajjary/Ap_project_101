import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import '../themes/theme_provider.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import 'photo_details_page.dart';
import 'search_page.dart';
import 'profile_page.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();
  
  // State variables
  String _selectedAlbum = 'All';
  String _sortBy = 'Date';
  bool _showOnlyFavorites = false;
  bool _isSelectionMode = false;
  final Set<int> _selectedIndices = {};
  bool _isLoadingMore = false;

  // Albums management (Only 'All' is fixed)
  final List<String> _userAlbums = []; 

  // Empty initial photos list
  final List<Map<String, dynamic>> _allPhotos = [];

  List<Map<String, dynamic>> _displayedPhotos = [];
  final int _pageSize = 21;

  @override
  void initState() {
    super.initState();
    _loadInitialPhotos();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialPhotos() {
    setState(() {
      _displayedPhotos = _filteredAndSortedPhotos.take(_pageSize).toList();
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100 &&
        !_isLoadingMore &&
        _displayedPhotos.length < _filteredAndSortedPhotos.length) {
      _loadMorePhotos();
    }
  }

  Future<void> _loadMorePhotos() async {
    setState(() => _isLoadingMore = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() {
        int nextBatchSize = _displayedPhotos.length + _pageSize;
        _displayedPhotos = _filteredAndSortedPhotos.take(nextBatchSize).toList();
        _isLoadingMore = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredAndSortedPhotos {
    List<Map<String, dynamic>> list = List.from(_allPhotos);
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

  Future<void> _pickImage(ImageSource source, {String album = 'Default'}) async {
    try {
      final XFile? file = await _picker.pickImage(source: source);
      if (file != null) {
        setState(() {
          final newPhoto = {
            'id': DateTime.now().millisecondsSinceEpoch,
            'name': 'Photo ${DateTime.now().second}',
            'image': file.path,
            'album': album,
            'date': DateTime.now(),
            'isLocal': true,
            'isFavorite': false,
            'tags': '',
          };
          _allPhotos.insert(0, newPhoto);
          _loadInitialPhotos();
        });
        AuthService.showToast('Photo uploaded to $album');
      }
    } catch (e) {
      AuthService.showToast('Failed to pick image', isError: true);
    }
  }

  void _createNewAlbum() {
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
              if (controller.text.isNotEmpty && !_userAlbums.contains(controller.text)) {
                setState(() {
                  _userAlbums.add(controller.text);
                });
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

  void _deleteSinglePhoto(int id) {
    setState(() {
      _allPhotos.removeWhere((p) => p['id'] == id);
      _displayedPhotos.removeWhere((p) => p['id'] == id);
    });
    AuthService.showToast('Photo deleted');
  }

  void _updatePhotoAlbum(int id, String newAlbum) {
    setState(() {
      final indexInAll = _allPhotos.indexWhere((p) => p['id'] == id);
      if (indexInAll != -1) {
        _allPhotos[indexInAll]['album'] = newAlbum;
      }
      _loadInitialPhotos();
    });
    AuthService.showToast('Photo moved to $newAlbum');
  }

  void _bulkMoveToAlbum() {
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
              ..._userAlbums.map((a) => ChoiceChip(
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
                setState(() {
                  List<int> idsToMove = _selectedIndices.map((i) => _displayedPhotos[i]['id'] as int).toList();
                  for (var id in idsToMove) {
                    final pIndex = _allPhotos.indexWhere((p) => p['id'] == id);
                    if (pIndex != -1) _allPhotos[pIndex]['album'] = selectedMoveAlbum;
                  }
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
    String selectedTargetAlbum = 'Default';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GlassContainer(
          borderRadius: 30,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Upload Photo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                const Text('Select Album:', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Default'),
                      selected: selectedTargetAlbum == 'Default',
                      onSelected: (v) => setModalState(() => selectedTargetAlbum = 'Default'),
                    ),
                    ..._userAlbums.map((a) => ChoiceChip(
                      label: Text(a),
                      selected: selectedTargetAlbum == a,
                      onSelected: (v) => setModalState(() => selectedTargetAlbum = a),
                    )),
                  ],
                ),
                const Divider(height: 30),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Pick from Gallery'),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery, album: selectedTargetAlbum); },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Capture with Camera'),
                  onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera, album: selectedTargetAlbum); },
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

    return Scaffold(
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
          child: Column(
            children: [
              _buildHeader(themeProvider, theme),
              if (_isSelectionMode) _buildSelectionToolbar(theme),
              _buildFilterBar(theme),
              _buildAlbumSelector(),
              Expanded(
                child: _displayedPhotos.isEmpty 
                  ? _buildEmptyState(theme)
                  : GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(2),
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
      floatingActionButton: _isSelectionMode ? null : FloatingActionButton(
        backgroundColor: theme.primaryColor,
        onPressed: _showAddOptions,
        child: const Icon(Icons.add_a_photo, color: Colors.white),
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
          Text('Start by adding your first photo', style: TextStyle(color: theme.hintColor.withAlpha(150))),
        ],
      ),
    );
  }

  Widget _buildHeader(ThemeProvider provider, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfilePage(totalPhotos: _allPhotos.length, totalAlbums: _userAlbums.length))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gallery', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                  Text('Tap to view profile', style: TextStyle(fontSize: 13, color: theme.textTheme.bodyMedium?.color?.withAlpha(150))),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SearchPage(
                  allPhotos: _allPhotos,
                  userAlbums: _userAlbums,
                  onDelete: (id) => _deleteSinglePhoto(id),
                  onMove: (id, newAlbum) => _updatePhotoAlbum(id, newAlbum),
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(provider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleTheme(!provider.isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionToolbar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withAlpha(30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withAlpha(60)),
      ),
      child: Row(
        children: [
          Text('${_selectedIndices.length} selected', style: TextStyle(fontWeight: FontWeight.bold, color: theme.primaryColor)),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.drive_file_move_outlined, size: 20),
            onPressed: _bulkMoveToAlbum,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: () {
              final List<String> paths = _selectedIndices.map((i) => _displayedPhotos[i]['image'] as String).toList();
              Share.share('Check out these photos: ${paths.join(', ')}');
              setState(() { _selectedIndices.clear(); _isSelectionMode = false; });
            }
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: () {
              setState(() {
                List<int> idsToRemove = _selectedIndices.map((i) => _displayedPhotos[i]['id'] as int).toList();
                _allPhotos.removeWhere((p) => idsToRemove.contains(p['id']));
                _displayedPhotos.removeWhere((p) => idsToRemove.contains(p['id']));
                _selectedIndices.clear();
                _isSelectionMode = false;
              });
              AuthService.showToast('Selected photos deleted');
            },
          ),
          IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => setState(() { _selectedIndices.clear(); _isSelectionMode = false; })),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(
        children: [
          DropdownButton<String>(
            value: _sortBy,
            underline: const SizedBox(),
            items: ['Date', 'Name'].map((s) => DropdownMenuItem(value: s, child: Text('Sort: $s', style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (val) => setState(() { _sortBy = val!; _loadInitialPhotos(); }),
          ),
          const Spacer(),
          FilterChip(
            label: const Text('Favorites', style: TextStyle(fontSize: 12)),
            selected: _showOnlyFavorites,
            onSelected: (val) => setState(() { _showOnlyFavorites = val; _loadInitialPhotos(); }),
            selectedColor: theme.primaryColor.withAlpha(50),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumSelector() {
    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 'All' Filter
          _buildAlbumChip('All', isFixed: true),
          
          // User created albums
          ..._userAlbums.map((a) => _buildAlbumChip(a)),
          
          // Add Album Button
          GestureDetector(
            onTap: _createNewAlbum,
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: const Icon(Icons.add, size: 18, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumChip(String title, {bool isFixed = false}) {
    final isSelected = _selectedAlbum == title;
    return GestureDetector(
      onTap: () => setState(() { _selectedAlbum = title; _loadInitialPhotos(); }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.white.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withAlpha(40)),
        ),
        child: Center(
          child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.grey, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ),
      ),
    );
  }

  Widget _buildPhotoCard(int index, ThemeData theme) {
    final photo = _displayedPhotos[index];
    final bool isSelected = _selectedIndices.contains(index);
    return InkWell(
      onLongPress: () => setState(() { _selectedIndices.add(index); _isSelectionMode = true; }),
      onTap: () {
        if (_isSelectionMode) {
          setState(() { 
            if (_selectedIndices.contains(index)) {
              _selectedIndices.remove(index);
            } else {
              _selectedIndices.add(index);
            }
            if (_selectedIndices.isEmpty) {
              _isSelectionMode = false;
            }
          });
        } else {
          Navigator.push(context, MaterialPageRoute(builder: (_) => PhotoDetailsPage(
            photos: _displayedPhotos,
            initialIndex: index,
            userAlbums: _userAlbums,
            onDelete: (id) => _deleteSinglePhoto(id),
            onMove: (id, newAlbum) => _updatePhotoAlbum(id, newAlbum),
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
          if (isSelected) Positioned.fill(child: Container(color: theme.primaryColor.withAlpha(100), child: const Icon(Icons.check_circle, color: Colors.white, size: 30))),
          if (photo['isFavorite'] == true) const Positioned(top: 4, right: 4, child: Icon(Icons.favorite, color: Colors.redAccent, size: 14)),
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
