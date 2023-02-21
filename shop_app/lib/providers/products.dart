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

  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoritesItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Future<void> fetchAndSetProducts([filterByUser = false]) async {
    var param = {
      'auth': authToken,
    };
    if (filterByUser) {
      param['orderBy'] = jsonEncode("creatorId");
      param['equalTo'] = jsonEncode(userId);
    }
    var url = Uri.https(
        'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
        '/products.json',
        param);

    try {
      final response = await http.get(url);

      final extractedData = jsonDecode(response.body) as Map<String, dynamic>;

      if (extractedData == null) {
        return;
      }
      url = Uri.https(
          'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
          '/userFavorites/$userId.json',
          {'auth': authToken});
      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);

      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, productData) {
        loadedProducts.add(Product(
          id: prodId,
          title: productData['title'],
          description: productData['description'],
          price: productData['price'],
          imageUrl: productData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
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
      final url = Uri.https(
          'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
          '/products.json',
          {'auth': authToken});

      final response = await http.post(url,
          body: jsonEncode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
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

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
          'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
          '/products/$id.json',
          {'auth': authToken});
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> removeProduct(String idProduct) async {
    final url = Uri.https(
        'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
        '/products/$idProduct.json',
        {'auth': authToken});
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
}
