import 'package:flutter/material.dart';
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
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double totale) {
    //insert(0,..) : insert at the begin of the list.
    _orders.insert(
        0,
        OrderItem(
            id: DateTime.now().toString(),
            amount: totale,
            products: cartProducts,
            dateTime: DateTime.now()));
    notifyListeners();
  }
}
