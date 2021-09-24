import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';

class FfaMatch extends ChangeNotifier{
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

  FfaMatch(matchData){
    this.value = matchData;
    notifyListeners();
  }
}