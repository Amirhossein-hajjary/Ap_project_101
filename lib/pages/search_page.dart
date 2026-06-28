import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/pressable.dart';
import 'photo_details_page.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> allPhotos;
  final List<String> userAlbums;
  final Function(int) onDelete;
  final Function(int, String) onMove;

  const SearchPage({
    super.key,
    required this.allPhotos,
    required this.userAlbums,
    required this.onDelete,
    required this.onMove,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];

  void _performSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _searchResults = [];
      } else {
        _searchResults = widget.allPhotos.where((p) {
          final title = (p['name'] as String).toLowerCase();
          final album = (p['album'] as String).toLowerCase();
          final tags = (p['tags'] as String? ?? '').toLowerCase();
          return title.contains(query.toLowerCase()) || 
                 album.contains(query.toLowerCase()) ||
                 tags.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Row(
                children: [
                  Text('Search', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomTextField(
                controller: _searchController,
                label: 'Search Gallery',
                hint: 'Try "Mountain" or "Nature"',
                icon: Icons.search_rounded,
                validator: null,
                onChanged: _performSearch,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.withAlpha(100)),
                        const SizedBox(height: 16),
                        Text('No matches found', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                      ],
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final photo = _searchResults[index];
                        return Pressable(
                          onTap: () => Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (_) => PhotoDetailsPage(
                                photos: _searchResults,
                                initialIndex: index,
                                userAlbums: widget.userAlbums,
                                onDelete: (id) {
                                  widget.onDelete(id);
                                  setState(() {
                                    _searchResults.removeWhere((p) => p['id'] == id);
                                  });
                                },
                                onMove: (id, newAlbum) {
                                  widget.onMove(id, newAlbum);
                                  setState(() {
                                    final idx = _searchResults.indexWhere((p) => p['id'] == id);
                                    if (idx != -1) _searchResults[idx]['album'] = newAlbum;
                                  });
                                },
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withAlpha(20)),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(8),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: photo['isLocal'] == true 
                                    ? Image.file(File(photo['image']), width: 60, height: 60, fit: BoxFit.cover)
                                    : Image.network(photo['image'], width: 60, height: 60, fit: BoxFit.cover),
                              ),
                              title: Text(photo['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(photo['album'], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                              trailing: Icon(Icons.chevron_right_rounded, color: theme.primaryColor),
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
}
