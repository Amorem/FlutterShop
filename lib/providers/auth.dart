import 'package:flutter/widgets.dart';
import '../models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum AuthMode { Signup, Login }
const googleApiKey = "AIzaSyBSHWLq2rjhEI2aj4LilDWmh5GlUYKvkAk";
const endPoint = "https://identitytoolkit.googleapis.com/v1/accounts:";

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
  }

  String get userId {
    return _userId;
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, AuthMode.Signup);
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, AuthMode.Login);
  }

  Future<void> _authenticate(String email, String password, authMode) async {
    var url = "";
    if (authMode == AuthMode.Login) {
      url = '${endPoint}signInWithPassword?key=$googleApiKey';
    }
    if (authMode == AuthMode.Signup) {
      url = '${endPoint}signUp?key=$googleApiKey';
    }
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      var data = json.decode(response.body);
      if (data['error'] != null) {
        throw HttpException(data['error']['message']);
      }
      _token = data['idToken'];
      _userId = data['localId'];
      _expiryDate = DateTime.now().add(
        Duration(seconds: int.parse(data['expiresIn'])),
      );
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }
}
