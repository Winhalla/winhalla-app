import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/user_class.dart';

import '../main.dart';
import '../screens/login.dart';

MaterialPageRoute buildAppController(int startIndex){
  return MaterialPageRoute(builder: (context)=> SafeArea(
    child: FutureBuilder(
        future: initUser(context),
        builder: (context, AsyncSnapshot<dynamic> res) {
          if (!res.hasData) {
            return const AppCore(isUserDataLoaded: false);
          }

          if (res.data == "no data" ||
              res.data["data"] == "" ||
              res.data["data"] == null) {
            return LoginPage(userData: res.data);
          }

          if (res.data["data"]["user"] == null) {
            return LoginPage(userData: res.data);
          }

          // Do not edit res.data directly otherwise it calls the build function again for some reason
          Map<String, dynamic> newData =
          res.data as Map<String, dynamic>;
          var callApi = res.data["callApi"];

          newData["callApi"] = null;
          newData["user"] = res.data["data"]["user"];
          newData["steam"] = res.data["data"]["steam"];
          newData["informations"] = res.data["data"]["informations"];
          newData["tutorial"] = res.data["tutorial"];

          List<GlobalKey?> keys = [];
          for (int i = 0; i < 17; i++) {
            if (i == 0 ||
                i == 4 ||
                i == 5 ||
                i == 10 ||
                i == 11 ||
                i == 16) {
              keys.add(null);
            } else {
              keys.add(GlobalKey());
            }
          }
          var inGameData = newData["user"]["inGame"];
          var currentMatch = inGameData
              .where((g) => g["isFinished"] == false)
              .toList();

          var inGame = null;
          if (currentMatch.length > 0) {
            inGame = {
              'id': currentMatch[0]["id"],
              'joinDate': currentMatch[0]["joinDate"]
            };
          }
          /*Future.delayed(const Duration(seconds: 5),(){
                            FlutterApplovinMax.showMediationDebugger();
                          });*/

          return ChangeNotifierProvider<User>(
              create: (_) => User(newData, callApi, keys,
                  inGame, res.data["oldDailyChallengeData"]),
              child: AppCore(
                startIndex: startIndex,
                isUserDataLoaded: true,
                tutorial: newData["tutorial"],
              ));
        }),
  ));
}