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
/*

*/
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.read<User>().getQuestsData(),
      builder: (BuildContext context,AsyncSnapshot res)  {
        if(!res.hasData) {
          return Center(
              child: CircularProgressIndicator(),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<User>().refreshQuests(context,showInfo: true);
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
                      child: Consumer<User>(
                        builder: (context, user,_) {
                          return TimerWidget(
                            showHours: "hours",
                            numberOfSeconds:
                                (((user.quests["lastDaily"] + 86400000) - DateTime.now().millisecondsSinceEpoch) /
                                        1000)
                                    .round(),
                          );
                        }
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Consumer<User>(
                builder: (context, user,_) {
                  return ListView.builder(
                    itemBuilder: (context, int index) {
                      return Container(
                        margin: EdgeInsets.only(top: index != 0 ? 30.0 : 0),
                        child: QuestWidget(
                            name: user.quests["dailyQuests"][index]["name"],
                            color: _getColorFromPrice(user.quests["dailyQuests"][index]["reward"], "weekly"),
                            progress: user.quests["dailyQuests"][index]["progress"],
                            goal: user.quests["dailyQuests"][index]["goal"]),
                      );
                    },
                    itemCount: user.quests["dailyQuests"].length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  );
                }
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
                        child: Consumer<User>(
                          builder: (context, user,_) {
                            return TimerWidget(
                                showHours: "days",
                                numberOfSeconds: (((user.quests["lastWeekly"] + 86400000 * 7) -
                                            DateTime.now().millisecondsSinceEpoch) /
                                        1000)
                                    .round());
                          }
                        ))
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Consumer<User>(
                builder: (context, user,_) {
                  return ListView.builder(
                    itemBuilder: (context, int index) {
                      return Container(
                        margin: EdgeInsets.only(top: index != 0 ? 30.0 : 0),
                        child: QuestWidget(
                            name: user.quests["weeklyQuests"][index]["name"],
                            color: _getColorFromPrice(user.quests["weeklyQuests"][index]["reward"], "weekly"),
                            progress: user.quests["weeklyQuests"][index]["progress"],
                            goal: user.quests["weeklyQuests"][index]["goal"]),
                      );
                    },
                    itemCount: user.quests["weeklyQuests"].length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  );
                }
              ),
            ],
          ),
        );
    });
  }
}
