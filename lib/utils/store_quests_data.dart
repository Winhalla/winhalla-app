import 'dart:convert';

import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/widgets/quest_widget.dart';

storeQuestsData(questsData) async {
  //store quests data (progress and name) in secure storage
  return await secureStorage.write(
      key: "questsData",
      value: jsonEncode({
        "dailyQuests": questsData["dailyQuests"]
            .map((q) => {"name": q["name"], "progress": q["progress"]})
            .toList(),
        "weeklyQuests": questsData["weeklyQuests"]
            .map((q) => {"name": q["name"], "progress": q["progress"]})
            .toList(),
      }));
}
