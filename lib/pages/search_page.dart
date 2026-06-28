import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import 'photo_details_page.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> allPhotos;
  final List<String> userAlbums;
  final void Function(int) onDelete;
  final void Function(int, String) onMove;

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
  bool _hasSearched = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      _hasSearched = trimmed.isNotEmpty;
      if (trimmed.isEmpty) {
        _searchResults = [];
        return;
      }
      _searchResults = widget.allPhotos.where((p) {
        final name = (p['name'] as String).toLowerCase();
        final album = (p['album'] as String).toLowerCase();
        final tags = (p['tags'] as String? ?? '').toLowerCase();
        return name.contains(trimmed) ||
            album.contains(trimmed) ||
            tags.contains(trimmed);
      }).toList();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _performSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: CustomTextField(
              controller: _searchController,
              label: 'Search Photos',
              hint: 'Search by name, album, or tag...',
              icon: Icons.search,
              validator: null,
              onChanged: _performSearch,
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
          if (_hasSearched)
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_searchResults.length} result(s)',
                  style: TextStyle(
                      fontSize: 13, color: theme.hintColor),
                ),
              ),
            ),
          Expanded(
            child: _hasSearched && _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off,
                            size: 64,
                            color: theme.hintColor.withAlpha(100)),
                        const SizedBox(height: 12),
                        const Text('No results found',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : !_hasSearched
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_search,
                                size: 64,
                                color: theme.hintColor.withAlpha(80)),
                            const SizedBox(height: 12),
                            Text('Search your gallery',
                                style: TextStyle(
                                    fontSize: 16,
                                    color: theme.hintColor)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final photo = _searchResults[index];
                          final date =
                              photo['date'] as DateTime;
                          return Card(
                            margin:
                                const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8),
                                child: photo['isLocal'] == true
                                    ? Image.file(
                                        File(photo['image']
                                            as String),
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        photo['image'] as String,
                                        width: 52,
                                        height: 52,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                              title: Text(photo['name'] as String),
                              subtitle: Text(
                                '${photo['album']}  •  ${date.day}/${date.month}/${date.year}',
                                style: const TextStyle(fontSize: 12),
                              ),
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
                                        _searchResults.removeWhere(
                                            (p) => p['id'] == id);
                                      });
                                    },
                                    onMove: (id, newAlbum) {
                                      widget.onMove(id, newAlbum);
                                      setState(() {
                                        final idx =
                                            _searchResults.indexWhere(
                                                (p) => p['id'] == id);
                                        if (idx != -1) {
                                          _searchResults[idx]
                                              ['album'] = newAlbum;
                                        }
                                      });
                                    },
                                  ),
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
