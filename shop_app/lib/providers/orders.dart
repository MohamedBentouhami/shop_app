import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final _url = Uri.https(
      'flutter-update-fdbf8-default-rtdb.europe-west1.firebasedatabase.app',
      '/orders.json');

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double totale) async {
    final timestamp = DateTime.now();
    final response = await http.post(_url,
        body: jsonEncode({
          'amount': totale,
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList(),
          'dateTime': timestamp.toIso8601String()
        }));
    _orders.insert(
        0,
        OrderItem(
            id: jsonDecode(response.body)['name'],
            amount: totale,
            products: cartProducts,
            dateTime: timestamp));
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final response = await http.get(_url);
    final extractedData = jsonDecode(response.body) as Map<String, dynamic>;
    List<OrderItem> loadedOrders = [];
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title']),
              )
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime'])));
    });
    _orders = loadedOrders;
    notifyListeners();
  }
}
