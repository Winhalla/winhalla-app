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
    var accountDataDecoded = jsonDecode(accountData.body);
    this.value["user"]["solo"] = accountDataDecoded["solo"];
    if (showInfo) {
      List<Widget> icons = [];
      for (int i = 0; i < accountDataDecoded["updatedPlatforms"].length;i++){
        icons.add(
            Padding(
              padding: EdgeInsets.only(left: i!=0?12:0),
              child: Image.asset(
                "assets/images/icons/pink/${accountDataDecoded["updatedPlatforms"][i]}Pink.png",
                color: kText80,
                height: 40,
              ),
            ),
        );
      }
      if(icons.length>0) showInfoDropdown(context, kPrimary, "Data updated",
          timeShown: 4500,
          body: Row(
            children: icons,
          ));
    }
    notifyListeners();
  }

  Future<String> enterMatch() async {
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
