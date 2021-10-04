import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/userClass.dart';

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

  FfaMatch(match, context) {
    String steamId = context;
    match["userPlayer"] = match["players"].firstWhere((e) => e["steamId"] == steamId);
    match["players"] = match["players"].where((e)=>e["steamId"]!= steamId).toList();
    this.value = match;
    notifyListeners();
  }
}

Future<dynamic> initMatch(matchId, context) async {
  var storageKey = context.read<User>()["authKey"];
  if (storageKey == null) return Future(() => "no data");
  var data = await http.get(getUri("/getMatch/$matchId"), headers: {"authorization": storageKey});
  return data;
}
