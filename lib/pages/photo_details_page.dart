import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';

class PhotoDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> photos;
  final int initialIndex;
  final List<String> userAlbums;
  final void Function(int id) onDelete;
  final void Function(int id, String newAlbum) onMove;

  const PhotoDetailsPage({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.userAlbums,
    required this.onDelete,
    required this.onMove,
  });

  @override
  State<PhotoDetailsPage> createState() => _PhotoDetailsPageState();
}

class _PhotoDetailsPageState extends State<PhotoDetailsPage> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showOverlay = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _currentPhoto => widget.photos[_currentIndex];

  void _toggleFavorite() {
    setState(() {
      _currentPhoto['isFavorite'] = !(_currentPhoto['isFavorite'] ?? false);
    });
    AuthService.showToast(
      _currentPhoto['isFavorite'] ? 'Added to Favorites' : 'Removed from Favorites',
    );
  }

  void _sharePhoto() {
    final photo = _currentPhoto;
    Share.share(
      'Photo: ${photo['name']}\nAlbum: ${photo['album']}',
    );
  }

  void _movePhoto() {
    String selectedAlbum = _currentPhoto['album'] as String;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Move to Album'),
          content: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              ChoiceChip(
                label: const Text('Default'),
                selected: selectedAlbum == 'Default',
                onSelected: (_) =>
                    setDialogState(() => selectedAlbum = 'Default'),
              ),
              ...widget.userAlbums.map((a) => ChoiceChip(
                    label: Text(a),
                    selected: selectedAlbum == a,
                    onSelected: (_) =>
                        setDialogState(() => selectedAlbum = a),
                  )),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                widget.onMove(_currentPhoto['id'] as int, selectedAlbum);
                Navigator.pop(ctx);
              },
              child: const Text('Move'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Photo'),
        content:
            const Text('Are you sure you want to permanently delete this photo?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final id = _currentPhoto['id'] as int;
              widget.onDelete(id);
              if (widget.photos.length > 1) {
                setState(() {
                  widget.photos.removeAt(_currentIndex);
                  if (_currentIndex >= widget.photos.length) {
                    _currentIndex = widget.photos.length - 1;
                    _pageController.jumpToPage(_currentIndex);
                  }
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showTechnicalDetails() {
    final photo = _currentPhoto;
    final DateTime date = photo['date'] as DateTime;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Image Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow('Title', photo['name'] as String),
            _detailRow('Album', photo['album'] as String),
            _detailRow('Date',
                '${date.day}/${date.month}/${date.year}'),
            _detailRow(
                'Tags',
                (photo['tags'] as String?)?.isNotEmpty == true
                    ? photo['tags']
                    : 'No tags'),
            _detailRow('Storage',
                photo['isLocal'] == true ? 'Local Device' : 'Cloud'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  TextStyle _overlayTextStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.white,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      shadows: const [
        Shadow(offset: Offset(-1, -1), color: Colors.black),
        Shadow(offset: Offset(1, -1), color: Colors.black),
        Shadow(offset: Offset(1, 1), color: Colors.black),
        Shadow(offset: Offset(-1, 1), color: Colors.black),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white,
          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
        ),
        automaticallyImplyLeading: _showOverlay,
        actions: _showOverlay
            ? [
                IconButton(
                  icon: const Icon(Icons.drive_file_move_outlined),
                  onPressed: _movePhoto,
                  tooltip: 'Move',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: _confirmDelete,
                  tooltip: 'Delete',
                ),
              ]
            : null,
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 12) Navigator.pop(context);
        },
        onTap: () => setState(() => _showOverlay = !_showOverlay),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.photos.length,
          onPageChanged: (index) =>
              setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final photo = widget.photos[index];
            final bool isLocal = photo['isLocal'] == true;
            final DateTime date = photo['date'] as DateTime;

            Widget imageWidget(BoxFit fit) => isLocal
                ? Image.file(File(photo['image'] as String), fit: fit)
                : Image.network(photo['image'] as String, fit: fit);

            return Stack(
              fit: StackFit.expand,
              children: [
                // Blurred background
                Positioned.fill(
                  child: Stack(
                    children: [
                      imageWidget(BoxFit.cover),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                            color: Colors.black.withAlpha(100)),
                      ),
                    ],
                  ),
                ),
                // Main image with zoom
                Center(
                  child: Hero(
                    tag: photo['id'] ?? photo['image'],
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: imageWidget(BoxFit.contain),
                    ),
                  ),
                ),
                // Bottom overlay panel
                if (index == _currentIndex)
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    bottom: _showOverlay ? 40 : -350,
                    left: 20,
                    right: 20,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showOverlay ? 1.0 : 0.0,
                      child: GlassContainer(
                        blur: 20,
                        opacity: 0.2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              photo['name'] ?? 'Untitled',
                              style: _overlayTextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.white,
                                    size: 16,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black,
                                          blurRadius: 4)
                                    ]),
                                const SizedBox(width: 6),
                                Text(
                                    '${date.day}/${date.month}/${date.year}',
                                    style:
                                        _overlayTextStyle(fontSize: 13)),
                                const Spacer(),
                                const Icon(Icons.folder_open,
                                    color: Colors.white,
                                    size: 16,
                                    shadows: [
                                      Shadow(
                                          color: Colors.black,
                                          blurRadius: 4)
                                    ]),
                                const SizedBox(width: 6),
                                Text(photo['album'] as String,
                                    style:
                                        _overlayTextStyle(fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                              children: [
                                _buildActionButton(Icons.share, 'Share',
                                    onTap: _sharePhoto),
                                _buildActionButton(
                                  (photo['isFavorite'] ?? false)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  'Favorite',
                                  color: (photo['isFavorite'] ?? false)
                                      ? Colors.redAccent
                                      : Colors.white,
                                  onTap: _toggleFavorite,
                                ),
                                _buildActionButton(
                                    Icons.info_outline, 'Details',
                                    onTap: _showTechnicalDetails),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label, {
    Color color = Colors.white,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: color,
                shadows: const [
                  Shadow(color: Colors.black, blurRadius: 8)
                ]),
            const SizedBox(height: 4),
            Text(label,
                style: _overlayTextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}
