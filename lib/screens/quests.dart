import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/timer_widget.dart';
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
      if (user.value["user"]["solo"]["lastDaily"] == null || user.value["user"]["solo"]["lastWeekly"] == null){
        user.refreshQuests(context,showInfo:false);
        return Center(child: CircularProgressIndicator());
      }

      userData["dailyQuests"].addAll(userData["finished"]["daily"]);
      userData["weeklyQuests"].addAll(userData["finished"]["weekly"]);
      return RefreshIndicator(
        onRefresh: () async {
          await user.refreshQuests(context,showInfo: true);
        },
        child: ListView(
          padding: EdgeInsets.only(bottom: 14),
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8.0, 3, 0, 0),
                    child: Text('Daily', style: kHeadline1),
                  ),
                  Container(
                    decoration:
                        BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.fromLTRB(25, 9, 25, 7.5),
                    child: TimerWidget(
                      showHours: "hours",
                      numberOfSeconds:
                          (((userData["lastDaily"] + 86400000) - DateTime.now().millisecondsSinceEpoch) /
                                  1000)
                              .round(),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ListView.builder(
              itemBuilder: (context, int index) {
                return Container(
                  margin: EdgeInsets.only(top: index != 0 ? 30.0 : 0),
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
                    padding: EdgeInsets.fromLTRB(8.0, 3.5, 0, 0),
                    child: Text('Weekly', style: kHeadline1),
                  ),
                  Container(
                      decoration:
                          BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.fromLTRB(25, 9, 25, 7.5),
                      child: TimerWidget(
                          showHours: "days",
                          numberOfSeconds: (((userData["lastWeekly"] + 86400000 * 7) -
                                      DateTime.now().millisecondsSinceEpoch) /
                                  1000)
                              .round()))
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            ListView.builder(
              itemBuilder: (context, int index) {
                return Container(
                  margin: EdgeInsets.only(top: index != 0 ? 30.0 : 0),
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
