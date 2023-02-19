import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items =
      []; /* = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ]; */
  final _url = Uri.https(
      'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
      '/products.json');

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoritesItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.https(
        'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
        '/products.json');
    try {
      final response = await http.get(url);
      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, productData) {
        loadedProducts.add(Product(
          id: prodId,
          title: productData['title'],
          description: productData['description'],
          price: double.parse(productData['price']),
          imageUrl: productData['imageUrl'],
          isFavorite: toBoolean(productData['isFavorite']),
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(_url,
          body: jsonEncode(<String, String>{
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price.toString(),
            'isFavorite': product.isFavorite.toString()
          }));
      final newProduct = Product(
        id: jsonDecode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Product findById(String idProduct) {
    return items.firstWhere((item) => item.id == idProduct);
  }

  Future<void> updateProduct(String idProduct, Product newProduct) async {
    final productIndex = _items.indexWhere((prod) => prod.id == idProduct);
    if (productIndex >= 0) {
      var url = Uri.https(
          'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
          '/products/$idProduct/.json');
      try {
        await http.patch(url,
            body: jsonEncode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price.toString(),
              'isFavorite': newProduct.isFavorite.toString()
            }));
        _items[productIndex] = newProduct;
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> removeProduct(String idProduct) async {
    final url = Uri.https(
        'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$idProduct.json');
    final existingProductIndex =
        _items.indexWhere((product) => product.id == idProduct);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }

  bool toBoolean(String value) {
    return value == 'true';
  }
}
