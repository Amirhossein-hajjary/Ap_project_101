import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Search Gallery')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search',
              hint: 'Search by title, album or tags...',
              icon: Icons.search,
              validator: null,
              onChanged: _performSearch,
            ),
          ),
          Expanded(
            child: _searchResults.isEmpty && _searchController.text.isNotEmpty
                ? const Center(child: Text('No results found'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final photo = _searchResults[index];
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: photo['isLocal'] == true 
                              ? Image.file(File(photo['image']), width: 50, height: 50, fit: BoxFit.cover)
                              : Image.network(photo['image'], width: 50, height: 50, fit: BoxFit.cover),
                        ),
                        title: Text(photo['name']),
                        subtitle: Text(photo['album']),
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
