import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/userClass.dart';

class FfaMatch extends ChangeNotifier {
  dynamic value;
  bool areOtherPlayersShown = false;
  Future<void> refresh(String authKey) async {
    var match = jsonDecode((await http.get(getUri("/getMatch/${this.value["_id"]}"),headers: {"authorization":authKey})).body);
    var steamId = this.value["userPlayer"]["steamId"];
    match["userPlayer"] = match["players"].firstWhere((e) => e["steamId"] == steamId);
    match["players"] = match["players"].where((e)=>e["steamId"]!= steamId).toList();
    this.value = match;
    notifyListeners();
  }

  void exit() async {
    await http.post(getUri("/exitMatch/613e57a522d5937857affe65"));
    this.value = "exited";
    notifyListeners();
  }
  void togglePlayerShown() {
    this.areOtherPlayersShown = !this.areOtherPlayersShown;
    notifyListeners();
  }

  FfaMatch(match, String steamId) {
    match["userPlayer"] = match["players"].firstWhere((e) => e["steamId"] == steamId);
    match["players"] = match["players"].where((e)=>e["steamId"]!= steamId).toList();
    this.value = match;
    this.areOtherPlayersShown = false;
    notifyListeners();
  }
}

Future<dynamic> initMatch(String matchId, context) async {
  var storageKey = context.read<User>()["authKey"];
  if (storageKey == null) return Future(() => "no data");
  var data = await http.get(getUri("/getMatch/$matchId"), headers: {"authorization": storageKey});
  return data;
}
