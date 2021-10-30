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
  late CallApi callApi;

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

    var accountData = await this.callApi.get("/solo");
    if(accountData["successful"] == false) return;
    if(showInfo && accountData["data"]["newQuests"] == true){
      showInfoDropdown(context, kGreen, "New quests available",
        timeShown: 4500,
        /*body: Row(
          children: icons,
        ),*/
      );

    }
    var accountDataDecoded = accountData["data"]["solo"];
    accountDataDecoded["dailyQuests"].addAll(accountDataDecoded["finished"]["daily"]);
    accountDataDecoded["weeklyQuests"].addAll(accountDataDecoded["finished"]["weekly"]);
    this.quests = accountDataDecoded;
    notifyListeners();
    if (showInfo && accountData["data"]["updatedPlatforms"] != null) {
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
      if(icons.length>0) showInfoDropdown(context, kPrimary, "Data updated",
          timeShown: 4500,
          body: Row(
            children: icons,
          ));
    }
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
    this.value["user"]["coins"] += coins;
    notifyListeners();
  }

  User(user,callApi) {
    this.callApi = callApi;
    this.value = user;
  }

  Future<void> collectQuest(int questId, String type, int price) async {
    var result = await this.callApi.post("/solo/collect?id=$questId&type=$type","{}");
    if(result["successful"] == false) return;
    this.quests["${type}Quests"].removeWhere((e)=>e["id"] == questId);
    this.value["user"]["coins"] += price;
    notifyListeners();
  }

}

Future<dynamic> initUser(context) async {
  var storageKey = await secureStorage.read(key: "authKey");
  if (storageKey == null) return "no data";
  CallApi caller = new CallApi(authKey: storageKey, context: context);
  var data = await caller.get("/account",showError:false);
  if(data["successful"] == false) {
    showInfoDropdown(
      context,
      kRed,
      "Error:",
      body: Text(
        data["data"] + data["addText"] != false ? "" : "\nIf error persists, please contact support.",
        style: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(TextStyle(color: kText, fontSize: 20)),
      ),
      fontSize:25,
      column:true,
    );
    return null;
  }
  return {"data": data["data"], "authKey": storageKey,"callApi":caller};
}
