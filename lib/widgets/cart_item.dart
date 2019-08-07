import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;

  CartItem(this.id, this.productId, this.price, this.quantity, this.title);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      background: Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 40),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
          color: Theme.of(context).errorColor,
          child: Icon(Icons.delete, color: Colors.white, size: 40)),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: Chip(
              label: Text(
                '\$ $price',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).primaryTextTheme.title.color),
              ),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            title: Text(title),
            subtitle: Text('Total: \$ ${(price * quantity)}'),
            trailing: Text('x $quantity'),
          ),
        ),
      ),
    );
  }
}
