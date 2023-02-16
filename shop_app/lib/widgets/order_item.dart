import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' as ord;
import 'package:intl/intl.dart';

class OrderItem extends StatelessWidget {
  final ord.OrderItem order;
  const OrderItem(this.order);
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          ListTile(
            title: Text('${order.amount}€'),
            subtitle: Text(
              DateFormat('dd MM yyyy hh:mm').format(order.dateTime),
            ),
            trailing: const IconButton(
                onPressed: null, icon: Icon(Icons.expand_more)),
          ),
        ],
      ),
    );
  }
}
