import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';

class User extends ChangeNotifier {
  dynamic value;
  dynamic shop;

  void refresh() async {
    var storageKey = await secureStorage.read(key: "authKey");
    if (storageKey == null) return;
    var accountData = await http.get(getUri("/account"), headers: {"authorization": storageKey});
    this.value = jsonDecode(accountData.body);
    notifyListeners();
  }

  Future<void> refreshQuests() async {
    var storageKey = await secureStorage.read(key: "authKey");
    if (storageKey == null) return;
    var accountData = await http.get(getUri("/solo"), headers: {"authorization": storageKey});
    this.value["user"]["solo"] = jsonDecode(accountData.body)["solo"];
    notifyListeners();
  }

  Future<String> enterMatch() async {
    String matchId;
    try {
      matchId = this.value["user"]["inGame"].firstWhere((x) => x["isFinished"] == false)["id"];
    } catch (e) {
      // Find new match;
      matchId = jsonDecode(
          (await http.get(getUri("/lobby"), headers: {"authorization": this.value["authKey"]})).body);
    }
    this.value["user"]["inGame"].add({
      "id": matchId,
      "type": "Solo",
      "isFinished": false,
      "Date": DateTime.now().millisecondsSinceEpoch,
      "progress": 0
    });
    notifyListeners();
    return matchId;
  }

  User(user) {
    this.value = user;
    notifyListeners();
  }

  void setShopDataTo(shopData) {
    this.shop = shopData;
  }
  void addCoins(coins){
    this.value["user"]["coins"] += coins;
    notifyListeners();
  }
}

Future<dynamic> initUser() async {
  var storageKey = await secureStorage.read(key: "authKey");
  if (storageKey == null) return Future(() => "no data");
  var data = await http.get(getUri("/account"), headers: {"authorization": storageKey});
  return {"data": data, "authKey": storageKey};
}
