import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';

// ignore: use_key_in_widget_constructors
class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushNamed(
            ProductDetailScreen.routeName,
            arguments: product.id,
          );
        },
        child: GridTile(
          footer: GridTileBar(
            backgroundColor: Colors.black87,
            leading: Consumer<Product>(
                builder: (ctx, product, child) => IconButton(
                      onPressed: () {
                        product.toggleFavoriteStatus(authData.token as String,
                            authData.userId as String);
                      },
                      icon: Icon(product.isFavorite
                          ? Icons.favorite_border
                          : Icons.favorite),
                      color: Theme.of(context).colorScheme.secondary,
                    )),
            title: Text(
              product.title,
              textAlign: TextAlign.center,
            ),
            trailing: IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                cart.addItem(
                    product.id as String, product.price, product.title);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: const Text(
                    'Added item to cart',
                    textAlign: TextAlign.center,
                  ),
                  duration: const Duration(seconds: 1),
                  action: SnackBarAction(
                    label: 'UNDO',
                    onPressed: () {
                      cart.removeSingleItem(product.id as String);
                    },
                  ),
                ));
              },
              icon: const Icon(Icons.shopping_cart),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
