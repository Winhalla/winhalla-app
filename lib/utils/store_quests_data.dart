import 'dart:convert';

import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/widgets/quest_widget.dart';

storeQuestsData(questsData) {
  //store quests data (progress and name) in secure storage
  Map<String, dynamic> writtenValue = {
    "dailyQuests": questsData["dailyQuests"]
        .map((q) => {"name": q["name"], "progress": q["progress"]})
        .toList(),
    "weeklyQuests": questsData["weeklyQuests"]
        .map((q) => {"name": q["name"], "progress": q["progress"]})
        .toList(),
  };
  secureStorage.write(
    key: "questsData",
    value: jsonEncode(writtenValue));
  return writtenValue;
}
