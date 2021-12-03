import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/ffa.dart';
import 'package:winhalla_app/utils/user_class.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, _) {
      return user.inGame == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 6, top: 4.5),
                  child: Text(
                    "Match History:",
                    style: kHeadline1,
                  ),
                ),
                const SizedBox(
                  height: 34,
                ),
                Consumer<User>(builder: (context, user, _) {
                  var filteredInGameList = user.value["user"]["inGame"];
                      /*.where((g) => g["nbOfUsersFinishing"] > 0 ? true : false)
                      .toList();*/

                  var lastGames = user.value["user"]["lastGames"];
                  var lastWidget;

                  return Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: lastGames.length + filteredInGameList.length,
                        itemBuilder: (BuildContext context, int index) {
                          var mergedArray = List.from(filteredInGameList)
                            ..addAll(lastGames.reversed);
                          var currentMatch = mergedArray[index];

                          //if last widget is an "in game" tile, AND this one is a "match history" tile, set lastWidget to separator
                          lastWidget = currentMatch["wins"] != null &&
                                  lastWidget == false
                              ? "separator"
                              : currentMatch["wins"] != null
                                  ? true
                                  : false;
                          if(currentMatch["nbOfUsersFinishing"] == 0) currentMatch["nbOfUsersFinishing"] = 1;
                          return Container(
                            key: index == 0 ? user.keys[7] : null,
                            decoration: BoxDecoration(
                                color: kBackgroundVariant,
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                            margin: EdgeInsets.only(
                                left: 10,
                                right: 15,
                                top: lastWidget == "separator"
                                    ? 30
                                    : index == 0
                                        ? 0
                                        : 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: currentMatch["wins"] == null
                                  ? [
                                      RichText(
                                        softWrap: true,
                                        text: TextSpan(
                                            style: kBodyText2.apply(
                                                color: kText80),
                                            children: [
                                              const TextSpan(text: "Waiting "),
                                              TextSpan(
                                                  text: currentMatch["nbOfUsersFinishing"].toString(),
                                                  style: const TextStyle(
                                                      color: kPrimary)),
                                              TextSpan(
                                                  text: " player${currentMatch["nbOfUsersFinishing"] > 1 ? "s" :""}..."),
                                            ]),
                                      ),
                                      Row(
                                        children: [
                                          const Text(
                                            "x",
                                            style: TextStyle(
                                                color: kGreen,
                                                fontSize: 24,
                                                fontFamily: 'Roboto Condensed'),
                                          ),
                                          const SizedBox(width: 1.5),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: .5),
                                            child: Text(
                                                "${(currentMatch["multiplier"]/100).round()}",
                                                style: const TextStyle(
                                                    color: kGreen,
                                                    fontSize: 28)),
                                          ),
                                        ],
                                      )
                                    ]
                                  : [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 2.85),
                                            child: Text(
                                              "${currentMatch["coinsEarned"]}",
                                              style: kBodyText1.apply(
                                                  color: kPrimary),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 6,
                                          ),
                                          Image.asset(
                                            "assets/images/logo.png",
                                            width: 34,
                                          )
                                        ],
                                      ),
                                      Text(
                                        currentMatch["id"] == "tutorial"
                                            ? "tutorial"
                                            : "${currentMatch["wins"]}/7 wins",
                                        style: kBodyText2.apply(
                                            color: kGray,
                                            fontFamily: "Bebas neue"),
                                      ),
                                      Text(
                                        "#${currentMatch["rank"] + 1}",
                                        style: kBodyText1.apply(
                                            fontFamily: "Bebas neue"),
                                      )
                                    ],
                            ),
                          );
                        }),
                  );
                }),
                const SizedBox(
                  height: 34,
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          var matchId = await context.read<User>().enterMatch();
                          if (matchId == "err") return;
                        },
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(8, 0, 8, 42),
                          decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            key: user.keys[2],
                            padding: const EdgeInsets.fromLTRB(12, 12, 25, 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.play_arrow_outlined,
                                  color: kText,
                                  size: 50,
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 3.5, left: 1),
                                  child: Text(
                                    "Start a match",
                                    style: kBodyText1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          :
          SoloMatch(matchId: user.inGame['id']);
    });
  }
}

class SoloMatchCreator extends StatelessWidget {
  const SoloMatchCreator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
