import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/timer_widget.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/ad_launch_button.dart';
import 'package:winhalla_app/widgets/popup_no_refresh.dart';
import 'package:winhalla_app/widgets/tip_painter.dart';

class SoloMatch extends StatelessWidget {
  final String matchId;

  const SoloMatch({Key? key, required this.matchId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: context.read<User>().callApi.get("/getMatch/$matchId"),
        builder: (BuildContext context, AsyncSnapshot res) {
          if (!res.hasData) {
            return const Center(
                child: CircularProgressIndicator()
            );
          }
          if(res.data["successful"] == false){
            return const Center(
              child: CircularProgressIndicator()
            );
          }
          return ChangeNotifierProvider<FfaMatch>(
            create: (context) => FfaMatch(res.data["data"], context.read<User>().value["steam"]["id"]),
            child: Builder(builder: (context) {
              return RefreshIndicator(
                onRefresh: () async {
                  var user = context.read<User>();
                  bool hasNotChanged = await context.read<FfaMatch>().refresh(context, user, showInfo: true);
                  print(hasNotChanged);
                  if(hasNotChanged && await getNonNullSSData("hideNoRefreshMatch") != "true") showDialog(context: context, builder: (_)=>NoRefreshPopup("match"));
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
                                color: kBackgroundVariant, borderRadius: BorderRadius.circular(14)),
                            padding: const EdgeInsets.fromLTRB(25, 9, 25, 6),
                            child: Consumer<FfaMatch>(builder: (context, match, _) {
                              return TimerWidget(
                                showHours: "no",
                                numberOfSeconds: (((match.value["userPlayer"]["joinDate"] + 3600 * 1000) -
                                            DateTime.now().millisecondsSinceEpoch) /
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
                              Consumer<FfaMatch>(
                                builder: (context, match,_) {
                                  return Text("x${(match.value["userPlayer"]["multiplier"]/100).round()}", style: const TextStyle(color: kGreen, fontSize: 34));
                                }
                              ),
                              const SizedBox(
                                width: 9,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 3.12),
                                child: Text(
                                  "Reward",
                                  style: TextStyle(color: kText, fontSize: 25),
                                ),
                              )
                            ],
                          ),
                          AdButton(
                            goal: 'earnMoreSoloMatch',
                            adNotReadyChild:Container(
                                padding: const EdgeInsets.fromLTRB(19, 11.5, 19, 8.5),
                                child: Text(
                                  "Ad loading...",
                                  style: kBodyText4.apply(color: kText),
                                ),
                                decoration:
                                BoxDecoration(color: kText60, borderRadius: BorderRadius.circular(12))),
                            child: Container(
                                padding: const EdgeInsets.fromLTRB(19, 11.5, 19, 8.5),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(bottom:2.0),
                                      child: Image.asset("assets/images/video_ad.png", width: 20,),
                                    ),
                                    const SizedBox(width: 7,),
                                    Text(
                                      "Boost it",
                                      style: kBodyText4.apply(color: kBackground),
                                    ),
                                  ],
                                ),
                                decoration:
                                    BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(12))),
                          )
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                      decoration:
                          BoxDecoration(color: kBackgroundVariant, borderRadius: BorderRadius.circular(20)),
                    ),
                    const SizedBox(
                      height: 60,
                    ),
                    Consumer<FfaMatch>(builder: (context, match, _) {
                      final player = match.value["userPlayer"];
                      return PlayerWidget(
                        isUser: true,
                        avatarUrl: player["avatarURL"],
                        games: player["gamesPlayed"],
                        wins: player["wins"],
                        name: player["username"],
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
                          const Text(
                            "players in this match...",
                            style: kBodyText3,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            child: Text(
                              match.areOtherPlayersShown ? "HIDE" : "SHOW",
                              style: kBodyText2.apply(fontFamily: "Bebas Neue", color: kText80),
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
                      if (match.areOtherPlayersShown && match.value["players"].length > 0) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: ListView.builder(
                            itemBuilder: (context, int index) {
                              if (index.isOdd) {
                                return const SizedBox(height: 39);
                              } //Spacing between each player card

                              final player = match.value["players"][index];
                              return PlayerWidget(
                                isUser: false,
                                avatarUrl: player["avatarURL"],
                                games: player["gamesPlayed"],
                                name: player["username"],
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
                                        text: const TextSpan(style: kBodyText3, children: [
                                          TextSpan(text: "Start "),
                                          TextSpan(text: "playing ", style: TextStyle(color: kPrimary)),
                                          TextSpan(text: "Brawlhalla! (only ranked games)")
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
                                        text: const TextSpan(style: kBodyText3, children: [
                                          TextSpan(text: "Drag down ", style: TextStyle(color: kPrimary)),
                                          TextSpan(text: "to "),
                                          TextSpan(text: "sync ", style: TextStyle(color: kPrimary)),
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
          padding: EdgeInsets.fromLTRB(35, isUser ? 25 : 18, 35, isUser ? 25 : 18),
          child: Row(
            children: [
              SizedBox(
                width: isUser ? 72 : 60,
                child: ClipRRect(borderRadius: BorderRadius.circular(11), child: Image.network(avatarUrl)),
              ),
              Column(
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
                        style: TextStyle(color: isUser ? kEpic : kPrimary, fontSize: 26),
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
                          child: Text("Games won:", style: TextStyle(color: kText, fontSize: 22)),
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
