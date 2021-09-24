import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
class User extends ChangeNotifier{
  dynamic value;

  void refresh() async {
    this.value = await http.get(getUri("/account"));
    notifyListeners();
  }

  User(userData){
    this.value = userData;
    notifyListeners();
  }
}