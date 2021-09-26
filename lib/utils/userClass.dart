import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
class User extends ChangeNotifier{
  dynamic value;

  void refresh() async {
    this.value = await http.get(getUri("/account"),headers: {"authorization":await secureStorage.read(key: "authKey") as String});
    print(this.value.body);
    this.value = jsonDecode(this.value.body);
    notifyListeners();
  }

  User(user){
    this.value = userData;
    notifyListeners();
  }
}


var userData = {
  "user": {
    "stats": {
      "solo": {
        "wins": 0,
        "gamesPlayed": 0
      },
      "2v2": {
        "wins": 0,
        "gamesPlayed": 0
      },
      "ffa": {
        "gamesPlayed": 0,
        "wins": 0
      }
    },
    "isSucpicious": {
      "ffa": false,
      "solo": false
    },
    "lastVideoAd": {
      "earnCoins": {}
    },
    "lastLotteryRoll": {},
    "coinLogs": {
      "total": {
        "solo": 0,
        "dailyQuests": 0,
        "weeklyQuests": 0,
        "link": 0,
        "redeemed": 0,
        "beta": 0
      },
      "history": [
        {
          "type": "Beta",
          "displayName": "Coins earned in Beta",
          "data": {
            "reward": 0
          },
          "timestamp": 1630433194283
        }
      ]
    },
    "notifications": [],
    "boost": 0,
    "coinsThisWeek": 0,
    "_id": "612d2bebdc5c9b3e6455fe60",
    "steamId": "steam76561198417157310",
    "brawlhallaId": 29163214,
    "brawlhallaName": "Philtrom",
    "avatarURL": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/da/da77bb66176e79e92a34eae1b2a492b0b6f37e07_full.jpg",
    "miniAvatarURL": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/da/da77bb66176e79e92a34eae1b2a492b0b6f37e07_medium.jpg",
    "coins": 585646545,
    "joinDate": 1630350315348,
    "linkId": "A2U42T",
    "lastGames": [],
    "__v": 0,
    "guidesOpenedList": {
      "play": [
        "game_modes",
        "quests",
        "quests_refresh"
      ],
      "solo": [
        "main",
        "play_ad",
        "refresh_data"
      ]
    },
    "waitingNewQuestsDaily": true,
    "waitingNewQuestsWeekly": true,
    "inGame": []
  },
  "steam": {
    "id": "steam76561198417157310",
    "name": "Philtrom",
    "picture": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/da/da77bb66176e79e92a34eae1b2a492b0b6f37e07_full.jpg",
    "pictureMini": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/da/da77bb66176e79e92a34eae1b2a492b0b6f37e07_medium.jpg"
  }
};