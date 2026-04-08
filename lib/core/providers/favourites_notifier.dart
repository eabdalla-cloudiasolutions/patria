import 'package:flutter/material.dart';

class FavouritesNotifier extends ChangeNotifier {
  final List<Map<String, String>> _favourites = [];

  List<Map<String, String>> get favourites => List.unmodifiable(_favourites);

  bool isFav(String name) => _favourites.any((p) => p['name'] == name);

  void toggle(Map<String, String> product) {
    if (isFav(product['name']!)) {
      _favourites.removeWhere((p) => p['name'] == product['name']);
    } else {
      _favourites.add(product);
    }
    notifyListeners();
  }
}
