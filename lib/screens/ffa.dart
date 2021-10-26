import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/ffaMatchClass.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/timer_widget.dart';
import 'package:winhalla_app/utils/userClass.dart';

class SoloMatch extends StatelessWidget {
  final String matchId;

  const SoloMatch({Key? key, required this.matchId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder(
        future: http.get(getUri("/getMatch/$matchId"),
            headers: {"authorization": context.read<User>().value["authKey"]}),
        builder: (dynamic context, AsyncSnapshot<http.Response> res) {
          if (!res.hasData) {
            return const Center(
              child: Text(
                "Loading...",
                style: kHeadline1,
              ),
            );
          }
          return ChangeNotifierProvider<FfaMatch>(
            create: (ctxt) => FfaMatch(
                res.hasData ? jsonDecode(res.data!.body) : null, ctxt.read<User>().value["steam"]["id"]),
            child: Builder(builder: (context) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<FfaMatch>().refresh(context.read<User>().value["authKey"],context,showInfo: true);
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
                                numberOfSeconds: (((match.value["Date"] + 3600 * 1000) -
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
                      padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
                      child: Row(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Consumer<FfaMatch>(
                                builder: (context, match,_) {
                                  return Text("x${(match.value["userPlayer"]["multiplier"]/100).round()}", style: TextStyle(color: kGreen, fontSize: 34));
                                }
                              ),
                              SizedBox(
                                width: 9,
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 3.12),
                                child: Text(
                                  "Reward",
                                  style: TextStyle(color: kText, fontSize: 25),
                                ),
                              )
                            ],
                          ),
                          Container(
                              padding: const EdgeInsets.fromLTRB(19, 11.5, 19, 8.5),
                              child: Text(
                                "Boost it",
                                style: kBodyText4.apply(color: kBackground),
                              ),
                              decoration:
                                  BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(12)))
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
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "players in this match...",
                            style: kBodyText3,
                          ),
                          SizedBox(
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
                      if (match.areOtherPlayersShown && match.value["players"].length > 0)
                        return Padding(
                          padding: const EdgeInsets.only(top: 50),
                          child: ListView.builder(
                            itemBuilder: (context, int index) {
                              if (index.isOdd)
                                return const SizedBox(height: 39); //Spacing between each player card

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
                            physics: NeverScrollableScrollPhysics(),
                          ),
                        );
                      else
                        return Container();
                    }),
                    SizedBox(
                      height: 50,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(28, 22, 0, 24.5),
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
                                padding: EdgeInsets.fromLTRB(20, 7, 0, 0),
                                child: CustomPaint(
                                  size: Size(40, 105),
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
                                        text: TextSpan(style: kBodyText3, children: const [
                                          TextSpan(text: "Start "),
                                          TextSpan(text: "playing ", style: TextStyle(color: kPrimary)),
                                          TextSpan(text: "Brawlhalla! (only ranked games)")
                                        ]),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 19,
                                    ),
                                    SizedBox(
                                      width: 200,
                                      child: RichText(
                                        softWrap: true,
                                        text: TextSpan(style: kBodyText3, children: const [
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

class TipPainter extends CustomPainter {
  TipPainter({required this.color});

  final Color color;

  double degToRad(num deg) => (deg * (pi / 180.0)).toDouble();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = kText80
      // ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    double rectSize = 30;

    Path path = Path();
    path.moveTo(0, 0);

    path.arcTo(
        Rect.fromLTWH(
            0,
            -7,
            rectSize,
            rectSize),
        degToRad(180),
        degToRad(-90),
        false);
    path.lineTo(23, 23);
    // path.lineTo(20, currentHeight + rectSize);
    path.moveTo(0, 10);

    path.arcTo(
        Rect.fromLTWH(
            0,
            58.5,
            rectSize, // -0.15 just for pixel perfect
            rectSize),
        degToRad(180),
        degToRad(-90),
        false);
    path.lineTo(23, 88.5);
    canvas.drawPath(path, paint);
  }

  //5
  @override
  bool shouldRepaint(TipPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

class PlayerWidget extends StatelessWidget {
  PlayerWidget({
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
