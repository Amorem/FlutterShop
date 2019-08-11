import 'package:flutter/material.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import './product.dart';
import 'dart:convert';

const endpoint = 'https://fluttershop-max.firebaseio.com';

class Products with ChangeNotifier {
  List<Product> _items = [];

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite == true).toList();
  }

  Future<void> fetchProducts() async {
    try {
      final response =
          await http.get('$endpoint/products.json?auth=$authToken');
      final data = json.decode(response.body) as Map<String, dynamic>;
      print(data);
      if (data == null) {
        return;
      }
      final favoriteResponse = await http
          .get('$endpoint/userFavorites/$userId.json?auth=$authToken');
      final favoriteData = json.decode(favoriteResponse.body);
      final List<Product> loadedProducts = [];
      data.forEach((productId, productData) => {
            loadedProducts.add(Product(
                id: productId,
                title: productData['title'],
                description: productData['description'],
                price: productData['price'],
                imageUrl: productData['imageUrl'],
                isFavorite: favoriteData == null
                    ? false
                    : favoriteData[productId] ?? false))
          });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {}
  }

  Future<void> addProduct(Product product) async {
    try {
      final res = await http.post('$endpoint/products.json?auth=$authToken',
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(res.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(Product product) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == product.id);
    if (prodIndex >= 0) {
      await http.patch('$endpoint/products/${product.id}.json?auth=$authToken',
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
          }));
      _items[prodIndex] = product;
      notifyListeners();
    } else {
      print('Error, failed to update product');
    }
  }

  Future<void> deleteProduct(String productId) async {
    // Optimistic Updating
    final existingProductIndex =
        _items.indexWhere((prod) => prod.id == productId);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response =
        await http.delete('$endpoint/products/$productId.json?auth=$authToken');
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('(${response.statusCode}) ${response.reasonPhrase}');
    }
    existingProduct = null;
    notifyListeners();
  }

  Product findById(String id) {
    return [..._items].firstWhere((product) => product.id == id);
  }
}
