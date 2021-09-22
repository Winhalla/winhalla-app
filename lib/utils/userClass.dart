import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
final httpClient = http.Client();
Uri getUri (String path,){
  return Uri.parse("http://192.168.1.33:3001"+path);
}
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