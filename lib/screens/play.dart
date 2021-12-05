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
  var _isLoadingMatch = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, _) {
      return (user.inGame == null ||
              user.inGame["showMatch"] == false ||
              user.inGame["joinDate"] + 3600 * 1000 <
                  DateTime.now().millisecondsSinceEpoch) || (user.inGame["isShown"] == false)
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
                  Future.delayed(
                      const Duration(milliseconds: 1),
                          () => user.setIsShown(true)
                  );
                  var filteredInGameList = user.value["user"]["inGame"];
                  /*.where((g) => g["nbOfUsersFinishing"] > 0 ? true : false)
                      .toList();*/

                  var lastGames = user.value["user"]["lastGames"];
                  var lastWidget;

                  return Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: lastGames.length + filteredInGameList.length == 0
                        ? Row(
                            children: [
                              Text(
                                "Nothing here for now...",
                                style: kBodyText2.apply(color: kText80),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount:
                                lastGames.length + filteredInGameList.length,
                            itemBuilder: (BuildContext context, int index) {
                              var mergedArray =
                                  List.from(filteredInGameList.reversed)
                                    ..addAll(lastGames.reversed);
                              var currentMatch = mergedArray[index];

                              //if last widget is an "in game" tile, AND this one is a "match history" tile, set lastWidget to separator
                              lastWidget = currentMatch["wins"] != null &&
                                      lastWidget == false
                                  ? "separator"
                                  : currentMatch["wins"] != null
                                      ? true
                                      : false;
                              if (currentMatch["nbOfUsersFinishing"] == 0) {
                                currentMatch["nbOfUsersFinishing"] = 1;
                              }
                              return GestureDetector(
                                onTap: () {
                                  if (currentMatch["wins"] == null) {
                                    user.enterMatch(
                                        targetedMatchId: currentMatch["id"],
                                        isFromMatchHistory: !(currentMatch["isFinished"] == false)
                                    );
                                  }
                                },
                                child: Container(
                                  key: index == 0 ? user.keys[7] : null,
                                  decoration: BoxDecoration(
                                      color: kBackgroundVariant,
                                      borderRadius: BorderRadius.circular(20),
                                      border: currentMatch["isFinished"] == false ? Border.all(
                                        color:  kPrimary,
                                        width: 1,
                                      ) : null,
                                  ),
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 20, 30, 20),
                                  margin: EdgeInsets.only(
                                      left: 10,
                                      right: 15,
                                      top: lastWidget == "separator"
                                          ? 30
                                          : index == 0
                                              ? 0
                                              : 15),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: currentMatch["wins"] == null
                                        ? [
                                            RichText(
                                              softWrap: true,
                                              text: TextSpan(
                                                  style: kBodyText2.apply(
                                                      color: kText80),
                                                  children: currentMatch["isFinished"] == false ? [
                                                    TextSpan(
                                                        text: "Match in progress! ", style: kBodyText2.apply(color:kText)),
                                                  ] :[
                                                    const TextSpan(
                                                        text: "Waiting "),
                                                    TextSpan(
                                                        text: currentMatch[
                                                                "nbOfUsersFinishing"]
                                                            .toString(),
                                                        style: const TextStyle(
                                                            color: kPrimary)),
                                                    TextSpan(
                                                        text:
                                                            " player${currentMatch["nbOfUsersFinishing"] > 1 ? "s" : ""}..."),
                                                  ]),
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  "x",
                                                  style: TextStyle(
                                                      color: kGreen,
                                                      fontSize: 24,
                                                      fontFamily:
                                                          'Roboto Condensed'),
                                                ),
                                                const SizedBox(width: 1),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: .5),
                                                  child: Text(
                                                      "${(currentMatch["multiplier"] / 100).round()}",
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
                                                  padding:
                                                      const EdgeInsets.only(
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
                          setState(() {
                            _isLoadingMatch = true;
                          });
                        
                          var matchId = await context
                              .read<User>()
                              .enterMatch();
                          _isLoadingMatch = false;
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
                              children: [
                                _isLoadingMatch == true ? const Padding(
                                  padding: EdgeInsets.fromLTRB(10, 12, 14, 12),
                                  child: SizedBox(
                                    width: 26,
                                    height: 26,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 4.5,
                                      color: kText,
                                    ),
                                  ),
                                ) :
                                const Icon(
                                  Icons.play_arrow_outlined,
                                  color: kText,
                                  size: 50,
                                ),
                                const Padding(
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
          : SoloMatch(matchId: user.inGame['id']);
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
