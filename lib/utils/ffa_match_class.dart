import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/info_dropdown.dart';
import 'package:winhalla_app/widgets/popups/popup_ad.dart';

class FfaMatch extends ChangeNotifier {
  dynamic value;
  bool areOtherPlayersShown = false;
  late int lastAdPopup;

  Future<bool> refresh(BuildContext context, User user,
      {bool showInfo = false,
        bool isTutorial = false,
        bool isTutorialRefresh = false}) async {
    dynamic match = await user.callApi.get(
          "/getMatch/${isTutorial ? "tutorial" : value["_id"]}" + (isTutorialRefresh ? "?isRefresh=true" : ""),
    );
    if (match["successful"] == false) return true;

    match = match["data"];
    var steamId = value["userPlayer"]["steamId"];

    match["userPlayer"] =
        match["players"].firstWhere((e) => e["steamId"] == steamId);

    match["players"] =
        match["players"].where((e) => e["steamId"] != steamId).toList();
    value = match;
    user.gamesPlayedInMatch = match["userPlayer"]["gamesPlayed"];

    /*if(isTutorialRefresh){
      user.inGame["isMatchFinished"] = match["finished"] ? true : match["fastFinish"];
    }*/

    if (match["userPlayer"]["gamesPlayed"] >= 7) {
      user.inGame["isFinished"] = true;
    }

    await user.refresh();

    if(match["finished"] == true && !isTutorialRefresh) {
      await user.exitMatch(isOnlyLayout: true, matchHistoryAnimated:true);
      notifyListeners();
      return false;
    }

    if(FirebaseRemoteConfig.instance.getBool("isAdButtonActivated") == false &&
        lastAdPopup + 180 * 1000 < DateTime.now().millisecondsSinceEpoch &&
        !isTutorial){
      print("test");
      showAdPopupWidget(context, this);
    }

    if (match["updatedPlatforms"] != null) {
      List<Widget> icons = [];
      for (int i = 0; i < match["updatedPlatforms"].length; i++) {
        icons.add(
          Padding(
            padding: EdgeInsets.only(left: i != 0 ? 12 : 0),
            child: Image.asset(
              "assets/images/icons/pink/${match["updatedPlatforms"][i]}Pink.png",
              color: kText80,
              height: 40,
            ),
          ),
        );
      }
      if (icons.isNotEmpty && showInfo) {
        showInfoDropdown(
          context,
          kPrimary,
          "Data updated",
          timeShown: 4500,
          body: Row(children: icons),
        );
      }
      notifyListeners();
      return false;
    }
    notifyListeners();
    return true;
  }

  void setAdPopupDate(){
    lastAdPopup = DateTime.now().millisecondsSinceEpoch;
  }

  void togglePlayerShown() {
    areOtherPlayersShown = !areOtherPlayersShown;
    notifyListeners();
  }

  FfaMatch(match, String steamId) {
    match["userPlayer"] =
        match["players"].firstWhere((e) => e["steamId"] == steamId);
    match["players"] =
        match["players"].where((e) => e["steamId"] != steamId).toList();
    value = match;
    areOtherPlayersShown = false;
    lastAdPopup = match["userPlayer"]["joinDate"];
    notifyListeners();
  }
}
