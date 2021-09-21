import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class User extends ChangeNotifier{
  dynamic value;
  void refresh() async {
    Future<dynamic> = http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1'));
    this.value = await "";
    notifyListeners();
  }
  User(userData){
    this.value = userData;
  }
}