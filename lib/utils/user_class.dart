import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/widgets/info_dropdown.dart';

class   User extends ChangeNotifier {
  dynamic value;
  dynamic shop;
  dynamic quests;
  dynamic inGame;
  int gamesPlayedInMatch = 0;

  int lastQuestsRefresh = 0;
  int lastShopRefresh = 0;
  List<GlobalKey?> keys;
  Map<String,dynamic> keyFx = {};
  late CallApi callApi;

  Future<void> refresh() async {
    var accountData = await callApi.get("/account");
    if (accountData["successful"] == false) return;
    value = accountData["data"];

    var inGameData = value["user"]["inGame"];
    var currentMatch =
        inGameData.where((g) => g["isFinished"] == false).toList();

    if (currentMatch.length > 0) {
      inGame = {
        'id': currentMatch[0]["id"],
        'joinDate': currentMatch[0]["joinDate"],
        'isFinished': false,
      };
    } else if (inGame["isMatchFinished"] == true) {
      inGame = null;
      gamesPlayedInMatch = 0;
    }

    notifyListeners();
  }

  Future<bool> refreshQuests(BuildContext context,
      {bool showInfo = false, isTutorial = true}) async {
    var accountData = await callApi.get("/solo" + (isTutorial == true ? "?tutorial=true" : ""));
    if (accountData["successful"] == false) return true;
    if (accountData["data"]["newQuests"] == true) {
      if (showInfo) {
        showInfoDropdown(
          context,
          kGreen,
          "New quests available",
          timeShown: 4500,
          /*body: Row(
          children: icons,
        ),*/
        );
      }
      return true;
    }
    var accountDataDecoded = accountData["data"]["solo"];
    accountDataDecoded["dailyQuests"]
        .addAll(accountDataDecoded["finished"]["daily"]);
    accountDataDecoded["weeklyQuests"]
        .addAll(accountDataDecoded["finished"]["weekly"]);
    quests = accountDataDecoded;
    notifyListeners();
    if (accountData["data"]["updatedPlatforms"] != null) {
      List<Widget> icons = [];
      for (int i = 0; i < accountData["data"]["updatedPlatforms"].length; i++) {
        icons.add(
          Padding(
            padding: EdgeInsets.only(left: i != 0 ? 12 : 0),
            child: Image.asset(
              "assets/images/icons/pink/${accountData["data"]["updatedPlatforms"][i]}Pink.png",
              color: kText80,
              height: 40,
            ),
          ),
        );
      }
      if (icons.isNotEmpty && showInfo) {
        showInfoDropdown(context, kPrimary, "Data updated",
            timeShown: 4500,
            body: Row(
              children: icons,
            ));
      }
      return true;
    }
    return false;
  }

  Future<String> enterMatch() async {
    if (inGame != null) {
      inGame = null;
      gamesPlayedInMatch = 0;
      notifyListeners();
    }

    dynamic matchId = await callApi.get("/lobby");
    if (matchId["successful"] == false) return "err";
    matchId = matchId["data"];

    dynamic accountData = await callApi.get("/account", showError: false);
    if (accountData["successful"] == false) return matchId;

    accountData = accountData["data"];
    value["user"] = accountData["user"];
    value["steam"] = accountData["steam"];

    inGame = {
      'id': matchId,
      'joinDate': DateTime.now().millisecondsSinceEpoch,
      'isFinished': false
    };

    notifyListeners();
    return matchId;
  }

  Future<void> exitMatch(beforeEnd) async {
    if (beforeEnd == true) {
      await callApi.post("/endMatch", "");
    } else {
      await callApi.post("/exitMatch", "");
    }

    inGame = null;
    gamesPlayedInMatch = 0;
    
    notifyListeners();
  }

  Future initQuestsData() async {
    if (lastQuestsRefresh + 900 * 1000 >
            DateTime.now().millisecondsSinceEpoch &&
        quests != null) {
      return "loaded";
    }
    dynamic questsData = await callApi.get("/solo");
    if (questsData["successful"] == false) return;
    questsData = questsData["data"]["solo"];
    questsData["dailyQuests"].addAll(questsData["finished"]["daily"]);
    questsData["weeklyQuests"].addAll(questsData["finished"]["weekly"]);
    quests = questsData;
    lastQuestsRefresh = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    return "loaded";
  }

  Future initShopData() async {
    if (shop == null ||
        lastShopRefresh + 86400 * 2 * 1000 <
            DateTime.now().millisecondsSinceEpoch) {
      try {
        dynamic shopData = await callApi.get("/shop");
        if (shopData["successful"] == false) return;
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
        shop = shopDataProcessed;
        lastShopRefresh = DateTime.now().millisecondsSinceEpoch;
        return shopDataProcessed;
      } catch (e) {}
    } else {
      return shop;
    }
  }

  void editShopData(shopData) {
    shop = shopData;
  }

  void addCoins(coins) {
    value["user"]["coins"] += coins;
    notifyListeners();
  }

  Future<void> collectQuest(int questId, String type, int price) async {
    var result =
        await callApi.post("/solo/collect?id=$questId&type=$type", "{}");
    if (result["successful"] == false) return;
    try {
      if (value["user"]["dailyChallenge"]["challenges"]
              .firstWhere((e) => e["goal"] == "winhallaQuest", orElse: null) !=
          null) {
        refresh();
      }
    } catch (e) {}

    quests["${type}Quests"].removeWhere((e) => e["id"] == questId);
    value["user"]["coins"] += price;
    notifyListeners();
  }

  Future<void> setItemGoal(int itemId) async {
    var result = await callApi.post("/setGoal", jsonEncode({"itemId": itemId}));
    if (result["successful"] == false) return;
    value["user"]["goal"] = result["data"];
  }

  void setKeyFx(Function keyFx1, String key) {
    keyFx[key] = keyFx1;
  }

  User(this.value, this.callApi, this.keys, this.inGame);
}

Future<dynamic> initUser(context) async {
  await Firebase.initializeApp();

  var storageKey = await secureStorage.read(key: "authKey");
  if (storageKey == null) return "no data";
  CallApi caller = CallApi(authKey: storageKey, context: context);
  var data = await caller.get("/account");
  if (data["successful"] == false) {
    return null;
  }
  dynamic tutorialFinished;
  dynamic tutorialStep;
  try{
    tutorialFinished = data["data"]["user"]["tutorialStep"]["hasFinishedTutorial"] == true ? false : true;
    if(data["data"]["user"]["tutorialStep"]["hasFinishedTutorial"] == true){
      tutorialStep = 17;

    } else if (data["data"]["user"]["tutorialStep"]["hasDoneTutorialQuest"] == true){
      tutorialStep = 13;

    } else if(data["data"]["user"]["tutorialStep"]["hasDoneTutorialMatch"] == true){
      tutorialStep = 8;

    } else {
      tutorialStep = 0;
    }

  } catch(e){}
  return {
    "data": data["data"],
    "authKey": storageKey,
    "callApi": caller,
    "tutorial": {
      "needed": tutorialFinished ?? false,
      "tutorialStep": tutorialStep ?? 0
    }
  };
}
