import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/timer_widget.dart';
import 'package:winhalla_app/utils/user_class.dart';
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
      future: context.read<User>().initQuestsData(),
      builder: (BuildContext context,AsyncSnapshot res)  {
        if(!res.hasData) {
          return const Center(
              child: CircularProgressIndicator(),
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            await context.read<User>().refreshQuests(context,showInfo: true);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 14),
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
                    Consumer<User>(
                      builder: (context, user,_) {
                        if(user.quests["dailyQuests"].length < 1) return Container();
                        return Container(
                          decoration:
                              BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.fromLTRB(25, 9, 25, 7.5),
                          child: TimerWidget(
                                showHours: "hours",
                                numberOfSeconds:
                                    (((user.quests["lastDaily"] + 86400000) - DateTime.now().millisecondsSinceEpoch) /
                                            1000)
                                        .round(),
                              )
                        );
                      }
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Consumer<User>(
                builder: (context, user,_) {
                  if(user.quests["dailyQuests"].length<1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom:50.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color:kBackgroundVariant),
                            padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
                            child: Column(
                              children: [
                                const Text("New quests in:",style: kBodyText1,),
                                const SizedBox(height: 5,),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(20, 9, 20, 9),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),color: kBackground),
                                  child: TimerWidget(
                                      fontSize:35,
                                      numberOfSeconds:
                                      (((user.quests["lastDaily"] + 86400000) - DateTime.now().millisecondsSinceEpoch) /1000).round(),
                                      showHours: "hours"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 78.0),
                    child: ListView.builder(
                      itemBuilder: (context, int index) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){
                            user.collectQuest(
                                user.quests["dailyQuests"][index]["id"],
                                "daily",
                                user.quests["dailyQuests"][index]["reward"]);
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: index != 0 ? 30.0 : 0),
                            child: QuestWidget(
                                name: user.quests["dailyQuests"][index]["name"],
                                color: _getColorFromPrice(user.quests["dailyQuests"][index]["reward"], "weekly"),
                                progress: user.quests["dailyQuests"][index]["progress"],
                                goal: user.quests["dailyQuests"][index]["goal"]),
                          ),
                        );
                      },
                      itemCount: user.quests["dailyQuests"].length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  );
                }
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
                    Consumer<User>(
                        builder: (context, user,_) {
                          if(user.quests["weeklyQuests"].length < 1) return Container();
                          return Container(
                              decoration:
                              BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.fromLTRB(25, 9, 25, 7.5),
                              child: TimerWidget(
                                showHours: "days",
                                numberOfSeconds:
                                (((user.quests["lastWeekly"] + 86400000*7) - DateTime.now().millisecondsSinceEpoch) /
                                    1000)
                                    .round(),
                              )
                          );
                        }
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Consumer<User>(
                  builder: (context, user,_) {
                    if(user.quests["weeklyQuests"].length<1) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),color:kBackgroundVariant),
                            padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
                            child: Column(
                              children: [
                                const Text("New quests in:",style: kBodyText1,),
                                const SizedBox(height: 5,),
                                Container(
                                  padding: const EdgeInsets.fromLTRB(20, 9, 20, 9),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(14),color: kBackground),
                                  child: TimerWidget(
                                      fontSize:35,
                                      numberOfSeconds:
                                      (((user.quests["lastWeekly"] + 86400000*7) - DateTime.now().millisecondsSinceEpoch) /1000).round(),
                                      showHours: "days"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }
                    return ListView.builder(
                      itemBuilder: (context, int index) {
                        return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: (){
                            user.collectQuest(
                                user.quests["weeklyQuests"][index]["id"],
                                "weekly",
                                user.quests["weeklyQuests"][index]["reward"]);
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: index != 0 ? 30.0 : 0),
                            child: QuestWidget(
                                name: user.quests["weeklyQuests"][index]["name"],
                                color: _getColorFromPrice(user.quests["weeklyQuests"][index]["reward"], "weekly"),
                                progress: user.quests["weeklyQuests"][index]["progress"],
                                goal: user.quests["weeklyQuests"][index]["goal"]),
                          ),
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
