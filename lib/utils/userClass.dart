import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
class User extends ChangeNotifier{
  dynamic value;

  void refresh() async {
    var storageKey = await secureStorage.read(key: "authKey");
    if(storageKey == null) return ;
    var accountData = await http.get(getUri("/account"),headers: {"authorization":storageKey});
    this.value = jsonDecode(accountData.body);
    notifyListeners();
  }

  void refreshQuests() async {
    var storageKey = await secureStorage.read(key: "authKey");
    if(storageKey == null) return;
    var accountData = await http.get(getUri("/solo"),headers: {"authorization":storageKey});
    this.value["user"]["solo"] = jsonDecode(accountData.body)["solo"];
    print(this.value["user"]["solo"]);
    notifyListeners();
  }

  User(user){
    this.value = user;
    notifyListeners();
  }
}

Future<dynamic> initUser() async{
  var storageKey = await secureStorage.read(key: "authKey");
  if(storageKey == null) return Future(()=>"no data");
  var data = http.get(getUri("/account"),headers: {"authorization":storageKey});
  return data;
}