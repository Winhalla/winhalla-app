import 'dart:async';
import 'dart:convert';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/store_quests_data.dart';
import 'package:winhalla_app/widgets/coin_dropdown.dart';
import 'package:winhalla_app/widgets/info_dropdown.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:winhalla_app/widgets/popup_link.dart';

import 'ad_helper.dart';

class User extends ChangeNotifier {
  dynamic value;
  dynamic shop;
  dynamic quests;
  dynamic inGame;
  int gamesPlayedInMatch = 0;
  bool animateMatchHistory = false;
  GlobalKey appBarKey = GlobalKey();
  int lastQuestsRefresh = 0;
  int lastShopRefresh = 0;
  List<GlobalKey?> keys;
  Map<String, dynamic> keyFx = {};
  late CallApi callApi;
  bool hasAlreadyInitAdmob = false;

  var oldQuestsData;
  var oldDailyChallengeData;

  int lastInterstitialAd = 0;
  int lastMatchInterstitial = 0;
  int lastQuestsInterstitial = 0;
  InterstitialAd? interstitialAd;

  Future<void> refresh({notify = true}) async {
    var accountData = await callApi.get("/account");
    if (accountData["successful"] == false) return;
    value = accountData["data"];

    var inGameData = value["user"]["inGame"];
    var currentMatch =
        inGameData.where((g) => g["isFinished"] == false).toList();

    var newDailyChallengeData = value["user"]["dailyChallenge"]["challenges"];
    var ssOldDailyChallengeData = await getNonNullSSData("dailyChallengeData");

    oldDailyChallengeData = ssOldDailyChallengeData != "no data"
        ? jsonDecode(ssOldDailyChallengeData)
        : newDailyChallengeData;

    /*await secureStorage.write(
        key: "dailyChallengeData", value: jsonEncode(newDailyChallengeData));*/

    try {
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
    } catch (e) {}
    if (notify) notifyListeners();
  }

  Future<bool> refreshQuests(BuildContext context,
      {bool showInfo = false, isTutorial = false}) async {
    var accountData = await callApi
        .get("/solo" + (isTutorial == true ? "?tutorial=true" : ""));

    if (accountData["successful"] == false) return true;
    var accountDataDecoded = accountData["data"]["solo"];

    //Add finished quests before the other ones
    accountDataDecoded["dailyQuests"] = [
      ...accountDataDecoded["finished"]["daily"],
      ...accountDataDecoded["dailyQuests"]
    ];

    accountDataDecoded["weeklyQuests"] = [
      ...accountDataDecoded["finished"]["weekly"],
      ...accountDataDecoded["weeklyQuests"]
    ];
    quests = accountDataDecoded;
    notifyListeners();

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
      FirebaseAnalytics.instance.logEvent(
          name: "QuestsRefresh",
          parameters:{
            "updated":true
          }
      );
      return false;
    }
    if (accountData["data"]["updatedPlatforms"] == null) {
      return false;
    }

    if (accountData["data"]["updatedPlatforms"].length > 0) {
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

  Future<String> enterMatch(
      {bool isTutorial = false, String? targetedMatchId, bool isFromMatchHistory = false}) async {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: "SoloMatch", screenClassOverride: "MainActivity");
    if (isTutorial) {
      inGame = {
        'id': "tutorial",
        'joinDate': DateTime.now().millisecondsSinceEpoch,
        'isFinished': false,
      };
      notifyListeners();
      return "tutorial";
    }


    if (inGame != null) {
      inGame = null;
      gamesPlayedInMatch = 0;
      notifyListeners();
    }
    dynamic matchId;

    if (targetedMatchId != null) {
      matchId = targetedMatchId;
      gamesPlayedInMatch = 7;
    } else {
      matchId = await callApi.get("/lobby");
      if (matchId["successful"] == false) return "err";
      matchId = matchId["data"];
    }

    FirebaseAnalytics.instance.logEvent(
      name: "JoinSoloMatch",
    );

    dynamic accountData = await callApi.get("/account", showError: false);
    if (accountData["successful"] == false) return matchId;

    accountData = accountData["data"];
    value["user"] = accountData["user"];
    value["steam"] = accountData["steam"];

    inGame = {
      'id': matchId,
      'joinDate': DateTime.now().millisecondsSinceEpoch,
      'isFinished': false,
      'showActivity':
          targetedMatchId != null && isFromMatchHistory ? false : null,
      'showMatch': true,
      'isFromMatchHistory': isFromMatchHistory
    };

    notifyListeners();
    return matchId;
  }

  Future<void> exitMatch(
      {isOnlyLayout = false,
      isBackButton = false,
      isFromMatchHistory = false,
      matchHistoryAnimated = false}) async {
    FirebaseAnalytics.instance.setCurrentScreen(screenName: "Play", screenClassOverride: "MainActivity");
    if (isBackButton) {
      inGame["isShown"] = false;
      notifyListeners();
      return;
    }

    if (isOnlyLayout) {
      inGame = null;
      gamesPlayedInMatch = 0;
      if (matchHistoryAnimated) animateMatchHistory = true;
      notifyListeners();
      if (isFromMatchHistory) refresh(notify: false);
      return;
    }

    await callApi.post("/exitMatch", "");

    await refresh();
    inGame = null;
    gamesPlayedInMatch = 0;

    notifyListeners();
  }

  Future initQuestsData() async {
    if (lastQuestsRefresh + 900 * 1000 >
            DateTime.now().millisecondsSinceEpoch &&
        quests != null) {
      return true;
    }
    dynamic questsData = await callApi.get("/solo");

    if (questsData["successful"] == false) return;
    questsData = questsData["data"]["solo"];
    //Add finished quests before the other ones
    questsData["dailyQuests"] = [
      ...questsData["finished"]["daily"],
      ...questsData["dailyQuests"]
    ];

    questsData["weeklyQuests"] = [
      ...questsData["finished"]["weekly"],
      ...questsData["weeklyQuests"]
    ];
    quests = questsData;
    lastQuestsRefresh = DateTime.now().millisecondsSinceEpoch;

    // Handle if there is no questsData key in secure storage
    var oldQuestsData1 = await getNonNullSSData("questsData");
    if (oldQuestsData1 != "no data") {
      oldQuestsData = jsonDecode(oldQuestsData1);
    } else {
      refreshOldQuestsData();
    }
    notifyListeners();
    return false;
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

  Future<void> collectQuest(int questId, String type, int price,
      {isTutorial = false}) async {
    var result =
        await callApi.post("/solo/collect?id=$questId&type=$type", "{}");
    if (result["successful"] == false) return;
    try {
      var dailyChallenge = value["user"]["dailyChallenge"]["challenges"]
          .firstWhere(
              (e) => e["goal"] == "winhallaQuest" && e["active"] == true,
              orElse: () => null);
      if (dailyChallenge != null) {
        refresh();
      }
    } catch (e) {}

    var quest = quests["${type}Quests"]
        .firstWhere((e) => e["id"] == questId, orElse: () => null);

    if (quest != null) {
      showCoinDropdown(appBarKey.currentContext as BuildContext,
          value["user"]["coins"], quest["reward"]);
    }
    FirebaseAnalytics.instance.logEvent(
      name: "CollectQuest",
    );

    quests["${type}Quests"].removeWhere((e) => e["id"] == questId);
    value["user"]["coins"] += price;

    if (!isTutorial) {
      Future.delayed(const Duration(milliseconds: 1400), () => showInterstitialAd(InterstitialType.quests));
    }
    refreshOldQuestsData();
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

  void toggleShowMatch(bool setTo) {
    inGame["showMatch"] = setTo;
  }

  void resetInGame() {
    inGame = null;
    gamesPlayedInMatch = 0;
    notifyListeners();
  }

  void setGames(games) {
    gamesPlayedInMatch = games;
    keyFx["rebuildNavbar"]();
  }

  void setMatchInProgress() {
    inGame["showActivity"] = null;
    keyFx["rebuildNavbar"]();
    keyFx["rebuildBottomNavbar"]();
  }

  void setIsShown(bool isShown) {
    if (inGame != null) {
      inGame["isShown"] = isShown;
    }
  }

  void refreshOldQuestsData() async {
    var questsDataStored = storeQuestsData(quests);
    oldQuestsData = questsDataStored;
  }

  void refreshOldDailyChallengeData() async {
    oldDailyChallengeData = value["user"]["dailyChallenge"]["challenges"];
    await secureStorage.write(
        key: "dailyChallengeData",
        value: jsonEncode(value["user"]["dailyChallenge"]["challenges"]));
  }

  User(this.value, this.callApi, this.keys, this.inGame,
      this.oldDailyChallengeData);

  void setAnimateMatchHistory(bool setTo) {
    animateMatchHistory = setTo;
  }
  Future<void> showInterstitialAd(InterstitialType type) async {

    if (kDebugMode) return;
    /*try{
      if(value["steam"]["id"] == "google100943440915784958511" || value["steam"]["id"] == "google102386642559331245430") return;
    }catch(e){}*/

    // Not more than an inter per minute and one for each type each 3 minutes
    if(lastInterstitialAd + 60 * 1000 > DateTime.now().millisecondsSinceEpoch) return;
    if(type == InterstitialType.match && lastMatchInterstitial + 120 * 1000 > DateTime.now().millisecondsSinceEpoch) return;
    if(type == InterstitialType.quests && lastQuestsInterstitial + 120 * 1000 > DateTime.now().millisecondsSinceEpoch) return;

    lastInterstitialAd = DateTime.now().millisecondsSinceEpoch;
    if(type == InterstitialType.match) lastMatchInterstitial = DateTime.now().millisecondsSinceEpoch;
    if(type == InterstitialType.quests) lastQuestsInterstitial = DateTime.now().millisecondsSinceEpoch;

    showApplovinInterstitial(type == InterstitialType.match
        ? "pre-match"
        : type == InterstitialType.quests
        ? "after-quests"
        : "other");
  }
}

enum InterstitialType {
  match,
  quests
}

Future<dynamic> initUser(context) async {
  FirebaseRemoteConfig.instance.fetchAndActivate();
  var storageKey = await secureStorage.read(key: "authKey");
  if (storageKey == null) return "no data";
  CallApi caller = CallApi(authKey: storageKey, context: context);
  var data = await caller.get("/account?apple=${Platform.isIOS}");
  if (data["successful"] == false) {
    return null;
  }
  // Tutorial
  dynamic tutorialFinished;
  dynamic tutorialStep;
  try {
    tutorialFinished =
        data["data"]["user"]["tutorialStep"]["hasFinishedTutorial"] == true
            ? false
            : true;

    if (data["data"]["user"]["tutorialStep"]["hasFinishedTutorial"] == true) {
      tutorialStep = 17;
    } else if (data["data"]["user"]["tutorialStep"]["hasDoneTutorialQuest"] ==
        true) {
      tutorialStep = 13;
    } else if (data["data"]["user"]["tutorialStep"]["hasDoneTutorialMatch"] ==
        true) {
      tutorialStep = 8;
    } else {
      tutorialStep = 0;
    }
  } catch (e) {}
  // Daily challenge
  dynamic oldDailyChallengeData;
  try {
    var newDailyChallengeData =
        data["data"]["user"]["dailyChallenge"]["challenges"];
    var ssOldDailyChallengeData = await getNonNullSSData("dailyChallengeData");

    oldDailyChallengeData = ssOldDailyChallengeData != "no data"
        ? jsonDecode(ssOldDailyChallengeData)
        : newDailyChallengeData;
  } catch (e) {}
  // App tracking transparency IOS
  if (Platform.isIOS &&
      await AppTrackingTransparency.trackingAuthorizationStatus ==
          TrackingStatus.notDetermined) {
    await AppTrackingTransparency.requestTrackingAuthorization();
  }
  // Referral link
  try{
    if(!kDebugMode){
      String? timesOpened = await secureStorage.read(key: "timesOpened");
      String? notFirstTime = await secureStorage.read(key: "hasShownLinkPopup");
      print(timesOpened);
      if(timesOpened == null){
        await secureStorage.write(key: "timesOpened",value: "1");
      } else {
        int timesOpenInt = int.parse(timesOpened);
        String linkId = data["data"]["user"]["linkId"];
        int neededAppOpensToDisplayLinkAlert = notFirstTime == "true" ? 15 : 3;

        if(timesOpenInt >= neededAppOpensToDisplayLinkAlert) {
          showDialog(context: context, builder: (_)=> LinkInfoWidget(linkId, true));
          FirebaseAnalytics.instance.logEvent(name: "ShownReferralLinkPopup",parameters: {"isForcedPopupShow": false});
          await secureStorage.write(key: "timesOpened",value: "0");
          if(notFirstTime == null) await secureStorage.write(key: "hasShownLinkPopup", value:"true");

        } else {
          await secureStorage.write(key: "timesOpened",value: "${timesOpenInt+1}");
        }
      }
    }
  }catch(e){}
  // Pre-load ads
  if(!kDebugMode) {
    try{
      FlutterApplovinMax.initRewardAd(AdHelper.rewardedApplovinUnitId);
      FlutterApplovinMax.initInterstitialAd(AdHelper.interstitialApplovinUnitId);
    }catch(e){}
  }
  return {
    "data": data["data"],
    "authKey": storageKey,
    "callApi": caller,
    "oldDailyChallengeData": oldDailyChallengeData,
    "tutorial": {
      "needed": tutorialFinished ?? false,
      "tutorialStep": tutorialStep ?? 0
    }
  };
}