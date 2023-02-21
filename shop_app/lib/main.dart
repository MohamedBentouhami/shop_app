import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/products_overview_screen.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';
import '../screens/edit_product_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';

import './screens/product_detail_screen.dart';
import './screens/cart_screen.dart';
import './providers/products.dart';
import './screens/auth_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            create: (ctx) => Products('', '', []),
            update: (ctx, auth, previousProducts) => Products(
                auth.token!,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProvider(
            create: (context) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('', []),
            update: (context, auth, previousOrders) => Orders(auth.token!,
                previousOrders == null ? [] : previousOrders.orders),
          )
        ],
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'MyShop',
            theme: ThemeData(
                colorScheme: ColorScheme.fromSwatch().copyWith(
                  primary: Colors.purple,
                  secondary: Colors.deepOrange,
                ),
                fontFamily: 'Lato'),
            home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              //AuthScreen.routeName: (ctx) => AuthScreen(),
            },
          ),
        ));
  }
}
