import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/utils/ffaMatchClass.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/getUri.dart';
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
                  await context.read<FfaMatch>().refresh(context.read<User>().value["authKey"]);
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
                            child: Consumer<FfaMatch>(
                              builder: (context, match,_) {
                                return TimerWidget(
                                  numberOfSeconds: (((match.value["Date"]+3600*1000)-DateTime.now().millisecondsSinceEpoch)/1000).round(),
                                );
                              }
                            ))
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
                            children: const [
                              Text("x4", style: TextStyle(color: kGreen, fontSize: 34)),
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
                      height: 56,
                    ),
                    Column(
                      children: [
                        Consumer<FfaMatch>(builder: (context, match, _) {
                          return ListView.builder(
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
                          );
                        })
                      ],
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

class TimerWidget extends StatefulWidget {
  final int numberOfSeconds;

  const TimerWidget({Key? key, required this.numberOfSeconds}) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  String timer = "";
  bool alreadyBuilt = false;
  Color color = kPrimary;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    int minutes = (widget.numberOfSeconds / 60).floor();
    int seconds = widget.numberOfSeconds % 60;
    void timerFx(Timer? cancel) {
      if (seconds == 0 && minutes == 0) {
        setState(() {
          timer = "00:00";
          color = kRed;
        });
        if (cancel != null) cancel.cancel();
        return;
      } else if (seconds == 0) {
        seconds = 59;
        minutes -= 1;
      } else {
        seconds -= 1;
      }

      if (minutes < 10)
        timer = "0$minutes";
      else
        timer = "$minutes";

      if (seconds < 10)
        timer += ":0$seconds";
      else
        timer += ":$seconds";

      setState(() {
        timer = timer;
      });
    }
    Timer _timer = new Timer.periodic(oneSec, timerFx);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext context) {
      if (alreadyBuilt == false) {
        alreadyBuilt = true;
        startTimer();
      }
      return Text(
        timer==""?"Loading...":timer,
        style: TextStyle(color: color, fontSize: 35),
      );
    });
  }
}
