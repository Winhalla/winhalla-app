import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/info_dropdown.dart';

class FfaMatch extends ChangeNotifier {
  dynamic value;
  bool areOtherPlayersShown = false;
  Future<bool> refresh(BuildContext context,User user,{bool showInfo =false}) async {
    dynamic match = await user.callApi.get("/getMatch/${value["_id"]}");
    if(match["successful"] == false) return true;

    match = match["data"];
    var steamId = value["userPlayer"]["steamId"];
    match["userPlayer"] = match["players" ].firstWhere((e) => e["steamId"] == steamId);
    match["players"] = match["players"].where((e)=>e["steamId"]!= steamId).toList();
    value = match;

    if (match["userPlayer"]["gamesPlayed"] >= 7) {
      FirebaseAnalytics.instance.logEvent(
        name: "FinishedSoloMatch",
      );
    }

    if(
    match["userPlayer"]["gamesPlayed"] >= 7
        &&
    user.value["user"]["dailyChallenge"]["challenges"].firstWhere((e)=>e["goal"] == "winhallaMatch",orElse:null) != null
    ){
      user.refresh();
      FirebaseAnalytics.instance.logEvent(
        name: "FinishDailyChallenge",
        parameters: {
          "type":"Match"
        }
      );
    }

    if(match["updatedPlatforms"] != null) {
      List<Widget> icons = [];
      for (int i = 0; i < match["updatedPlatforms"].length;i++){
        icons.add(
          Padding(
            padding: EdgeInsets.only(left: i!=0?12:0),
            child: Image.asset(
              "assets/images/icons/pink/${match["updatedPlatforms"][i]}Pink.png",
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
              children: icons
          ),
        );
      }
      notifyListeners();
      FirebaseAnalytics.instance.logEvent(
          name: "MatchRefresh",
          parameters:{
            "updated":true
          }
      );
      return false;
    }
    FirebaseAnalytics.instance.logEvent(
        name: "MatchRefresh",
        parameters:{
          "updated":false
        }
    );
    notifyListeners();
    return true;
  }

  void exit() async {
    await http.post(getUri("/exitMatch/${value["_id"].toString()}"));
  }
  void togglePlayerShown() {
    areOtherPlayersShown = !areOtherPlayersShown;
    notifyListeners();
  }

  FfaMatch(match, String steamId) {
    match["userPlayer"] = match["players"].firstWhere((e) => e["steamId"] == steamId);
    match["players"] = match["players"].where((e)=>e["steamId"]!= steamId).toList();
    value = match;
    areOtherPlayersShown = false;
    FirebaseAnalytics.instance.logEvent(
      name: "JoinSoloMatch",
    );
    notifyListeners();
  }
}