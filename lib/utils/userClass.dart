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
  dynamic quests;
  int lastQuestsRefresh = 0;
  int lastShopRefresh = 0;

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
    var accountDataDecoded = jsonDecode(accountData.body)["solo"];
    accountDataDecoded["dailyQuests"].addAll(accountDataDecoded["finished"]["daily"]);
    accountDataDecoded["weeklyQuests"].addAll(accountDataDecoded["finished"]["weekly"]);
    this.quests = accountDataDecoded;
    notifyListeners();

    if (showInfo && accountDataDecoded["updatedPlatforms"] != null) {
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
  }

  Future<String> enterMatch() async {
    String matchId;
    matchId = jsonDecode(
        (await http.get(getUri("/lobby"), headers: {"authorization": this.value["authKey"]})).body);
    var accountData = await http.get(getUri("/account"), headers: {"authorization": this.value["authKey"]});
    var accountDataParsed = jsonDecode(accountData.body);
    this.value["user"] = accountDataParsed["user"];
    this.value["steam"] = accountDataParsed["steam"];
    return matchId;
  }

  Future<void> initQuestsData() async {
    if(lastQuestsRefresh + 900 * 1000 > DateTime.now().millisecondsSinceEpoch && this.quests != null) {
      return this.quests;
    }

    var questsData = jsonDecode((await http.get(getUri("/solo"), headers: {"authorization": this.value["authKey"]})).body)["solo"];
    questsData["dailyQuests"].addAll(questsData["finished"]["daily"]);
    questsData["weeklyQuests"].addAll(questsData["finished"]["weekly"]);
    this.quests = questsData;
    this.lastQuestsRefresh = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    return;
  }

  Future initShopData() async {
    if (this.shop == null || this.lastShopRefresh + 86400*2 * 1000 < DateTime.now().millisecondsSinceEpoch) {
      try {
        print("nonCache");
        var shopData = jsonDecode((await http.get(getUri("/shop"))).body);

        var featuredItem = shopData.firstWhere((e) => e["state"] == 0);
        var paypalItem = shopData.firstWhere((e) => e["type"] == "paypal");
        List<dynamic> items = shopData
            .where((e) => (e["type"] != "paypal") && (e["state"] != 0))
            .toList();

        items.sort((a, b) => a["state"].compareTo(b["state"]) as int);
        var shopDataProcessed = {
          "items": items,
          "featuredItem": featuredItem,
          "paypalData": paypalItem
        };
        this.shop = shopDataProcessed;
        this.lastShopRefresh = DateTime.now().millisecondsSinceEpoch;
        return shopDataProcessed;
      } catch (e) {}

    } else {
      print("cache");
      return this.shop;
    }
  }

  void editShopData(shopData) {
    this.shop = shopData;
  }

  void addCoins(coins) {
    this.value["user"]["coins"] += coins;
    notifyListeners();
  }

  User(user) {
    this.value = user;
  }
}

Future<dynamic> initUser() async {
  var storageKey = await secureStorage.read(key: "authKey");
  if (storageKey == null) return "no data";
  var data = await http.get(getUri("/account"), headers: {"authorization": storageKey});
  return {"data": data, "authKey": storageKey};
}
