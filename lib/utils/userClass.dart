import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/widgets/infoDropdown.dart';

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

  Future<void> refreshQuests(BuildContext context, {bool showInfo: false}) async {
    var storageKey = await secureStorage.read(key: "authKey");
    if (storageKey == null) return;
    var accountData = await http.get(getUri("/solo"), headers: {"authorization": storageKey});
    this.value["user"]["solo"] = jsonDecode(accountData.body)["solo"];
    if (showInfo)
      showInfoDropdown(context, kPrimary, "Data updated",
          timeShown:2000,
          body: Row(
            children: [
              Image.asset(
                "assets/images/icons/phone.png",
                height: 35,
              ),
              SizedBox(
                width: 10,
              ),
              Image.asset(
                "assets/images/icons/steam.png",
                width: 35,
              ),
            ],
          ));
    notifyListeners();
  }

  Future<String> enterMatch() async {
    print(this.value["authKey"]);
    String matchId;
    // Find new match;
    matchId = jsonDecode(
        (await http.get(getUri("/lobby"), headers: {"authorization": this.value["authKey"]})).body);
    var accountData = await http.get(getUri("/account"), headers: {"authorization": this.value["authKey"]});
    var accountDataParsed = jsonDecode(accountData.body);
    this.value["user"] = accountDataParsed["user"];
    this.value["steam"] = accountDataParsed["steam"];
    return matchId;
  }

  User(user) {
    print(user["authKey"]);
    this.value = user;
  }

  void setShopDataTo(shopData) {
    this.shop = shopData;
  }

  void addCoins(coins) {
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
