import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../widgets/glass_container.dart';
import '../services/auth_service.dart';
import '../providers/gallery_provider.dart';
import '../widgets/photo_image.dart';

class PhotoDetailsPage extends StatefulWidget {
  final List<Map<String, dynamic>> photos;
  final int initialIndex;
  final List<String> userAlbums;
  final Function(int id) onDelete;
  final Function(int id, List<String> albums) onUpdateAlbums;

  const PhotoDetailsPage({
    super.key,
    required this.photos,
    required this.initialIndex,
    required this.userAlbums,
    required this.onDelete,
    required this.onUpdateAlbums,
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
    _initializeSocialData();
  }

  void _initializeSocialData() {
    for (var photo in widget.photos) {
      photo['captions'] ??= [];
      photo['comments'] ??= [];
      photo['allowComments'] ??= true;
      photo['albums'] ??= [photo['album'] ?? 'Default'];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    final photo = widget.photos[_currentIndex];
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    final newState = !(photo['isFavorite'] ?? false);
    provider.likePhoto(photo['id'] as int, newState);
    setState(() {
      photo['isFavorite'] = newState;
      photo['liked'] = newState;
    });
    AuthService.showToast(newState ? 'Added to Favorites' : 'Removed from Favorites');
  }

  void _sharePhoto() {
    final photo = widget.photos[_currentIndex];
    final String content = 'Check out this photo: ${photo['name']}\nAlbums: ${(photo['albums'] as List).join(', ')}';
    Share.share(content);
  }

  void _manageAlbums() {
    final photo = widget.photos[_currentIndex];
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    final allAvailableAlbums = ['Default', ...provider.userAlbums];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Manage Photo Albums'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('An image can exist in multiple albums simultaneously.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: allAvailableAlbums.length,
                    itemBuilder: (context, index) {
                      final albumName = allAvailableAlbums[index];
                      final bool isInAlbum = (photo['albums'] as List).contains(albumName);

                      return CheckboxListTile(
                        title: Text(albumName),
                        value: isInAlbum,
                        onChanged: (val) {
                          setDialogState(() {
                            if (val == true) {
                              provider.addPhotoToAlbum(photo['id'], albumName);
                            } else {
                              if ((photo['albums'] as List).length > 1) {
                                provider.removePhotoFromAlbum(photo['id'], albumName);
                              } else {
                                AuthService.showToast('At least one album is required', isError: true);
                              }
                            }
                          });
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done')),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo permanently from all albums?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final idToDelete = widget.photos[_currentIndex]['id'] as int;
              widget.onDelete(idToDelete);
              if (widget.photos.length > 1) {
                setState(() {
                  widget.photos.removeAt(_currentIndex);
                  if (_currentIndex >= widget.photos.length) {
                    _currentIndex = widget.photos.length - 1;
                  }
                });
              } else {
                Navigator.pop(context);
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showSocialAndDetails() {
    final photo = widget.photos[_currentIndex];
    final provider = Provider.of<GalleryProvider>(context, listen: false);
    final TextEditingController commentController = TextEditingController();
    final TextEditingController captionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => GlassContainer(
          borderRadius: 32,
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Social & Info', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Allow Comments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Switch(
                              value: photo['allowComments'],
                              onChanged: (val) async {
                                final success = await provider.setCommentable(photo['id'] as int, val);
                                if (success) {
                                  setModalState(() => photo['allowComments'] = val);
                                  setState(() {});
                                } else {
                                  AuthService.showToast('Error changing commentable status', isError: true);
                                }
                              },
                              activeTrackColor: Theme.of(context).primaryColor.withAlpha(150),
                              activeThumbColor: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text('Captions', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        ...(photo['captions'] as List).map((c) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $c', style: const TextStyle(color: Colors.white70)),
                        )),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: captionController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Add a caption...',
                                  hintStyle: TextStyle(color: Colors.white38),
                                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                              onPressed: () {
                                if (captionController.text.isNotEmpty) {
                                  setModalState(() {
                                    photo['captions'].add(captionController.text);
                                    captionController.clear();
                                  });
                                  setState(() {});
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        const Text('Comments', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (!photo['allowComments'])
                          const Text('Comments are disabled for this image.', style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic))
                        else ...[
                          if ((photo['comments'] as List).isEmpty)
                            const Text('No comments yet.', style: TextStyle(color: Colors.white38, fontStyle: FontStyle.italic)),
                          ...(photo['comments'] as List).map((c) {
                            final comment = c as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((comment['title'] ?? '').toString().isNotEmpty)
                                    Text(comment['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                  Text(comment['context'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                ],
                              ),
                            );
                          }),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: commentController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    hintText: 'Add a comment...',
                                    hintStyle: TextStyle(color: Colors.white38),
                                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.send_rounded, color: Colors.white),
                                onPressed: () async {
                                  final text = commentController.text;
                                  if (text.isNotEmpty) {
                                    final success = await provider.addComment(photo['id'] as int, text);
                                    if (success) {
                                      setModalState(() {
                                        photo['comments'] = provider.allPhotos
                                            .firstWhere((p) => p['id'] == photo['id'])['comments'];
                                        commentController.clear();
                                      });
                                      setState(() {});
                                    } else {
                                      AuthService.showToast('Error submitting comment', isError: true);
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTechnicalDetails() {
    final photo = widget.photos[_currentIndex];
    final DateTime date = photo['date'];
    
    String tagsString = 'No tags';
    if (photo['tags'] is List) {
      tagsString = (photo['tags'] as List).join(', ');
    } else if (photo['tags'] is String && photo['tags'].toString().isNotEmpty) {
      tagsString = photo['tags'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Technical Info'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('Title', photo['name'] ?? 'Untitled'),
              _detailRow('Albums', (photo['albums'] as List).join(', ')),
              _detailRow('Upload Date', '${date.day}/${date.month}/${date.year}'),
              _detailRow('Tags', tagsString),
              _detailRow('Storage', 'Cloud Server'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, height: 1.5),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  TextStyle _outlinedTextStyle({double fontSize = 14, FontWeight fontWeight = FontWeight.normal, Color color = Colors.white}) {
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
        actions: _showOverlay ? [
          IconButton(
            icon: const Icon(Icons.folder_shared_outlined, color: Colors.white),
            onPressed: _manageAlbums,
          ),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.white), onPressed: _confirmDelete),
        ] : null,
      ),
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 10) Navigator.pop(context);
        },
        onTap: () => setState(() => _showOverlay = !_showOverlay),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.photos.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final photo = widget.photos[index];
            final DateTime date = photo['date'];

            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned.fill(
                  child: Stack(
                    children: [
                      PhotoImage(imageId: photo['id'] as int),
                      BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(color: Colors.black.withAlpha(100)),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Hero(
                    tag: photo['id'],
                    child: InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: PhotoImage(imageId: photo['id'] as int, fit: BoxFit.contain),
                    ),
                  ),
                ),

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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(photo['name'] ?? 'Untitled', 
                              style: _outlinedTextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.white, size: 14, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                                const SizedBox(width: 4),
                                Text('${date.day}/${date.month}/${date.year}', style: _outlinedTextStyle(fontSize: 12)),
                                const Spacer(),
                                const Icon(Icons.folder_open, color: Colors.white, size: 14, shadows: [Shadow(color: Colors.black, blurRadius: 4)]),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    (photo['albums'] as List).join(', '), 
                                    style: _outlinedTextStyle(fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildActionButton(Icons.share, 'Share', onTap: _sharePhoto),
                                  _buildActionButton(
                                    (photo['isFavorite'] ?? false) ? Icons.favorite : Icons.favorite_border,
                                    'Favorite',
                                    color: (photo['isFavorite'] ?? false) ? Colors.redAccent : Colors.white,
                                    onTap: _toggleFavorite,
                                  ),
                                  _buildActionButton(Icons.forum_outlined, 'Social', onTap: _showSocialAndDetails),
                                  _buildActionButton(Icons.info_outline, 'Technical', onTap: _showTechnicalDetails),
                                ],
                              ),
                            )
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

  Widget _buildActionButton(IconData icon, String label, {Color color = Colors.white, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22, shadows: const [Shadow(color: Colors.black, blurRadius: 8)]),
            const SizedBox(height: 4),
            Text(label, style: _outlinedTextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}