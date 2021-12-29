import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/ffa.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/coin_dropdown.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({Key? key}) : super(key: key);

  @override
  _PlayPageState createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  var _isLoadingMatch = false;
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    /*if (!kDebugMode)*/ //_initGoogleMobileAds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<User>(builder: (context, user, _) {
      bool hasMatchInProgress = false;
      try{
        if(user.value["user"]["inGame"].firstWhere((e) => e["isFinished"] == false, orElse: () => null) != null){
          hasMatchInProgress = true;
        }
      }catch(e){}

      return (user.inGame == null ||
              user.inGame["showMatch"] == false ||
              user.inGame["joinDate"] + 3600 * 1000 <
                  DateTime.now().millisecondsSinceEpoch) || (user.inGame["isShown"] == false)
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 6, top: 4.5),
                  child: Text(
                    "Match History:",
                    style: InheritedTextStyle.of(context).kHeadline1,
                  ),
                ),
                SizedBox(
                  height: 4.8.h,
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
                  var lastMatchHistory;
                  if(user.animateMatchHistory && user.value["user"]["lastGames"].isNotEmpty) {
                    lastMatchHistory = lastGames.last;
                    lastGames.removeLast();
                  }
                  var mergedArray = List.from(filteredInGameList.reversed)
                    ..addAll(lastGames.reversed);

                  var lastWidget;
                  return Flexible(
                    flex: 1,
                    fit: FlexFit.tight,
                    child: lastGames.length + filteredInGameList.length == 0
                        ? Row(
                            children: [
                              Text(
                                "Nothing here for now...",
                                style: InheritedTextStyle.of(context).kBodyText2.apply(color: kText80),
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.center,
                            // crossAxisAlignment: CrossAxisAlignment.start,
                          )
                        : StatefulBuilder(
                          builder: (context, setState) {
                            return AnimatedList(
                                key: _listKey,
                                shrinkWrap: true,
                                initialItemCount:lastGames.length + filteredInGameList.length,
                                itemBuilder: (BuildContext context, int index, Animation<double> animation) {

                                  var currentMatch = mergedArray[index];
                                  // For animation
                                  if(index == 0) {
                                    if (user.animateMatchHistory && user.value["user"]["lastGames"].isNotEmpty) {

                                      user.setAnimateMatchHistory(false);
                                      user.animateMatchHistory = false;
                                      Future.delayed(const Duration(milliseconds: 250), () {
                                        showCoinDropdown(
                                            context,
                                            user.value["user"]["coins"]-lastMatchHistory["coinsEarned"],
                                            lastMatchHistory["coinsEarned"]
                                        );
                                        lastGames.add(lastMatchHistory);
                                        mergedArray = List.from(filteredInGameList.reversed)
                                          ..addAll(lastGames.reversed);
                                        _listKey.currentState!.insertItem(
                                            filteredInGameList.length,
                                            duration: const Duration(milliseconds: 350)
                                        );
                                        // Uncomment to deactivate shadow & border after delay
                                        /*Future.delayed(const Duration(milliseconds: 2500), () {
                                          setState((){});
                                        });*/
                                      });
                                    }
                                  }

                                  // if last widget is an "in game" tile, AND this one is a "match history" tile, set lastWidget to separator
                                  lastWidget = currentMatch["wins"] != null &&
                                          lastWidget == false
                                      ? "separator"
                                      : currentMatch["wins"] != null
                                          ? true
                                          : false;
                                  if (currentMatch["nbOfUsersFinishing"] == 0) {
                                    currentMatch["nbOfUsersFinishing"] = 1;
                                  }
                                  bool isInTransition = currentMatch["_id"] == lastMatchHistory?["_id"] && !animation.isCompleted;
                                  return GestureDetector(
                                    onTap: () {
                                      if (currentMatch["wins"] == null) {
                                        user.enterMatch(
                                            targetedMatchId: currentMatch["id"],
                                            isFromMatchHistory: !(currentMatch["isFinished"] == false)
                                        );
                                      }
                                    },
                                    child: FadeTransition(
                                      opacity: Tween(begin: 0.0, end: 1.0).animate(
                                          CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
                                      child: SizeTransition(
                                        sizeFactor: Tween(
                                          begin: 0.0,
                                          end: 1.0,
                                        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                                        ),
                                        child: Container(
                                          key: index == 0 ? user.keys[7] : null,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                if(isInTransition)
                                                  const BoxShadow(
                                                    // offset: Offset(3.0, 3.0),
                                                    blurRadius: 5.0,
                                                    spreadRadius: 2.0,
                                                    color: kPrimary
                                                  ),
                                              ],
                                              color: kBackgroundVariant,
                                              borderRadius: BorderRadius.circular(20),
                                              border: currentMatch["isFinished"] == false
                                                  || isInTransition ? Border.all(
                                                  color:  kPrimary,
                                                  width: 1,
                                                ) : null,
                                          ),
                                          padding:
                                              const EdgeInsets.fromLTRB(30, 20, 30, 20),
                                          margin: EdgeInsets.only(
                                              left: 10,
                                              right: 15,
                                              bottom: isInTransition ? 7 : 0,
                                              top: lastWidget == "separator"
                                                  ? 30
                                                  : index == 0
                                                      ? (isInTransition ? 7 : 0)
                                                      : 15),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: currentMatch["wins"] == null
                                                ? [
                                                    RichText(
                                                      softWrap: true,
                                                      text: TextSpan(
                                                          style: InheritedTextStyle.of(context).kBodyText2.apply(
                                                              color: kText80),
                                                          children: currentMatch["isFinished"] == false ? [
                                                            TextSpan(
                                                                text: "Match in progress! ", style: InheritedTextStyle.of(context).kBodyText2.apply(color:kText)),
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
                                                        Text(
                                                          "x",
                                                          style: InheritedTextStyle.of(context).kBodyText2.apply(color: kGreen,),
                                                        ),
                                                        const SizedBox(width: 1),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets.only(
                                                                  top: .5),
                                                          child: Text(
                                                            "${(currentMatch["multiplier"] / 100).round()}",
                                                            style: InheritedTextStyle.of(context).kBodyText4.apply(
                                                                color: kGreen,
                                                                fontSizeFactor: 1.4   // Equivalent to 28 of font size
                                                            )
                                                          ),
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
                                                            style: InheritedTextStyle.of(context).kBodyText1.apply(
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
                                                      style: InheritedTextStyle.of(context).kBodyText2.apply(
                                                          color: kGray,
                                                          fontFamily: "Bebas neue"),
                                                    ),
                                                    Text(
                                                      "#${currentMatch["rank"] + 1}",
                                                      style: InheritedTextStyle.of(context).kBodyText1.apply(
                                                          fontFamily: "Bebas neue"),
                                                    )
                                                  ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                });
                          }
                        ),
                  );
                }),
                SizedBox(
                  height: 4.5.h,
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
                          //if (matchId == "err") _isLoadingMatch = false;
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(8, 0, 8, 5.h),
                          decoration: BoxDecoration(
                              color: kPrimary,
                              borderRadius: BorderRadius.circular(18)),
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
                                      strokeWidth: 4,
                                      color: kText,
                                    ),
                                  ),
                                ) :
                                Icon(
                                  Icons.play_arrow_outlined,
                                  color: kText,
                                  size: 28.sp,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 3.5, left: 1),
                                  child: Text(
                                    hasMatchInProgress? "Go to match" :"Start a match",
                                    style: InheritedTextStyle.of(context).kBodyText1,
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