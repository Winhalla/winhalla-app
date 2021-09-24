import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';

class FfaMatch extends ChangeNotifier {
  dynamic value;

  void refresh() async {
    this.value = await http.get(getUri("/getMatch/613e57a522d5937857affe65"));
    notifyListeners();
  }

  void exit() async {
    await http.post(getUri("/exitMatch/613e57a522d5937857affe65"));
    this.value = "exited";
    notifyListeners();
  }

  FfaMatch(match) {
    this.value = matchData;
    notifyListeners();
  }
}

var matchData = {
  "_id": "613e57a522d5937857affe65",
  "finished": true,
  "fastFinish": false,
  "remainingSpace": 2,
  "Date": 1631475621800,
  "createdAt": "2021-09-12T19:40:21.800Z",
  "players": [
    {
      "wins": 5,
      "gamesPlayed": 7,
      "multiplier": 5.6,
      "adsWatched": 3,
      "updateCount": 1,
      "_id": "613e9e9e22d5937857affef5",
      "steamId": "steam76561198856213869",
      "brawlhallaId": 9303456,
      "username": "vitortadeums",
      "totalWins": 683,
      "totalGamesPlayed": 1360,
      "avatarURL": "https: //steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg",
      "joinDate": 1631493790885,
      "rank": 0,
      "rewards": 83.44,
      "multiplierDetails": {
        "base": 14.9,
        "event": 0,
        "link": 40,
        "player": 0,
        "ad": 300
      }
    },
    {
      "wins": 4,
      "gamesPlayed": 7,
      "multiplier": 9,
      "adsWatched": 8,
      "updateCount": 2,
      "_id": "613e8a2b22d5937857affeaa",
      "steamId": "steam76561198814846191",
      "brawlhallaId": 41814323,
      "username": "ItsAGaem",
      "totalWins": 59,
      "totalGamesPlayed": 103,
      "avatarURL": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/dc/dc4ae685dce5d2db24996558d011c59d97ee99c9_full.jpg",
      "joinDate": 1631488555221,
      "rank": 1,
      "rewards": 86.4,
      "multiplierDetails": {
        "base": 9.6,
        "event": 0,
        "link": 0,
        "player": 0,
        "ad": 800
      }
    },
    {
      "wins": 4,
      "gamesPlayed": 7,
      "multiplier": 12.6,
      "adsWatched": 8,
      "updateCount": 2,
      "_id": "613e9b5422d5937857affeec",
      "steamId": "steam76561198799823383",
      "brawlhallaId": 59725007,
      "username": "Wildberth",
      "totalWins": 249,
      "totalGamesPlayed": 489,
      "avatarURL": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/80/807482f54d0bdda3de9249fd75b402e7a4bff639_full.jpg",
      "joinDate": 1631492948471,
      "rank": 1,
      "rewards": 120.96,
      "multiplierDetails": {
        "base": 9.6,
        "event": 0,
        "link": 40,
        "player": 0,
        "ad": 800
      }
    },
    {
      "wins": 3,
      "gamesPlayed": 7,
      "multiplier": 12.6,
      "adsWatched": 8,
      "updateCount": 1,
      "_id": "613e57a522d5937857affe66",
      "steamId": "steam76561198250077480",
      "brawlhallaId": 2955838,
      "username": "Igor",
      "totalWins": 355,
      "totalGamesPlayed": 705,
      "avatarURL": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/09/09458d21b1664cb1c8822b3790ec7d882148f480_full.jpg",
      "joinDate": 1631475621800,
      "rank": 3,
      "rewards": 88.2,
      "multiplierDetails": {
        "base": 7,
        "event": 0,
        "link": 40,
        "player": 0,
        "ad": 800
      }
    },
    {
      "wins": 3,
      "gamesPlayed": 7,
      "multiplier": 1,
      "adsWatched": 0,
      "updateCount": 2,
      "_id": "613e8d3522d5937857affeb8",
      "steamId": "steam76561198968450608",
      "brawlhallaId": 70233834,
      "username": "pumba",
      "totalWins": 78,
      "totalGamesPlayed": 159,
      "avatarURL": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/92/92e70e8ee62420c9aa7137e3a4ee4ceeb9212b92_full.jpg",
      "joinDate": 1631489333312,
      "rank": 3,
      "rewards": 7,
      "multiplierDetails": {
        "base": 7,
        "event": 0,
        "link": 0,
        "player": 0,
        "ad": 0
      }
    },
    {
      "wins": 3,
      "gamesPlayed": 4,
      "multiplier": 12.6,
      "adsWatched": 8,
      "updateCount": 1,
      "_id": "613e907522d5937857affecc",
      "steamId": "steam76561198861444756",
      "brawlhallaId": 9469162,
      "username": "fremel",
      "totalWins": 174,
      "totalGamesPlayed": 346,
      "avatarURL": "https://steamcdn-a.akamaihd.net/steamcommunity/public/images/avatars/6a/6a3535dc6043c2c2c4761e199f4c269fe68191cd_full.jpg",
      "joinDate": 1631490165272,
      "rank": 3,
      "rewards": 88.2,
      "multiplierDetails": {
        "base": 7,
        "event": 0,
        "link": 40,
        "player": 0,
        "ad": 800
      }
    }
  ],
  "__v": 0
};