import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/pressable.dart';
import '../widgets/glass_container.dart';
import '../themes/app_theme.dart';
import 'photo_details_page.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> allPhotos;
  final List<String> userAlbums;
  final Function(int) onDelete;
  final Function(int, List<String>) onUpdateAlbums;

  const SearchPage({
    super.key,
    required this.allPhotos,
    required this.userAlbums,
    required this.onDelete,
    required this.onUpdateAlbums,
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
          final objects = (p['objects'] as String? ?? '').toLowerCase();
          return title.contains(query.toLowerCase()) || 
                 album.contains(query.toLowerCase()) ||
                 tags.contains(query.toLowerCase()) ||
                 objects.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl, vertical: AppTheme.spacingMd),
      child: GlassContainer(
        borderRadius: AppTheme.radiusLg,
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg, vertical: AppTheme.spacingMd),
        child: Row(
          children: [
            Text('Search', style: theme.textTheme.headlineMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(theme),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
              child: CustomTextField(
                controller: _searchController,
                label: 'Query',
                hint: 'Try "Mountain" or "Nature"',
                icon: Icons.search_rounded,
                validator: null,
                onChanged: _performSearch,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl),
            Expanded(
              child: _searchResults.isEmpty && _searchController.text.isNotEmpty
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: theme.hintColor.withAlpha(80)),
                        const SizedBox(height: AppTheme.spacingLg),
                        Text('No matches found', style: theme.textTheme.titleLarge?.copyWith(color: theme.hintColor)),
                      ],
                    ))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(AppTheme.spacingLg, 0, AppTheme.spacingLg, 120),
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
                                onUpdateAlbums: (id, albums) {
                                  widget.onUpdateAlbums(id, albums);
                                  setState(() {
                                    final idx = _searchResults.indexWhere((p) => p['id'] == id);
                                    if (idx != -1) {
                                      _searchResults[idx]['albums'] = albums;
                                      _searchResults[idx]['album'] = albums.isNotEmpty ? albums.first : '';
                                    }
                                  });
                                },
                              ),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              border: Border.all(color: theme.dividerColor.withAlpha(20)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(AppTheme.spacingSm),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                                child: photo['isLocal'] == true 
                                    ? Image.file(File(photo['image']), width: 60, height: 60, fit: BoxFit.cover)
                                    : Image.network(photo['image'], width: 60, height: 60, fit: BoxFit.cover),
                              ),
                              title: Text(photo['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                (photo['albums'] as List).isNotEmpty 
                                  ? (photo['albums'] as List).join(', ') 
                                  : 'No Album', 
                                style: TextStyle(color: theme.hintColor, fontSize: 12)
                              ),
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
