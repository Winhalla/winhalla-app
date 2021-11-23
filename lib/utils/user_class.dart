import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/widgets/info_dropdown.dart';

class User extends ChangeNotifier {
  dynamic value;
  dynamic shop;
  dynamic quests;
  int lastQuestsRefresh = 0;
  int lastShopRefresh = 0;
  late CallApi callApi;

  Future<void> refresh() async {
    var accountData = await callApi.get("/account");
    if(accountData["successful"] == false) return;
    value = accountData["data"];
    notifyListeners();
  }

  Future<bool> refreshQuests(BuildContext context, {bool showInfo = false}) async {

    var accountData = await callApi.get("/solo");
    if(accountData["successful"] == false) return true;
    if(accountData["data"]["newQuests"] == true){

      if(showInfo) {
        showInfoDropdown(context, kGreen, "New quests available",
          timeShown: 4500,
          /*body: Row(
            children: icons,
          ),*/
        );
      }
      FirebaseAnalytics.instance.logEvent(
          name: "QuestsRefresh",
          parameters:{
            "updated":true
          }
      );
      return false;
    }
    var accountDataDecoded = accountData["data"]["solo"];
    accountDataDecoded["dailyQuests"].addAll(accountDataDecoded["finished"]["daily"]);
    accountDataDecoded["weeklyQuests"].addAll(accountDataDecoded["finished"]["weekly"]);
    quests = accountDataDecoded;
    notifyListeners();
    if (accountData["data"]["updatedPlatforms"] != null) {
      List<Widget> icons = [];
      for (int i = 0; i < accountData["data"]["updatedPlatforms"].length;i++){
        icons.add(
            Padding(
              padding: EdgeInsets.only(left: i!=0?12:0),
              child: Image.asset(
                "assets/images/icons/pink/${accountData["data"]["updatedPlatforms"][i]}Pink.png",
                color: kText80,
                height: 40,
              ),
            ),
        );
      }
      if(icons.isNotEmpty && showInfo) {
        showInfoDropdown(context, kPrimary, "Data updated",
          timeShown: 4500,
          body: Row(
            children: icons,
          ));
      }
      FirebaseAnalytics.instance.logEvent(
          name: "QuestsRefresh",
          parameters:{
            "updated":true
          }
      );
      return false;
    }
    FirebaseAnalytics.instance.logEvent(
        name: "QuestsRefresh",
        parameters:{
          "updated":false
        }
    );
    return true;
  }

  Future<String> enterMatch() async {
    dynamic matchId = await this.callApi.get("/lobby");
    if(matchId["successful"] == false) return "err";
    matchId = matchId["data"];

    dynamic accountData = await this.callApi.get("/account",showError: false);
    if(accountData["successful"] == false) return matchId;

    accountData = accountData["data"];
    this.value["user"] = accountData["user"];
    this.value["steam"] = accountData["steam"];

    return matchId;
  }

  Future initQuestsData() async {
    if(lastQuestsRefresh + 900 * 1000 > DateTime.now().millisecondsSinceEpoch && this.quests != null) {
      return "loaded";
    }
    dynamic questsData = await this.callApi.get("/solo");
    if(questsData["successful"] == false) return;
    questsData = questsData["data"]["solo"];
    questsData["dailyQuests"].addAll(questsData["finished"]["daily"]);
    questsData["weeklyQuests"].addAll(questsData["finished"]["weekly"]);
    this.quests = questsData;
    this.lastQuestsRefresh = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    return "loaded";
  }

  Future initShopData() async {
    if (this.shop == null || this.lastShopRefresh + 86400*2 * 1000 < DateTime.now().millisecondsSinceEpoch) {
      try {
        dynamic shopData = await this.callApi.get("/shop");
        if(shopData["successful"] == false) return;
        shopData = shopData["data"];
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
      return this.shop;
    }
  }

  void editShopData(shopData) {
    this.shop = shopData;
  }

  void addCoins(coins) {
    value["user"]["coins"] += coins;
    notifyListeners();
  }


  Future<void> collectQuest(int questId, String type, int price) async {

    var result = await callApi.post("/solo/collect?id=$questId&type=$type","{}");
    if(result["successful"] == false) return;
    try{
      if(value["user"]["dailyChallenge"]["challenges"].firstWhere((e)=>e["goal"] == "winhallaQuest",orElse:null) != null){
        refresh();
        FirebaseAnalytics.instance.logEvent(
          name: "FinishDailyChallenge",
          parameters: {
            "type":"Quests"
          }
        );
      }
    } catch(e){}

    FirebaseAnalytics.instance.logEvent(
      name: "CollectQuest",
    );
    quests["${type}Quests"].removeWhere((e)=>e["id"] == questId);
    value["user"]["coins"] += price;
    notifyListeners();
  }

  Future<void> setItemGoal(int itemId) async {
    var result = await callApi.post("/setGoal",jsonEncode({"itemId":itemId}));
    if(result["successful"] == false) return;
    value["user"]["goal"] = result["data"];
    print(value["user"]["goal"]);
  }

  User(this.value,this.callApi);
}

Future<dynamic> initUser(context) async {
  await Firebase.initializeApp();
  var storageKey = await secureStorage.read(key: "authKey");
  if (storageKey == null) return "no data";
  CallApi caller = CallApi(authKey: storageKey, context: context);
  var data = await caller.get("/account");
  if(data["successful"] == false) {
    return null;
  }
  return {"data": data["data"], "authKey": storageKey,"callApi":caller};
}
