import 'package:flutter/material.dart';
import '../services/socket_service.dart';

class GalleryProvider with ChangeNotifier {
  List<Map<String, dynamic>> _allPhotos = [];
  List<Map<String, dynamic>> _albums = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get allPhotos => _allPhotos;
  List<Map<String, dynamic>> get albums => _albums;
  bool get isLoading => _isLoading;

  Future<void> loadGallery(String username) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await SocketService().sendRequest(
        method: 'GET',
        route: '/gallery/list/',
        username: username,
        payload: {},
      );

      if (response['statusCode'] == 200) {
        final List<dynamic> images = response['payload'] ?? [];
        _allPhotos = images.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('خطا در دریافت گالری: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadAlbums(String username) async {
    try {
      final response = await SocketService().sendRequest(
        method: 'GET',
        route: '/album/list/',
        username: username,
        payload: {},
      );

      if (response['statusCode'] == 200) {
        final List<dynamic> albumsData = response['payload'] ?? [];
        _albums = albumsData.map((e) => Map<String, dynamic>.from(e)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('خطا در دریافت آلبوم‌ها: $e');
    }
  }

  Future<bool> createAlbum(String username, String name) async {
    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/album/create/',
        username: username,
        payload: {'name': name},
      );

      if (response['statusCode'] == 200) {
        await loadAlbums(username);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطا در ساخت آلبوم: $e');
      return false;
    }
  }

  Future<bool> uploadPhoto({
    required String username,
    required String base64Data,
    required String name,
    required String caption,
    List<int> albumIds = const [],
    List<String> tags = const [],
  }) async {
    try {
      final response = await SocketService().sendRequest(
        method: 'POST',
        route: '/album/upload/',
        username: username,
        payload: {
          'base64Data': base64Data,
          'name': name,
          'caption': caption,
          'albumIds': albumIds,
          'tags': tags,
        },
      );

      if (response['statusCode'] == 200) {
        await loadGallery(username);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('خطا در آپلود عکس: $e');
      return false;
    }
  }
}