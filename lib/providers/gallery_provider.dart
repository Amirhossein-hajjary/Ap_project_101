import 'package:flutter/material.dart';

class GalleryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _allPhotos = [];
  final List<String> _userAlbums = [];

  List<Map<String, dynamic>> get allPhotos => _allPhotos;
  List<String> get userAlbums => _userAlbums;

  void addPhoto(Map<String, dynamic> photo) {
    _allPhotos.insert(0, photo);
    notifyListeners();
  }

  void deletePhoto(int id) {
    _allPhotos.removeWhere((p) => p['id'] == id);
    notifyListeners();
  }

  void bulkDelete(List<int> ids) {
    _allPhotos.removeWhere((p) => ids.contains(p['id']));
    notifyListeners();
  }

  void updatePhotoAlbum(int id, String newAlbum) {
    final index = _allPhotos.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      _allPhotos[index]['album'] = newAlbum;
      notifyListeners();
    }
  }

  void bulkMove(List<int> ids, String newAlbum) {
    for (var id in ids) {
      final index = _allPhotos.indexWhere((p) => p['id'] == id);
      if (index != -1) _allPhotos[index]['album'] = newAlbum;
    }
    notifyListeners();
  }

  void addAlbum(String name) {
    if (!_userAlbums.contains(name)) {
      _userAlbums.add(name);
      notifyListeners();
    }
  }
}
