import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/timer_widget.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/ad_launch_button.dart';
import 'package:winhalla_app/widgets/coin.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';
import 'package:winhalla_app/widgets/popup_no_refresh.dart';
import 'package:winhalla_app/widgets/tip_painter.dart';

class SoloMatch extends StatefulWidget {
  final String matchId;
  const SoloMatch({Key? key, required this.matchId}) : super(key: key);

  @override
  State<SoloMatch> createState() => _SoloMatchState();
}

class _SoloMatchState extends State<SoloMatch> {
  bool isAdReady = false;

  @override
  void initState() {
    User user = context.read<User>();
    if (widget.matchId != "tutorial" &&
        user.value["user"]["lastGames"].length >= 2 &&
        user.inGame["isFromMatchHistory"] != true) {
      user.showInterstitialAd();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: context.read<User>().callApi.get("/getMatch/${widget.matchId}"),
        builder: (BuildContext context, AsyncSnapshot res) {
          User user = context.read<User>();
          if (user.inGame["showActivity"] == false) {
            user.toggleShowMatch(false);
          }

          if (!res.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (res.data["successful"] == false) {
            Future.delayed(const Duration(milliseconds: 1),
                () => user.exitMatch(isOnlyLayout: true));

            return const Center(child: CircularProgressIndicator());
          }
          return ChangeNotifierProvider<FfaMatch>(
            create: (context) =>
                FfaMatch(res.data["data"], user.value["steam"]["id"]),
            child: Builder(builder: (BuildContext context) {
              return RefreshIndicator(
                onRefresh: () async {
                  var user = context.read<User>();
                  bool hasNotChanged = await context
                      .read<FfaMatch>()
                      .refresh(context, user, showInfo: true);
                  if (hasNotChanged &&
                      await getNonNullSSData("hideNoRefreshMatch") != "true") {
                    if (user.appBarKey.currentContext != null) {
                      showDialog(
                          context:
                              user.appBarKey.currentContext as BuildContext,
                          builder: (_) => NoRefreshPopup("match"));
                    }
                  }
                  return;
                },
                child: ListView(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text('Solo Match',
                              style: InheritedTextStyle.of(context).kHeadline1),
                        ),
                        Container(
                            decoration: BoxDecoration(
                                color: kBackgroundVariant,
                                borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.fromLTRB(25, 9, 25, 6),
                            child: Consumer<FfaMatch>(
                                builder: (context, match, _) {
                              return TimerWidget(
                                showHours: "no",
                                numberOfSeconds: (((match.value["userPlayer"]
                                                    ["joinDate"] +
                                                3600 * 1000) -
                                            DateTime.now()
                                                .millisecondsSinceEpoch) /
                                        1000)
                                    .round(),
                              );
                            }))
                      ],
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    ),
                    SizedBox(
                      height: 3.75.h,
                    ),

                    /*Container(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: Row(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Consumer<FfaMatch>(builder: (context, match, _) {


                                if (match.value["finished"] == true) {
                                  return Text(
                                      "x${(match.value["userPlayer"]["multiplier"]).round()}",
                                      style: InheritedTextStyle.of(context).kHeadline2.apply(color: kGreen)
                                  );
                                }
                                return Text(
                                    "x${(match.value["userPlayer"]["multiplier"] / 100).round()}",
                                    style: InheritedTextStyle.of(context).kHeadline2.apply(color: kGreen)
                                );
                              }),
                              const SizedBox(
                                width: 9,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  "Reward",
                                  style: InheritedTextStyle.of(context).kBodyText2.apply(color: kText, fontFamily: "Bebas neue"),
                                ),
                              )
                            ],
                          ),
                          Consumer<FfaMatch>(builder: (context, match, _) {
                            if (match.value["userPlayer"]["adsWatched"] >= 16) {
                              return Container(
                                padding: const EdgeInsets.fromLTRB(
                                    19, 11.5, 19, 8.5),
                                decoration: BoxDecoration(
                                    color: kText60,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                  "Max ads reached",
                                  style: InheritedTextStyle.of(context).kBodyText4.apply(color: kText),
                                ),
                              );
                            }
                            return AdButton(
                              goal: 'earnMoreSoloMatch',
                              adNotReadyChild: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      19, 11.5, 19, 8.5),
                                  child: Text(
                                    "Ad loading...",
                                    style: InheritedTextStyle.of(context).kBodyText4.apply(color: kText),
                                  ),
                                  decoration: BoxDecoration(
                                      color: kText60,
                                      borderRadius: BorderRadius.circular(12))),
                              adErrorChild: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      19, 11.5, 19, 8.5),
                                  child: Text(
                                    "Ad Error.",
                                    style: InheritedTextStyle.of(context).kBodyText4.apply(color: kText),
                                  ),
                                  decoration: BoxDecoration(
                                      color: kText60,
                                      borderRadius: BorderRadius.circular(12))),
                              child: Container(
                                  padding: const EdgeInsets.fromLTRB(
                                      19, 11.5, 19, 8.5),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2.0),
                                        child: Image.asset(
                                          "assets/images/video_ad.png",
                                          width: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 7,
                                      ),
                                      Text(
                                        "Boost it",
                                        style: InheritedTextStyle.of(context).kBodyText4.apply(
                                            color: kBackground),
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                      color: kGreen,
                                      borderRadius: BorderRadius.circular(12))),
                            );
                          })
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      decoration: BoxDecoration(
                          color: kBackgroundVariant,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    SizedBox(height: 2.h,),*/
                    Container(
                      padding: EdgeInsets.fromLTRB(6.w, 3.h, 6.w, 2.5.h),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1.45),
                                    child: Text("Estimated reward:",
                                        style: InheritedTextStyle.of(context)
                                            .kBodyText2
                                            .apply(
                                                fontSizeFactor: 0.95,
                                                color: kText90)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 1.95),
                                    child: Text("Based on current stats",
                                        style: InheritedTextStyle.of(context)
                                            .kBodyText3
                                            .apply(
                                                fontStyle: FontStyle.italic,
                                                fontSizeFactor: 0.8,
                                                color: kGray)),
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 3.65.w,
                              ),
                              Consumer<FfaMatch>(builder: (context, match, _) {
                                context
                                    .read<User>()
                                    .setKeyFx(match.refresh, "refreshMatch");
                                Future.delayed(const Duration(milliseconds: 1),
                                    () {
                                  bool hasExpiredTime =
                                      match.value["userPlayer"]["joinDate"] +
                                              3600 * 1000 <
                                          DateTime.now().millisecondsSinceEpoch;

                                  if (hasExpiredTime) {
                                    user.setGames(7);
                                  } else {
                                    user.setGames(match.value["userPlayer"]
                                        ["gamesPlayed"]);
                                  }

                                  if (user.inGame["showActivity"] == false &&
                                      (match.value["userPlayer"]
                                                  ["gamesPlayed"] <
                                              7 &&
                                          !hasExpiredTime)) {
                                    user.setMatchInProgress();
                                  }
                                });
                                return Coin(
                                  nb: match.value["estimatedReward"]["reward"]
                                      .toString(),
                                  color: kText,
                                  bgColor: kBlack,
                                  padding: EdgeInsets.fromLTRB(
                                      4.9.w, 1.3.h, 4.9.w, 0.85.h),
                                  fontSize: 28,
                                );
                              })
                            ],
                          ),
                          if(FirebaseRemoteConfig.instance.getBool("isAdButtonActivated") == true) SizedBox(
                            height: 2.2.h,
                          ),
                          if(FirebaseRemoteConfig.instance.getBool("isAdButtonActivated") == true) Padding(
                            padding: EdgeInsets.fromLTRB(.5.w, 0, .9.w, 0),
                            child: Container(
                              //padding: EdgeInsets.fromLTRB(1.w, 0, 1.w, 0),
                              decoration: BoxDecoration(
                                  color: kBlack,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Consumer<FfaMatch>(
                                            builder: (context, match, _) {
                                          if (match.value["finished"] == true) {
                                            return Text(
                                                "x${(match.value["userPlayer"]["multiplier"]).round()}",
                                                style: InheritedTextStyle.of(
                                                        context)
                                                    .kBodyText1Roboto
                                                    .apply(
                                                        color: kGreen,
                                                        fontSizeFactor: 0.825));
                                          }
                                          return Text(
                                              "x${(match.value["userPlayer"]["multiplier"] / 100).round()}",
                                              style:
                                                  InheritedTextStyle.of(context)
                                                      .kBodyText1Roboto
                                                      .apply(
                                                          color: kGreen,
                                                          fontSizeFactor:
                                                              0.825));
                                        }),
                                        SizedBox(
                                          width: 1.175.w,
                                        ),
                                        Padding(
                                          padding:
                                              EdgeInsets.only(bottom: 0.178.h),
                                          child: Text(
                                            "reward",
                                            style:
                                                InheritedTextStyle.of(context)
                                                    .kBodyText2
                                                    .apply(
                                                        fontSizeFactor: 0.8,
                                                        color: kText90),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Consumer<FfaMatch>(
                                      builder: (context, match, _) {
                                    if (match.value["userPlayer"]
                                            ["adsWatched"] >=
                                        16) {
                                      return Container(
                                        padding: const EdgeInsets.fromLTRB(
                                            19, 11.5, 19, 8.5),
                                        decoration: BoxDecoration(
                                            color: kText60,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Text(
                                          "Max ads reached",
                                          style: InheritedTextStyle.of(context)
                                              .kBodyText4
                                              .apply(color: kText),
                                        ),
                                      );
                                    }
                                    return AdButton(
                                      goal: 'earnMoreSoloMatch',
                                      adNotReadyChild: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              4.6.w, 1.55.h, 4.6.w, 1.25.h),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2.0),
                                                child: Image.asset(
                                                  "assets/images/video_ad.png",
                                                  width: 20,
                                                  color: kText95,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 1.9.w,
                                              ),
                                              Text(
                                                "Loading...",
                                                style: InheritedTextStyle.of(
                                                        context)
                                                    .kBodyText4
                                                    .apply(color: kText95),
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              color: kText60,
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      adErrorChild: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              4.6.w, 1.55.h, 4.6.w, 1.25.h),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2.0),
                                                child: Image.asset(
                                                  "assets/images/video_ad.png",
                                                  width: 20,
                                                  color: kText95,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 1.9.w,
                                              ),
                                              Text(
                                                "Error",
                                                style: InheritedTextStyle.of(
                                                        context)
                                                    .kBodyText4
                                                    .apply(color: kText95),
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              color: kText60,
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                      child: Container(
                                          padding: EdgeInsets.fromLTRB(
                                              4.6.w, 1.55.h, 4.6.w, 1.25.h),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    bottom: 2.0),
                                                child: Image.asset(
                                                  "assets/images/video_ad.png",
                                                  width: 20,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 1.9.w,
                                              ),
                                              Text(
                                                "Boost it",
                                                style: InheritedTextStyle.of(
                                                        context)
                                                    .kBodyText4
                                                    .apply(color: kBackground),
                                              ),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                              color: kGreen,
                                              borderRadius:
                                                  BorderRadius.circular(12))),
                                    );
                                  })
                                ],
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                              ),
                            ),
                          ),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: kBackgroundVariant,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                    SizedBox(
                      height: 7.25.h,
                    ),
                    Consumer<FfaMatch>(builder: (context, match, _) {
                      final player = match.value["userPlayer"];
                      return Container(
                        key: context.read<User>().keys[3],
                        child: PlayerWidget(
                          isUser: true,
                          avatarUrl: player["avatarURL"],
                          games: player["gamesPlayed"],
                          wins: player["wins"],
                          name: player["username"],
                        ),
                      );
                    }),
                    SizedBox(
                      height: 1.8.h,
                    ),
                    Consumer<FfaMatch>(builder: (context, match, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${match.value["players"].length}",
                            style: InheritedTextStyle.of(context)
                                .kBodyText3
                                .apply(color: kPrimary),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "other player${match.value["players"].length > 1 ? "s" : ""} in this match...",
                            style: InheritedTextStyle.of(context).kBodyText3,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            child: Text(
                              match.areOtherPlayersShown ? "HIDE" : "SHOW",
                              style: InheritedTextStyle.of(context)
                                  .kBodyText2
                                  .apply(
                                      fontFamily: "Bebas Neue", color: kText80),
                            ),
                            onTap: () {
                              match.togglePlayerShown();
                            },
                            behavior: HitTestBehavior.translucent,
                          )
                        ],
                      );
                    }),
                    Consumer<FfaMatch>(builder: (context, match, _) {
                      if (match.areOtherPlayersShown &&
                          match.value["players"].length > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: ListView.builder(
                            itemBuilder: (context, int index) {
                              final player = match.value["players"][index];
                              return Padding(
                                padding:
                                    EdgeInsets.only(top: index == 0 ? 0 : 22.0),
                                child: PlayerWidget(
                                  isUser: false,
                                  avatarUrl: player["avatarURL"],
                                  games: player["gamesPlayed"],
                                  name: player["username"],
                                ),
                              );
                            },
                            itemCount: match.value["players"].length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                          ),
                        );
                      } else {
                        return Container();
                      }
                    }),
                    SizedBox(
                      height: 6.1.h,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(28, 22, 0, 24.5),
                      decoration: BoxDecoration(
                        color: kBackgroundVariant,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text("You can",
                                    style: InheritedTextStyle.of(context)
                                        .kBodyText2bis
                                        .apply(color: kText80)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: Text("TIP",
                                          style: InheritedTextStyle.of(context)
                                              .kBodyText2bis
                                              .apply(color: kGreen)),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Icon(
                                      Icons.lightbulb_outline_sharp,
                                      color: kGreen,
                                    )
                                  ],
                                ),
                              )
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(20, 7, 0, 0),
                                child: CustomPaint(
                                  size: const Size(40, 105),
                                  painter: TipPainter(color: kText), //3
                                ),
                              ),
                              Padding(
                                  padding: const EdgeInsets.only(top: 18.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 28.h,
                                        child: RichText(
                                          text: TextSpan(
                                              style:
                                                  InheritedTextStyle.of(context)
                                                      .kBodyText3,
                                              children: const [
                                                TextSpan(text: "Start "),
                                                TextSpan(
                                                    text: "playing ",
                                                    style: TextStyle(
                                                        color: kPrimary)),
                                                TextSpan(
                                                    text:
                                                        "Brawlhalla! (only ranked games)")
                                              ]),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      SizedBox(
                                        width: 28.h,
                                        child: RichText(
                                          softWrap: true,
                                          text: TextSpan(
                                              style:
                                                  InheritedTextStyle.of(context)
                                                      .kBodyText3,
                                              children: const [
                                                TextSpan(
                                                    text: "Drag down ",
                                                    style: TextStyle(
                                                        color: kPrimary)),
                                                TextSpan(text: "to "),
                                                TextSpan(
                                                    text: "sync ",
                                                    style: TextStyle(
                                                        color: kPrimary)),
                                                TextSpan(text: "your stats"),
                                              ]),
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}

class PlayerWidget extends StatelessWidget {
  const PlayerWidget({
    Key? key,
    required this.isUser,
    required this.avatarUrl,
    required this.games,
    this.wins,
    required this.name,
  }) : super(key: key);

  final bool isUser;
  final String avatarUrl;
  final int games;
  final int? wins;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding:
              EdgeInsets.fromLTRB(35, isUser ? 25 : 18, 35, isUser ? 25 : 18),
          child: Row(
            children: [
              SizedBox(
                width: isUser ? 72 : 60,
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Image.network(avatarUrl)),
              ),
              Column(
                key: isUser ? context.read<User>().keys[6] : null,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1.5),
                        child: Text(
                          "Games played:",
                          style: InheritedTextStyle.of(context)
                              .kBodyText2bis
                              .apply(color: kText),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "$games/7",
                        style: InheritedTextStyle.of(context)
                            .kBodyText1bis
                            .apply(color: isUser ? kEpic : kPrimary),
                      )
                    ],
                    crossAxisAlignment: CrossAxisAlignment.end,
                  ),
                  const SizedBox(
                    height: 2.5,
                  ),
                  if (isUser == true)
                    Row(
                      children: [
                        Padding(
                            padding: const EdgeInsets.only(bottom: 1.5),
                            child: Text(
                              "Games won:",
                              style: InheritedTextStyle.of(context)
                                  .kBodyText2bis
                                  .apply(color: kText),
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "$wins/7",
                          style: InheritedTextStyle.of(context)
                              .kBodyText1bis
                              .apply(color: kEpic),
                        )
                      ],
                      crossAxisAlignment: CrossAxisAlignment.end,
                    )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
          ),
          decoration: BoxDecoration(
            color: kBackgroundVariant,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        Positioned(
          left: 35,
          bottom: isUser ? 110 : 83.5,
          child: Text(name, style: InheritedTextStyle.of(context).kBodyText4),
        ),
      ],
      clipBehavior: Clip.none,
    );
  }
}
