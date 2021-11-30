import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/play.dart';
import 'package:winhalla_app/utils/user_class.dart';

class TutorialController extends ChangeNotifier{
  late OverlayEntry overlayEntry;
  late List<GlobalKey?> keys;
  late Tutorial tutorial;
  late double screenW;
  late BuildContext ctxt;
  late double screenH;
  bool finished = false;
  int status1 = 0;

  TutorialController(this.status1, this.keys, this.screenW, this.screenH, this.ctxt){
    tutorial = Tutorial(status1, keys, screenW, screenH, ctxt);
  }


  void endTutorial(){
    overlayEntry.remove();
    finished = true;
    notifyListeners();
  }

  void summon(BuildContext context) {
    try{
      overlayEntry.remove();
    }catch(e) {}

    overlayEntry = OverlayEntry(
        builder: (_) {
          return ChangeNotifierProvider<Tutorial>.value(
            value: tutorial,
            child: DefaultTextStyle(
              style: const TextStyle(fontFamily: "Bebas neue"),
              child: Consumer<Tutorial>(
                builder: (context, tutorial, _) {
                  return SizedBox.expand(
                    child: Stack(
                      children: [
                        Positioned.fromRect(
                            rect: tutorial.currentWidgetPosition[0],
                            child: Container(
                              color: Colors.black.withOpacity(0.85),
                            ),
                        ),
                        Positioned.fromRect(
                          rect: tutorial.currentWidgetPosition[1],
                          child: Container(
                            color: Colors.black.withOpacity(0.85),
                          ),
                        ),
                        Positioned.fromRect(
                          rect: tutorial.currentWidgetPosition[2],
                          child: Container(
                            color: Colors.black.withOpacity(0.85),
                          ),
                        ),
                        Positioned.fromRect(
                          rect: tutorial.currentWidgetPosition[3],
                          child: Container(
                            color: Colors.black.withOpacity(0.85),
                          ),
                        ),
                        Positioned.fromRect(rect: tutorial.currentWidgetPosition[4], child: GestureDetector(
                          onTap: () async {
                            User user = ctxt.read<User>();
                            if(tutorial.status == 1){
                              user.keyFx["switchPage"](2);
                            } else if(tutorial.status == 2){
                              await user.keyFx["joinMatch"]();
                            } else if (tutorial.status == 8){
                              user.keyFx["switchPage"](1);
                            } else if (tutorial.status == 12){
                              var questData = user.value["user"]["solo"]["dailyQuests"]
                              await user.collectQuest()
                            }
                            Timer.periodic(const Duration(milliseconds: 100),(timer){
                              if(user.keys[tutorial.status+1]?.currentContext != null){
                                tutorial.next();
                                timer.cancel();
                              }
                            });


                          },
                          child: Container(
                              color: Colors.transparent,
                            ),
                        ),
                        ),
                        tutorial.currentTextWidget,
                        Positioned(
                          bottom:50,
                          left:30,
                          right:30,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if(tutorial.backButtonEnabled) TextButton(
                                onPressed: () =>
                                    tutorial.previous(),
                                child: const Text(
                                  "Back",
                                  style: TextStyle(
                                      fontFamily: 'Roboto condensed',
                                      fontSize: 30,
                                      color: kText80),
                                ),
                              )
                              else Container(),
                              if(tutorial.nextButtonEnabled)  TextButton(
                                onPressed: () =>
                                    tutorial.next(),
                                child: const Text(
                                  "Next",
                                  style: TextStyle(
                                      fontFamily: 'Roboto condensed',
                                      fontSize: 30,
                                      color: kOrange),
                                ),
                              )
                              else Container(),
                            ]
                      ),
                        )
                    ]
                    ),
                  );
                }
              ),
            ),
          );
        }
    );
    Overlay.of(context)?.insert(
        overlayEntry
    );
    /*Future.delayed(const Duration(milliseconds: 5000),(){
      overlayEntry.remove();
    });*/
  }
}

class Tutorial extends ChangeNotifier{
  late Widget currentTextWidget;
  late List<Rect> currentWidgetPosition;
  late List<GlobalKey?> keys;
  late double screenW;
  late double screenH;
  late List<Map<String,dynamic>> tutorials;
  late BuildContext ctxt;
  // late BuildContext context;
  bool backButtonEnabled = true;
  bool nextButtonEnabled = true;
  int status = 0;

  void calculateNextValues(){
    currentTextWidget = tutorials[status]["widget"];
    currentWidgetPosition = _calculateRectFromKey(status);
    backButtonEnabled = tutorials[status]["controlButtonsEnabled"]["back"];
    nextButtonEnabled = tutorials[status]["controlButtonsEnabled"]["next"];
  }

  void next(){
    status ++;
    calculateNextValues();
    notifyListeners();
  }

  void previous(){
    status -= 1;
    calculateNextValues();
    notifyListeners();
  }

  List<Rect> _calculateRectFromKey(int index) {
    if(keys[index] == null){
      return [
        Rect.fromLTWH(0, 0, screenW, screenH),
        const Rect.fromLTWH(0, 0, 0, 0),
        const Rect.fromLTWH(0, 0, 0, 0),
        const Rect.fromLTWH(0, 0, 0, 0),
        const Rect.fromLTWH(0, 0, 0, 0),
      ];
    }
    if(index == 6){
      Future.delayed(const Duration(milliseconds: 4000), (){
        User user = ctxt.read<User>();
        user.keyFx["exitMatch"]();
        Timer.periodic(const Duration(milliseconds: 100),(timer){
          if(user.keys[status+1]?.currentContext != null){
            next();
            timer.cancel();
          }
        });
      });
      return [
        const Rect.fromLTWH(0, 0, 0, 0),
        const Rect.fromLTWH(0, 0, 0, 0),
        const Rect.fromLTWH(0, 0, 0, 0),
        const Rect.fromLTWH(0, 0, 0, 0),
        const Rect.fromLTWH(0, 0, 0, 0),
      ];
    }
    BuildContext? context = keys[index]?.currentContext;
    if(context == null) {
      throw Exception("Key not found");
    }
    RenderBox box = context.findRenderObject() as RenderBox;

    Offset offset = box.localToGlobal(Offset.zero);
    double add = 0;
    if(index == 3) add = 10;
    if(index == 7) add = 80;
    return [
      Rect.fromLTWH(0, 0, offset.dx, screenH), // Left
      Rect.fromLTWH(offset.dx + box.size.width, 0, screenW, screenH), // Right
      Rect.fromLTWH(offset.dx, 0, box.size.width, offset.dy-add), // Up
      Rect.fromLTRB(offset.dx, offset.dy+box.size.height, screenW, screenH), // Down
      Rect.fromLTWH(offset.dx, offset.dy, box.size.width, box.size.height)
    ];
    /*return Rect.fromLTWH(
      offset.dx - 5,
      offset.dy - 5,
      box.size.width + 10,
      box.size.height + 10,
    );*/
  }

  Tutorial(this.status, this.keys, this.screenW, this.screenH, this.ctxt){
    tutorials = [
      {
        "widget":Positioned(
          left: 20,
          right: 20,
          child: SizedBox(
            width: screenW-40,
            height: screenH-70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
              child: Column(mainAxisAlignment:MainAxisAlignment.center, children: [
                const Text("Hey! Welcome to Winhalla!", style: TextStyle(fontFamily: "Roboto condensed", fontSize: 40),),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(style: kBodyText1Roboto, children: [
                          const TextSpan(
                              text: "Here’s a ",
                              style: kBodyText1Roboto
                          ),
                          TextSpan(text: "quick tutorial ", style:kBodyText1Roboto.apply(color: kPrimary )),
                          const TextSpan(text: "for you to understand the app in less than ", style: kBodyText1Roboto ),
                          TextSpan(text: "a minute!", style:kBodyText1Roboto.apply(color: kPrimary) )
                        ]),
                      ),
                    ),
                  ],
                )
              ],),
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":true
        },
      },
      {
        "widget":Container(),
        "controlButtonsEnabled":{
          "back":false,
          "next":false
        },
      }, {
        "widget":Positioned(
          // top: 10,
          left: 20,
          right: 20,
          bottom: 10,
          child: SizedBox(
            width: screenW-40,
            height: screenH/2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Let's jump in a match!",
                  style: kBodyText1Roboto
                ),
              ],
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":false
        },
      },{
        "widget":Positioned(
          // top: 10,
          left: 20,
          right: 20,
          bottom: 10,
          child: SizedBox(
            width: screenW-40,
            height: screenH/3,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                    "This is your player card",
                    style: kBodyText1Roboto
                ),
              ],
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":true
        },
      },{
        "widget":Positioned(
          // top: 10,
          left: 40,
          right: 40,
          bottom: 10,
          child: SizedBox(
            width: screenW-80,
            height: screenH/1.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: Text(
                      "Let’s pretend you just played some Brawlhalla games.",
                      style: kBodyText1Roboto
                  ),
                ),
              ],
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":true,
          "next":true
        },
      },{
        "widget":Positioned(
          // top: 10,
          left: 20,
          right: 20,
          bottom: 10,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW-40,
                height: screenH/1.5,
                child: RefreshIndicator(
                  onRefresh: () async {
                    User user = ctxt.read<User>();
                    await user.keyFx["refreshMatch"](ctxt, user, showInfo:false);
                    context.read<Tutorial>().next();
                  },
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Pull down to refresh", style: kBodyText1Roboto,),
                        ],
                      ),
                      const Icon(Icons.south, size: 40, color: kText,)
                    ],
                  ),
                ),
              );
            }
          ),
        ),
        "controlButtonsEnabled":{
          "back":true,
          "next":false
        },
      },{
        "widget":Container(),
        "controlButtonsEnabled":{
          "back":false,
          "next":false
        },
      },{
        "widget": Positioned(
          left: 40,
          right: 40,
          child: SizedBox(
            width: screenW - 80,
            height: screenH - 70,
            child: Padding(
              padding:
                  EdgeInsets.only(top: screenH/2,),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(style: kBodyText1Roboto, children: [
                        const TextSpan(
                            text: "Recently played ", style: kBodyText1Roboto),
                        const TextSpan(
                            text: "Winhalla ",
                            style: kBodyText1Roboto),
                        TextSpan(
                            text:
                                "matches ",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
                        const TextSpan(
                            text:
                                "will show up there. It will display the",
                            style: kBodyText1Roboto),
                        TextSpan(
                            text: "number of coins ",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
                        const TextSpan(
                            text: "you earned, and your rank in the match.",
                            style: kBodyText1Roboto)
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":true
        },
      },{
        "widget": Container(),
        "controlButtonsEnabled":{
          "back":true,
          "next":false
        },
      }, { 
        "widget": Positioned(
          left: 40,
          right: 40,
          child: SizedBox(
            width: screenW - 80,
            height: screenH - 70,
            child: Padding(
              padding: EdgeInsets.only(top: screenH/1.8,),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(style: kBodyText1Roboto, children: [
                        const TextSpan(
                            text: "This is the quests, complete these quests in ", style: kBodyText1Roboto),
                        TextSpan(
                            text: "any online Brawlhalla gamemode",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
                        const TextSpan(
                            text:
                                "(unless specified)",
                            style: kBodyText1Roboto),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":true,
          "next":true
        },
      }, {
        "widget":Positioned(
          left: 40,
          right: 40,
          bottom: 10,
          child: SizedBox(
            width: screenW-80,
            height: screenH/1.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(
                  child: Text(
                      "Let’s pretend you just completed one of these goals.",
                      style: kBodyText1Roboto
                  ),
                ),
              ],
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":true,
          "next":true
        },
      },{ // 12th item
        "widget":Positioned(
          left: 20,
          right: 20,
          bottom: 10,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW-40,
                height: screenH/1.5,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await ctxt.read<User>().refreshQuests(ctxt, showInfo:false)
                    context.read<Tutorial>().next();
                  },
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text("Pull down to refresh", style: kBodyText1Roboto,),
                        ],
                      ),
                      const Icon(Icons.south, size: 40, color: kText,)
                    ],
                  ),
                ),
              );
            }
          ),
        ),
        "controlButtonsEnabled":{
          "back":true,
          "next":false
        },
      },{
        "widget": Positioned(
          left: 40,
          right: 40,
          child: SizedBox(
            width: screenW - 80,
            height: screenH - 70,
            child: Padding(
              padding: EdgeInsets.only(top: screenH/1.8,),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: kBodyText1Roboto, 
                        children: [
                          const TextSpan(
                              text: "This quest is now completed. ", style: kBodyText1Roboto),
                          TextSpan(
                              text: "Tap it ",
                              style: kBodyText1Roboto.apply(color: kPrimary)),
                          const TextSpan(
                              text:
                                  "to collect it and get the coins",
                              style: kBodyText1Roboto),
                        ]
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":true,
          "next":false
        },
      }
    ];
    calculateNextValues();
  }
}