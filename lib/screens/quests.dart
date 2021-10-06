import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/userClass.dart';
import 'package:winhalla_app/widgets/quest_widget.dart';

class Quests extends StatelessWidget {
  const Quests({Key? key}) : super(key: key);

  Color _getColorFromPrice(price, type) {
    if (type == "daily") {
      switch (price) {
        case 10:
          return kPrimary;
        case 20:
          return kEpic;
        case 30:
          return kRed;
        default:
          return kPrimary;
      }
    } else {
      switch (price) {
        case 50:
          return kPrimary;
        case 100:
          return kEpic;
        case 200:
          return kRed;
        default:
          return kPrimary;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, _) {
      var userData = user.value["user"]["solo"];

      return RefreshIndicator(
        onRefresh: () async {
          await user.refreshQuests();
        },
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Daily Quests', style: kHeadline1),
                  ),
                  Container()
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ListView.builder(
              itemBuilder: (context, int index) {
                return Container(
                  margin: EdgeInsets.only(bottom: index != 2 - 1 ? 30.0 : 0),
                  child: QuestWidget(
                      name: userData["dailyQuests"][index]["name"],
                      color: _getColorFromPrice(userData["dailyQuests"][index]["reward"], "weekly"),
                      progress: userData["dailyQuests"][index]["progress"],
                      goal: userData["dailyQuests"][index]["goal"]),
                );
              },
              itemCount: userData["dailyQuests"].length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
            const SizedBox(
              height: 78,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text('Weekly Quests', style: kHeadline1),
                  ),
                  Container()
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ListView.builder(
              itemBuilder: (context, int index) {
                return Container(
                  margin: EdgeInsets.only(bottom: index != 2 - 1 ? 30.0 : 0),
                  child: QuestWidget(
                      name: userData["weeklyQuests"][index]["name"],
                      color: _getColorFromPrice(userData["weeklyQuests"][index]["reward"], "weekly"),
                      progress: userData["weeklyQuests"][index]["progress"],
                      goal: userData["weeklyQuests"][index]["goal"]),
                );
              },
              itemCount: userData["weeklyQuests"].length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            ),
          ],
        ),
      );
    });
  }
}
