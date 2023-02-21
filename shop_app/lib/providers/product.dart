import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite = false;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final url = Uri.https(
        'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
        '/userFavorites/$userId/$id.json',
        {'auth': token});
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(url, body: jsonEncode(isFavorite));
      if (response.statusCode >= 400) {
        _setFavValue(!isFavorite);
      }
    } catch (error) {
      _setFavValue(!isFavorite);
    }
  }

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }
}
