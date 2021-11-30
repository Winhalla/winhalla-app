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
                  var alreadyTutorial;
                  try {
                    alreadyTutorial = user.value["user"]["lastGames"]
                        .firstWhere((e) => e["wins"] == "tutorial");
                  } catch (e) {}

                  if (user.value["user"]["lastGames"].length < 4 &&
                      alreadyTutorial == null) {
                    user.value["user"]["lastGames"].add({
                      "players": ['Philtrom', 'Philtrom2'],
                      "Date": "2021-10-12T15:26:59.598Z",
                      "_id": "6165a943a065c71f5c1f0787",
                      "gm": 'FFA',
                      "wins": "tutorial",
                      "coinsEarned": 10,
                      "rank": 0,
                      "id": '6165a73b60b0762990aebf5e'
                    });
                  }
                  return Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: user.value["user"]["lastGames"].length,
                        itemBuilder: (BuildContext context, int index) {
                          var match = user.value["user"]["lastGames"][index];
                          return Container(
                            decoration: BoxDecoration(
                                color: kBackgroundVariant,
                                borderRadius: BorderRadius.circular(20)),
                            padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                            margin: EdgeInsets.only(
                                left: 10, right: 15, top: index == 0 ? 0 : 15),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.85),
                                      child: Text(
                                        "${match["coinsEarned"]}",
                                        style: kBodyText1.apply(color: kPrimary),
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
                                  match["wins"] == "tutorial"
                                      ? "tutorial"
                                      : "${match["wins"]}/7 wins",
                                  style: kBodyText2.apply(
                                      color: kGray, fontFamily: "Bebas neue"),
                                ),
                                Text(
                                  "#${match["rank"] + 1}",
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
                  ],
                ),
              ],
            )
          :
          // Can't be null bc we check above. Null safety still there.
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
