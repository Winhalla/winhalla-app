import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/timer_widget.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';
import 'package:winhalla_app/widgets/popup_no_refresh.dart';
import 'package:winhalla_app/widgets/quest_widget.dart';
import 'package:winhalla_app/widgets/quick_earn_ad_prompt.dart';

class Quests extends StatefulWidget {
  const Quests({Key? key}) : super(key: key);

  @override
  State<Quests> createState() => _QuestsState();
}

class _QuestsState extends State<Quests> {
  RewardedAd? nextAd;
  @override
  void initState() {
    super.initState();
    reloadAd();
  }
  void reloadAd(){
    loadApplovinRewarded((ad) {
      context.read<User>().setNextAdQuests(ad);
      FirebaseAnalytics.instance.logEvent(
        name: "ShowQuestReroll",
      );
    },);
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: context.read<User>().initQuestsData(),
        builder: (BuildContext context, AsyncSnapshot res) {
          if (!res.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              var showNoRefreshQuests = await context.read<User>().refreshQuests(context, showInfo: true);

              if (showNoRefreshQuests == true &&
                  await getNonNullSSData("hideNoRefreshQuests") != "true") {
                showDialog(
                    context: context, builder: (_) => NoRefreshPopup("quests"));
              }
            },
            child: ListView(
              padding: const EdgeInsets.only(bottom: 14),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 3, 0, 0),
                        child: Text('Daily', style: InheritedTextStyle.of(context).kHeadline1),
                      ),
                      Consumer<User>(builder: (context, user, _) {
                        if (user.quests["dailyQuests"].length < 1) {
                          return Container();
                        }
                        return Container(
                            decoration: BoxDecoration(
                                color: kBackgroundVariant,
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.fromLTRB(25, 9, 25, 7.5),
                            child: TimerWidget(
                              showHours: "hours",
                              numberOfSeconds:
                                  (((user.quests["lastDaily"] + 86400000) -
                                              DateTime.now()
                                                  .millisecondsSinceEpoch) /
                                          1000)
                                      .round(),
                            ));
                      })
                    ],
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Consumer<User>(builder: (context, user, _) {
                  WidgetsBinding.instance?.addPostFrameCallback((_){
                    user.refreshOldQuestsData();
                  });
                  if (user.quests["dailyQuests"].length < 1) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: kBackgroundVariant),
                            padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
                            child: Column(
                              children: [
                                Text(
                                  "New quests in:",
                                  style: InheritedTextStyle.of(context).kBodyText1,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 9, 20, 9),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      color: kBackground),
                                  child: TimerWidget(
                                      fontSize: 35,
                                      numberOfSeconds: (((user
                                                          .quests["lastDaily"] +
                                                      86400000) -
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch) /
                                              1000)
                                          .round(),
                                      showHours: "hours"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  bool isCollectingQuestDaily = false;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 78.0),
                    child: ListView.builder(
                      key: user.keys[9],
                      itemBuilder: (context, int index) {
                        return GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              if (isCollectingQuestDaily == true) return;
                              isCollectingQuestDaily = true;
                              try {
                                if (user.quests["dailyQuests"][index]
                                        ["progress"] >=
                                    user.quests["dailyQuests"][index]["goal"]) {
                                  await user.collectQuest(
                                      user.quests["dailyQuests"][index]["id"],
                                      "daily",
                                      user.quests["dailyQuests"][index]
                                          ["reward"]);
                                }
                                isCollectingQuestDaily = false;
                              } catch (e) {
                                isCollectingQuestDaily = false;
                              }
                            },
                            child: Container(
                              margin:
                                  EdgeInsets.only(top: index != 0 ? 30.0 : 0),
                              child: QuestWidget(
                                key: index == 0 ? user.keys[12] : null,
                                reward: user.quests["dailyQuests"][index]
                                    ["reward"],
                                name: user.quests["dailyQuests"][index]["name"],
                                color: _getColorFromPrice(
                                    user.quests["dailyQuests"][index]["reward"],
                                    "daily"),
                                progress: user.quests["dailyQuests"][index]
                                    ["progress"],
                                goal: user.quests["dailyQuests"][index]["goal"],
                                oldProgress: user.oldQuestsData["dailyQuests"]
                                            .firstWhere(
                                              (q) =>
                                                  q["name"] ==
                                                  user.quests["dailyQuests"]
                                                      [index]["name"],
                                              orElse:()=>{"progress":0}
                                            )["progress"],
                                questId: user.quests["dailyQuests"][index]["_id"],
                                reloadAd:reloadAd

                              ),
                            ));
                      },
                      itemCount: user.quests["dailyQuests"].length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6.0, 3, 0, 0),
                        child: Text('Weekly', style: InheritedTextStyle.of(context).kHeadline1),
                      ),
                      Consumer<User>(builder: (context, user, _) {
                        if (user.quests["weeklyQuests"].length < 1) {
                          return Container();
                        }
                        return Container(
                            decoration: BoxDecoration(
                                color: kBackgroundVariant,
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.fromLTRB(25, 9, 25, 7.5),
                            child: TimerWidget(
                              showHours: "days",
                              numberOfSeconds:
                                  (((user.quests["lastWeekly"] + 86400000 * 7) -
                                              DateTime.now()
                                                  .millisecondsSinceEpoch) /
                                          1000)
                                      .round(),
                            ));
                      })
                    ],
                  ),
                ),
                const SizedBox(
                  height: 33,
                ),
                Consumer<User>(builder: (context, user, _) {
                  if (user.quests["weeklyQuests"].length < 1) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: kBackgroundVariant),
                          padding: const EdgeInsets.fromLTRB(35, 20, 35, 20),
                          child: Column(
                            children: [
                              Text(
                                "New quests in:",
                                style: InheritedTextStyle.of(context).kBodyText1,
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Container(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 9, 20, 9),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                    color: kBackground),
                                child: TimerWidget(
                                    fontSize: 35,
                                    numberOfSeconds: (((user
                                                        .quests["lastWeekly"] +
                                                    86400000 * 7) -
                                                DateTime.now()
                                                    .millisecondsSinceEpoch) /
                                            1000)
                                        .round(),
                                    showHours: "days"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  bool isCollectingQuestWeekly = false;
                  return ListView.builder(
                    itemBuilder: (context, int index) {
                      return GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            if (isCollectingQuestWeekly == true) return;
                            isCollectingQuestWeekly = true;
                            try {
                              if (user.quests["weeklyQuests"][index]
                                      ["progress"] >=
                                  user.quests["weeklyQuests"][index]["goal"]) {
                                await user.collectQuest(
                                    user.quests["weeklyQuests"][index]["id"],
                                    "weekly",
                                    user.quests["weeklyQuests"][index]
                                        ["reward"]);
                              }
                              isCollectingQuestWeekly = false;
                            } catch (e) {
                              isCollectingQuestWeekly = false;
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: index != 0 ? 30.0 : 0),
                            child: QuestWidget(
                              reward: user.quests["weeklyQuests"][index]
                                  ["reward"],
                              name: user.quests["weeklyQuests"][index]["name"],
                              color: _getColorFromPrice(
                                  user.quests["weeklyQuests"][index]["reward"],
                                  "weekly"),
                              progress: user.quests["weeklyQuests"][index]
                                  ["progress"],
                              goal: user.quests["weeklyQuests"][index]["goal"],
                              oldProgress: user.oldQuestsData["weeklyQuests"].firstWhere(
                                    (q) => q["name"] == user.quests["weeklyQuests"][index]["name"],
                                    orElse: () => {"progress": 0}) ["progress"],
                                questId: user.quests["weeklyQuests"][index]["_id"],

                              reloadAd:reloadAd
                            ),
                          ));
                    },
                    itemCount: user.quests["weeklyQuests"].length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                  );
                }),
              ],
            ),
          );
        });
  }
}

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