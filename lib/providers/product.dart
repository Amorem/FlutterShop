import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

const endpoint = 'https://fluttershop-max.firebaseio.com';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus(String authToken) async {
    final previousStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.patch(
        '$endpoint/products/$id.json?auth=$authToken',
        body: json.encode({'isFavorite': isFavorite}));
    print(response.reasonPhrase);
    if (response.statusCode >= 400) {
      isFavorite = previousStatus;
      notifyListeners();
      throw HttpException('(${response.statusCode}) ${response.reasonPhrase}');
    }
  }
}
