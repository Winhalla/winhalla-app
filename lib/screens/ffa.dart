import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/timer_widget.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/ad_launch_button.dart';
import 'package:winhalla_app/widgets/popup_no_refresh.dart';
import 'package:winhalla_app/widgets/tip_painter.dart';

class SoloMatch extends StatefulWidget {
  final String matchId;
  const SoloMatch({Key? key, required this.matchId}) : super(key: key);

  @override
  State<SoloMatch> createState() => _SoloMatchState();
}

class _SoloMatchState extends State<SoloMatch> {
  bool _hasAlreadyInitAdmob = false;
  bool isAdReady = false;

  Future<void> _initGoogleMobileAds() async {
    if (!_hasAlreadyInitAdmob) {
      await MobileAds.instance.initialize();
      _hasAlreadyInitAdmob = true;
    }
    await InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          ad.show();
        },
        onAdFailedToLoad: (err) {
          print('Failed to load a rewarded ad: ${err.message}');
        },
      ),
    );
  }

  @override
  void initState() {
    User user = context.read<User>();

    if (widget.matchId != "tutorial" &&
        user.value["user"]["lastGames"].length > 2 &&
        user.inGame["isFromMatchHistory"] != true) {
        _initGoogleMobileAds();
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
                        const Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: Text('Solo Match', style: kHeadline1),
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
                    const SizedBox(
                      height: 35,
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: Row(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Consumer<FfaMatch>(builder: (context, match, _) {
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
                                context
                                    .read<User>()
                                    .setKeyFx(match.refresh, "refreshMatch");
                                if (match.value["finished"] == true) {
                                  return Text(
                                      "x${(match.value["userPlayer"]["multiplier"]).round()}",
                                      style: const TextStyle(
                                          color: kGreen, fontSize: 34));
                                }
                                return Text(
                                    "x${(match.value["userPlayer"]["multiplier"] / 100).round()}",
                                    style: const TextStyle(
                                        color: kGreen, fontSize: 34));
                              }),
                              const SizedBox(
                                width: 9,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 3),
                                child: Text(
                                  "Reward",
                                  style: TextStyle(color: kText, fontSize: 25),
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
                                  style: kBodyText4.apply(color: kText),
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
                                    style: kBodyText4.apply(color: kText),
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
                                        style: kBodyText4.apply(
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
                    const SizedBox(
                      height: 60,
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
                    const SizedBox(
                      height: 15,
                    ),
                    Consumer<FfaMatch>(builder: (context, match, _) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${match.value["players"].length}",
                            style: kBodyText3.apply(color: kPrimary),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "other player${match.value["players"].length > 1 ? "s" : ""} in this match...",
                            style: kBodyText3,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            child: Text(
                              match.areOtherPlayersShown ? "HIDE" : "SHOW",
                              style: kBodyText2.apply(
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
                    const SizedBox(
                      height: 50,
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
                              const Padding(
                                padding: EdgeInsets.only(top: 3.0),
                                child: Text(
                                  "You can",
                                  style: TextStyle(
                                    color: kText80,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.only(top: 3.0),
                                      child: Text(
                                        "TIP",
                                        style: TextStyle(
                                          color: kGreen,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Icon(
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
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      child: RichText(
                                        text: const TextSpan(
                                            style: kBodyText3,
                                            children: [
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
                                      height: 19,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: RichText(
                                        softWrap: true,
                                        text: const TextSpan(
                                            style: kBodyText3,
                                            children: [
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
                                ),
                              )
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
    required this.isUser,
    required this.avatarUrl,
    required this.games,
    this.wins,
    required this.name,
  });

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
                      const Padding(
                        padding: EdgeInsets.only(bottom: 1.5),
                        child: Text(
                          "Games played:",
                          style: TextStyle(color: kText, fontSize: 22),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        "$games/7",
                        style: TextStyle(
                            color: isUser ? kEpic : kPrimary, fontSize: 26),
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
                        const Padding(
                          padding: EdgeInsets.only(bottom: 1.5),
                          child: Text("Games won:",
                              style: TextStyle(color: kText, fontSize: 22)),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          "$wins/7",
                          style: const TextStyle(color: kEpic, fontSize: 26),
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
          child: Text(name, style: const TextStyle(color: kGray, fontSize: 19)),
        ),
      ],
      clipBehavior: Clip.none,
    );
  }
}
