import 'package:flutter/material.dart';

class GalleryProvider with ChangeNotifier {
  final List<Map<String, dynamic>> _allPhotos = [];
  final List<String> _userCreatedAlbums = [];

  List<Map<String, dynamic>> get allPhotos => _allPhotos;
  List<String> get userAlbums => _userCreatedAlbums;
  
  // Dynamic Albums List
  List<String> get displayAlbums {
    List<String> albums = List.from(_userCreatedAlbums);
    
    // Check if any photo is liked to show 'Favorites'
    final hasFavorites = _allPhotos.any((p) => p['isFavorite'] == true);
    if (hasFavorites) {
      albums.insert(0, 'Favorites');
    }
    
    return albums;
  }

  // Get photos for a specific album name
  List<Map<String, dynamic>> getPhotosForAlbum(String albumName) {
    if (albumName == 'Favorites') {
      return _allPhotos.where((p) => p['isFavorite'] == true).toList();
    }
    return _allPhotos.where((p) => (p['albums'] as List).contains(albumName)).toList();
  }

  void addPhoto(Map<String, dynamic> photo) {
    // If no album provided, it goes to an internal 'unnamed' storage 
    // that isn't part of the displayAlbums list.
    if (photo['albums'] == null || (photo['albums'] as List).isEmpty) {
      photo['albums'] = <String>['__unnamed__'];
    }
    _allPhotos.insert(0, photo);
    notifyListeners();
  }

  void toggleFavorite(int id) {
    final index = _allPhotos.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      _allPhotos[index]['isFavorite'] = !(_allPhotos[index]['isFavorite'] ?? false);
      notifyListeners();
    }
  }

  void deletePhoto(int id) {
    _allPhotos.removeWhere((p) => p['id'] == id);
    notifyListeners();
  }

  void bulkDelete(List<int> ids) {
    _allPhotos.removeWhere((p) => ids.contains(p['id']));
    notifyListeners();
  }

  void addPhotoToAlbum(int id, String albumName) {
    final index = _allPhotos.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      List<String> albums = List<String>.from(_allPhotos[index]['albums'] ?? []);
      if (!albums.contains(albumName)) {
        // If it was only in unnamed, remove it
        albums.remove('__unnamed__');
        albums.add(albumName);
        _allPhotos[index]['albums'] = albums;
        notifyListeners();
      }
    }
  }

  void removePhotoFromAlbum(int id, String albumName) {
    final index = _allPhotos.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      List<String> albums = List<String>.from(_allPhotos[index]['albums'] ?? []);
      albums.remove(albumName);
      // If now empty, move back to unnamed
      if (albums.isEmpty) albums.add('__unnamed__');
      _allPhotos[index]['albums'] = albums;
      notifyListeners();
    }
  }

  void transferPhoto(int id, String fromAlbum, String toAlbum) {
    final index = _allPhotos.indexWhere((p) => p['id'] == id);
    if (index != -1) {
      List<String> albums = List<String>.from(_allPhotos[index]['albums'] ?? []);
      albums.remove(fromAlbum);
      if (!albums.contains(toAlbum)) albums.add(toAlbum);
      if (albums.isEmpty) albums.add('__unnamed__');
      _allPhotos[index]['albums'] = albums;
      notifyListeners();
    }
  }

  void addAlbum(String name) {
    if (name.toLowerCase() != 'favorites' && !_userCreatedAlbums.contains(name)) {
      _userCreatedAlbums.add(name);
      notifyListeners();
    }
  }

  void deleteAlbum(String name) {
    _userCreatedAlbums.remove(name);
    for (var photo in _allPhotos) {
      List<String> albums = List<String>.from(photo['albums'] ?? []);
      if (albums.contains(name)) {
        albums.remove(name);
        if (albums.isEmpty) albums.add('__unnamed__');
        photo['albums'] = albums;
      }
    }
    notifyListeners();
  }
}
