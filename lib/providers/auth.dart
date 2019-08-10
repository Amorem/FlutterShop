import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum AuthMode { Signup, Login }
const googleApiKey = "AIzaSyBSHWLq2rjhEI2aj4LilDWmh5GlUYKvkAk";
const endPoint = "https://identitytoolkit.googleapis.com/v1/accounts:";

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

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
    print(json.decode(response.body));
  }
}
