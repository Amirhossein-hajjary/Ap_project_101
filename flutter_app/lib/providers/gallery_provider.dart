import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class GalleryProvider with ChangeNotifier {
  String _username = '';
  List<Map<String, dynamic>> _allPhotos = [];
  List<Map<String, dynamic>> _rawAlbums = [];
  bool _isLoading = false;
  final Map<int, Uint8List> _imageCache = {};

  List<Map<String, dynamic>> get allPhotos => _allPhotos;
  List<String> get userAlbums => _rawAlbums.map((a) => a['name'] as String).toList();
  List<String> get displayAlbums => userAlbums;
  bool get isLoading => _isLoading;

  void setUsername(String username) {
    _username = username;
  }

  int? _albumIdByName(String name) {
    for (var a in _rawAlbums) {
      if (a['name'] == name) return a['id'] as int;
    }
    return null;
  }

  String _albumNameById(int id) {
    for (var a in _rawAlbums) {
      if (a['id'] == id) return a['name'] as String;
    }
    return '';
  }

  List<String> _albumNamesFromIds(List<dynamic>? ids) {
    if (ids == null) return [];
    return ids.map((id) => _albumNameById(id as int)).where((n) => n.isNotEmpty).toList();
  }

  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    await loadAlbums();
    await loadGallery();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadGallery() async {
    try {
      final response = await SocketService().sendRequest(
        method: 'GET',
        route: '/gallery/list/',
        username: _username,
        payload: {},
      );

      if (response['statusCode'] == 200) {
        final List<dynamic> images = response['payload'] ?? [];
        _allPhotos = images.map<Map<String, dynamic>>((raw) {
          final map = Map<String, dynamic>.from(raw);
          final bool liked = map['liked'] ?? false;
          return {
            'id': map['id'],
            'name': map['name'] ?? '',
            'caption': map['caption'] ?? '',
            'date': DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
            'tags': List<String>.from(map['tags'] ?? []),
            'albums': _albumNamesFromIds(map['albumIds']),
            'albumIds': List<int>.from(map['albumIds'] ?? []),
            'liked': liked,
            'isFavorite': liked,
            'isLocal': false,
            'comments': List<Map<String, dynamic>>.from(
              (map['comments'] as List<dynamic>? ?? [])
                  .map((c) => Map<String, dynamic>.from(c)),
            ),
            'allowComments': map['commentable'] ?? true,
          };
        }).toList();
      }
    } catch (e) {
      debugPrint('Error loading gallery: $e');
    }
    notifyListeners();
  }

  Future<void> loadAlbums() async {
    try {
      final response = await SocketService().sendRequest(
        method: 'GET',
        route: '/album/list/',
        username: _username,
        payload: {},
      );

      if (response['statusCode'] == 200) {
        final List<dynamic> albumsData = response['payload'] ?? [];
        _rawAlbums = albumsData.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('Error loading albums: $e');
    }
    notifyListeners();
  }

  Future<Uint8List?> getImageBytes(int imageId) async {
    if (_imageCache.containsKey(imageId)) return _imageCache[imageId];

    try {
      final response = await SocketService().sendRequest(
        method: 'GET',
        route: '/album/getImage/',
        username: _username,
        payload: {'imageId': imageId},
      );

      if (response['statusCode'] == 200) {
        final String base64Data = response['payload']['base64Data'];
        final bytes = base64Decode(base64Data);
        _imageCache[imageId] = bytes;
        return bytes;
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
    }
    return null;
  }

  Future<bool> addAlbum(String name) async {
    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/album/create/',
        username: _username,
        payload: {'name': name},
      );
      if (response['statusCode'] == 200) {
        await loadAlbums();
        return true;
      }
    } catch (e) {
      debugPrint('Error creating album: $e');
    }
    return false;
  }

  Future<bool> renameAlbum(String oldName, String newName) async {
    final albumId = _albumIdByName(oldName);
    if (albumId == null) return false;

    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/album/rename/',
        username: _username,
        payload: {'albumId': albumId, 'newName': newName},
      );
      if (response['statusCode'] == 200) {
        await loadAlbums();
        await loadGallery();
        return true;
      }
    } catch (e) {
      debugPrint('Error renaming album: $e');
    }
    return false;
  }

  Future<bool> deleteAlbum(String name) async {
    final albumId = _albumIdByName(name);
    if (albumId == null) return false;

    try {
      final response = await SocketService().sendRequest(
        method: 'DELETE',
        route: '/album/delete/',
        username: _username,
        payload: {'albumId': albumId},
      );
      if (response['statusCode'] == 200) {
        await loadAlbums();
        await loadGallery();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting album: $e');
    }
    return false;
  }

  Future<bool> addPhoto(Map<String, dynamic> photoData) async {
    final String base64Data = photoData['base64Data'] ?? '';
    if (base64Data.isEmpty) return false;

    final List<String> albumNames = List<String>.from(photoData['albums'] ?? []);
    final albumIds = albumNames.map((n) => _albumIdByName(n)).whereType<int>().toList();

    final String tagsRaw = photoData['tags'] ?? '';
    final List<String> tagsList = tagsRaw
        .toString()
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/album/upload/',
        username: _username,
        payload: {
          'base64Data': base64Data,
          'name': photoData['name'] ?? 'untitled',
          'caption': photoData['caption'] ?? '',
          'albumIds': albumIds,
          'tags': tagsList,
        },
      );
      if (response['statusCode'] == 200) {
        await loadGallery();
        return true;
      }
    } catch (e) {
      debugPrint('Error uploading photo: $e');
    }
    return false;
  }

  Future<bool> deletePhoto(int imageId) async {
    try {
      final response = await SocketService().sendRequest(
        method: 'DELETE',
        route: '/image/delete/',
        username: _username,
        payload: {'imageId': imageId},
      );
      if (response['statusCode'] == 200) {
        _imageCache.remove(imageId);
        await loadGallery();
        return true;
      }
    } catch (e) {
      debugPrint('Error deleting photo: $e');
    }
    return false;
  }

  Future<void> bulkDelete(List<int> imageIds) async {
    for (var id in imageIds) {
      await deletePhoto(id);
    }
  }

  Future<bool> likePhoto(int imageId, bool liked) async {
    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/image/like/',
        username: _username,
        payload: {'imageId': imageId, 'liked': liked},
      );
      if (response['statusCode'] == 200) {
        final index = _allPhotos.indexWhere((p) => p['id'] == imageId);
        if (index != -1) {
          _allPhotos[index]['liked'] = liked;
          _allPhotos[index]['isFavorite'] = liked;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error liking photo: $e');
    }
    return false;
  }

  Future<bool> addPhotoToAlbum(int imageId, String albumName) async {
    final albumId = _albumIdByName(albumName);
    if (albumId == null) return false;
    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/album/addImageToAlbum/',
        username: _username,
        payload: {'imageId': imageId, 'albumId': albumId},
      );
      if (response['statusCode'] == 200) {
        await loadGallery();
        return true;
      }
    } catch (e) {
      debugPrint('Error adding to album: $e');
    }
    return false;
  }

  Future<bool> removePhotoFromAlbum(int imageId, String albumName) async {
    final albumId = _albumIdByName(albumName);
    if (albumId == null) return false;
    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/album/removeImageFromAlbum/',
        username: _username,
        payload: {'imageId': imageId, 'albumId': albumId},
      );
      if (response['statusCode'] == 200) {
        await loadGallery();
        return true;
      }
    } catch (e) {
      debugPrint('Error removing from album: $e');
    }
    return false;
  }

  Future<bool> updatePhotoAlbums(int imageId, List<String> newAlbumNames) async {
    final photo = _allPhotos.firstWhere((p) => p['id'] == imageId, orElse: () => {});
    if (photo.isEmpty) return false;

    final List<String> oldAlbumNames = List<String>.from(photo['albums'] ?? []);
    final toAdd = newAlbumNames.where((n) => !oldAlbumNames.contains(n));
    final toRemove = oldAlbumNames.where((n) => !newAlbumNames.contains(n));

    bool success = true;
    for (var name in toAdd) {
      if (!await addPhotoToAlbum(imageId, name)) success = false;
    }
    for (var name in toRemove) {
      if (!await removePhotoFromAlbum(imageId, name)) success = false;
    }
    return success;
  }

  Future<void> bulkTransfer(List<int> imageIds, String fromAlbum, String toAlbum) async {
    for (var id in imageIds) {
      await removePhotoFromAlbum(id, fromAlbum);
      await addPhotoToAlbum(id, toAlbum);
    }
  }

  Future<void> bulkMove(List<int> imageIds, String toAlbum) async {
    for (var id in imageIds) {
      final photo = _allPhotos.firstWhere((p) => p['id'] == id, orElse: () => {});
      final currentAlbums = List<String>.from(photo['albums'] ?? []);
      for (var oldAlbum in currentAlbums) {
        await removePhotoFromAlbum(id, oldAlbum);
      }
      await addPhotoToAlbum(id, toAlbum);
    }
  }

  List<Map<String, dynamic>> getPhotosForAlbum(String albumName) {
    return _allPhotos.where((p) => (p['albums'] as List<dynamic>).contains(albumName)).toList();
  }

  Future<bool> addComment(int imageId, String context, {String title = ''}) async {
    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/image/comment/add/',
        username: _username,
        payload: {'imageId': imageId, 'title': title, 'context': context},
      );
      debugPrint('Server response for comment: $response');
      if (response['statusCode'] == 200) {
        final List<dynamic> comments = response['payload'] ?? [];
        final index = _allPhotos.indexWhere((p) => p['id'] == imageId);
        if (index != -1) {
          _allPhotos[index]['comments'] = comments
              .map((c) => Map<String, dynamic>.from(c))
              .toList();
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error submitting comment: $e');
    }
    return false;
  }

  Future<bool> setCommentable(int imageId, bool commentable) async {
    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/image/commentable/set/',
        username: _username,
        payload: {'imageId': imageId, 'commentable': commentable},
      );
      if (response['statusCode'] == 200) {
        final index = _allPhotos.indexWhere((p) => p['id'] == imageId);
        if (index != -1) {
          _allPhotos[index]['allowComments'] = commentable;
        }
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Error changing commentable status: $e');
    }
    return false;
  }
}