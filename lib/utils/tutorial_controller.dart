import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';

class FadeInPositioned extends StatefulWidget {
  final double? top;
  final double? right;
  final double? left;
  final double? bottom;
  final Widget? child;
  const FadeInPositioned({
    Key? key,
    this.top,
    this.right,
    this.left,
    this.bottom,
    required this.child,
  }) : super(key: key);

  @override
  _FadeInPositionedState createState() => _FadeInPositionedState();
}

class _FadeInPositionedState extends State<FadeInPositioned> {
  bool _visible = true;
  bool _dontResetNextBuild = false;

  @override
  void initState(){
    /*Future.delayed(const Duration(milliseconds: 10), (){
      setState((){
        _visible = true;
      });
    });*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!_dontResetNextBuild){
        _visible = false;
        Future.delayed(const Duration(milliseconds: 1), () {
          setState(() {
            print("show");
            _visible = true;
            _dontResetNextBuild = true;
          });
        });


    } else {
      _dontResetNextBuild = false;
    }
    return Positioned(
      child:AnimatedOpacity(
        child: widget.child,
        opacity: _visible?1:0,
        duration: Duration(milliseconds: _visible ? 400 : 0),
      ),
      top: widget.top,
      right: widget.right,
      left: widget.left,
      bottom: widget.bottom,
    );
  }
}


class TutorialStack extends StatefulWidget {
  final bool isTransition;
  final Tutorial tutorial;

  const TutorialStack({Key? key, required this.tutorial, this.isTransition = false}) : super(key: key);
  @override
  _TutorialStackState createState() => _TutorialStackState();
}
class _TutorialStackState extends State<TutorialStack> {
  bool _visible = true;
  bool _dontResetNextBuild = false;

  @override
  Widget build(BuildContext context) {
    if(widget.isTransition) {
      if(!_dontResetNextBuild){
        _visible = false;
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _visible = true;
            _dontResetNextBuild = true;
          });
        });

      } else {
        _dontResetNextBuild = false;
      }
    }
    Tutorial tutorial = widget.tutorial;

    return AnimatedOpacity(
      opacity: _visible?1:0,
      duration: Duration(milliseconds: _visible ? 400 : 0),
      child: Stack(children: [
        for (int i = 0; i < 4; i++)
          Positioned.fromRect(
            rect: tutorial.currentWidgetPosition[i],
            child: Container(
              color: Colors.black.withOpacity(0.85),
            ),
          ),
        Positioned.fromRect(
          rect: tutorial.currentWidgetPosition[4],
          child: GestureDetector(
            onTap: () async {
              User user = tutorial.ctxt.read<User>();
              if (tutorial.status == 1) {
                user.keyFx["switchPage"](2);

              } else if (tutorial.status == 2) {
                await user.enterMatch(isTutorial: true);

              } else if (tutorial.status == 8) {
                user.keyFx["switchPage"](1);

              } else if (tutorial.status == 13) {
                user.keyFx["switchPage"](0);

              } else if (tutorial.status == 12) {
                var questData = user.quests["finished"]["daily"][0];
                await user.collectQuest(questData["id"], "daily", questData["reward"]);

              } else if (tutorial.status == 16) {
                user.keyFx["playAd"]();
                Future.delayed(const Duration(seconds: 1), () => tutorial.next());
                return;
              }

              Timer.periodic(const Duration(milliseconds: 100), (timer) {
                if (user.keys[tutorial.status + 1]?.currentContext != null) {
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
          bottom: 50,
          left: 30,
          right: 30,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (tutorial.backButtonEnabled)
              TextButton(
                onPressed: () => tutorial.previous(),
                child: const Text(
                  "Back",
                  style: TextStyle(fontFamily: 'Roboto condensed', fontSize: 30, color: kText80),
                ),
              )
            else
              Container(),
            if (tutorial.nextButtonEnabled)
              TextButton(
                onPressed: () => tutorial.next(),
                child: Row(
                  children: [
                    Text(
                      tutorial.status == 17 ? "Finish" : "Next",
                      style: TextStyle(
                          fontFamily: 'Roboto condensed', fontSize: 30, color: tutorial.status == 17 ? kGreen : kOrange),
                    ),
                    if (tutorial.status == 17)
                      const SizedBox(
                        width: 6,
                      ),
                    if (tutorial.status == 17)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 3),
                        child: Icon(
                          Icons.check,
                          color: kGreen,
                          size: 30,
                        ),
                      ),
                  ],
                ),
              )
            else
              Container(),
          ]),
        )
      ]),
    );
  }
}

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
    ctxt = context;
    tutorial.ctxt = context;
    try{
      overlayEntry.remove();
    }catch(e) {}

    overlayEntry = OverlayEntry(builder: (_) {
      return ChangeNotifierProvider<Tutorial>.value(
        value: tutorial,
        child: DefaultTextStyle(
          style: const TextStyle(fontFamily: "Bebas neue"),
          child: Consumer<Tutorial>(builder: (context, tutorial, _) {
            int i = tutorial.status;
            return SizedBox.expand(
              child: TutorialStack(
                  tutorial: tutorial,
                  isTransition: i == 0 || i == 2 || i == 3 || i == 7 || i == 9 || i == 14
              )
            );
          }),
        ),
      );
    });
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
  int? nextStatus;

  void calculateNextValues(){
    currentTextWidget = tutorials[status]["widget"];
    currentWidgetPosition = _calculateRectFromKey(status);
    backButtonEnabled = tutorials[status]["controlButtonsEnabled"]["back"];
    nextButtonEnabled = tutorials[status]["controlButtonsEnabled"]["next"];
  }

  void next(){
    status ++;
    print(status);
    if(nextStatus != null){
      status = nextStatus as int;
      nextStatus = null;
    }
    if(status == 18) {
      ctxt.read<User>().callApi.post("/finishedTutorial","{}");
      return ctxt.read<TutorialController>().endTutorial();
    }
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
      Future.delayed(const Duration(milliseconds: 4500), () async {
        User user = ctxt.read<User>();
        await user.exitMatch(false, isOnlyLayout: true);
        Timer.periodic(const Duration(milliseconds: 100),(timer){
          if(user.keys[status+1]?.currentContext != null){
            next();
            timer.cancel();
          }
        });
      });
    }
    BuildContext? context = keys[index]?.currentContext;
    if(context == null) {
      throw Exception("Key not found");
    }
    RenderBox box = context.findRenderObject() as RenderBox;

    Offset offset = box.localToGlobal(Offset.zero);
    double add = 0;
    double addAll = 0;
    if(index == 3) add = 10;
    if(index == 7) add = 90;
    if(index == 6) addAll = 15;
    return [
      Rect.fromLTWH(0, 0, offset.dx-addAll, screenH), // Left
      Rect.fromLTWH(offset.dx + box.size.width + addAll, 0, screenW, screenH), // Right
      Rect.fromLTWH(offset.dx-addAll, 0, box.size.width+addAll*2, offset.dy-add-addAll), // Up
      Rect.fromLTRB(offset.dx-addAll, offset.dy+box.size.height+addAll, screenW, screenH), // Down
      Rect.fromLTWH(offset.dx, offset.dy, box.size.width, box.size.height)
    ];
    /*return Rect.fromLTWH(
      offset.dx - 5,
      offset.dy - 5,
      box.size.width + 10,
      box.size.height + 10,
    );*/
  }

  Tutorial(status, this.keys, this.screenW, this.screenH, this.ctxt){
    if(status != 0){
      nextStatus = status;
    }
    tutorials = [
      {
        "widget":FadeInPositioned(
          left: 20,
          right: 20,
          child: SizedBox(
            width: screenW-40,
            height: screenH-70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
              child: Column(mainAxisAlignment:MainAxisAlignment.center, children: [
                Text(nextStatus != null ? "Hey! Welcome back to Winhalla!" : "Hey! Welcome to Winhalla!", style: TextStyle(fontFamily: "Roboto condensed", fontSize: 40),),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(style: kBodyText1Roboto, children: [
                          TextSpan(
                              text: nextStatus != null ? "Let's take the " : "Here’s a ",
                              style: kBodyText1Roboto
                          ),
                          TextSpan(text: nextStatus != null ? "tutorial " : "quick tutorial ", style:kBodyText1Roboto.apply(color: kPrimary )),
                          TextSpan(text: nextStatus != null ? "where you left it, it takes no more than " : "for you to understand the app in less than ", style: kBodyText1Roboto ),
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
        "widget":FadeInPositioned(
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
                Expanded(
                  child: Text(
                    "Let's jump in a match!",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontFamily: "Roboto condensed", fontSize: 35, )
                  ),
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
        "widget":FadeInPositioned(
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
                Expanded(
                  child: Text(
                      "This is your player card",
                      textAlign: TextAlign.center,
                      style: kBodyText1Roboto
                  ),
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
        "widget":FadeInPositioned(
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
        "widget":FadeInPositioned(
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
                    await user.keyFx["refreshMatch"](ctxt, user, showInfo:false, isTutorial:true, isTutorialRefresh:true);
                    context.read<Tutorial>().next();
                  },
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Expanded(
                            child: Text(
                              "Pull down to refresh",
                              style: kBodyText1Roboto,
                              textAlign: TextAlign.center,
                            )
                          ),
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
        "widget": FadeInPositioned(
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
                                "will show up there. It will display the ",
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
          "back":false,
          "next":false
        },
      }, { 
        "widget": FadeInPositioned(
          left: 20,
          right: 20,
          child: SizedBox(
            width: screenW - 40,
            height: screenH,
            child: Padding(
              padding: EdgeInsets.only(top: screenH/1.8,),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(style: kBodyText1Roboto, children: [
                        const TextSpan(
                            text: "Here are the quests, Complete them in ", style: kBodyText1Roboto),
                        TextSpan(
                            text: "any online Brawlhalla gamemode ",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
                        const TextSpan(
                            text:
                                "(unless a gamemode is specified)",
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
        "widget":FadeInPositioned(
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
      },{ // 12th item ; index : 11
        "widget":FadeInPositioned(
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
                    await ctxt.read<User>().refreshQuests(ctxt, showInfo:false, isTutorial:true);
                    context.read<Tutorial>().next();
                  },
                  child: ListView(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Expanded(
                            child: Text(
                              "Pull down to refresh",
                              textAlign: TextAlign.center,
                              style: kBodyText1Roboto,
                            )
                          ),
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
      },{ // 13th item ; index : 12
        "widget": FadeInPositioned(
          left: 40,
          right: 40,
          child: SizedBox(
            width: screenW - 80,
            height: screenH - 70,
            child: Padding(
              padding: EdgeInsets.only(top: screenH/1.65,),
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
          "back":false,
          "next":false
        },
      },{ // 14th item ; index : 13
        "widget": FadeInPositioned(
          left: 20,
          right: 20,
          child: SizedBox(
            width: screenW - 40,
            height: screenH,
            child: Padding(
              padding: EdgeInsets.only(top: screenH/2,),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(style: kBodyText1Roboto, children: [
                        const TextSpan(
                            text: "Now that this quest is completed, let's check the ", style: kBodyText1Roboto),
                        TextSpan(
                            text: "daily challenges",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
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
          "next":false
        },
      },{ // 15th item ; index : 14
        "widget": FadeInPositioned(
          left: 20,
          right: 20,
          bottom: 65,
          child: SizedBox(
            width: screenW - 40,
            height: screenH - 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: RichText(
                    text: TextSpan(style: kBodyText1Roboto, children: [
                      const TextSpan(
                          text: "These are the ", style: kBodyText1Roboto),
                      TextSpan(
                          text: "daily challenges, ",
                          style: kBodyText1Roboto.apply(color: kPrimary)),
                      const TextSpan(
                          text:
                          "Complete them by doing different actions ",
                          style: kBodyText1Roboto),
                      TextSpan(
                          text:
                          "in the app.",
                          style: kBodyText1Roboto.apply(color: kPrimary)),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":true
        },
      },{ // 16th item ; index : 15
        "widget": FadeInPositioned(
          left: 20,
          right: 20,
          child: SizedBox(
            width: screenW - 40,
            height: screenH,
            child: Padding(
              padding: EdgeInsets.only(top: screenH/2,),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(style: kBodyText1Roboto, children: [
                        const TextSpan(
                            text: "You just completed this one, so it has updated ", style: kBodyText1Roboto),
                        TextSpan(
                            text: "automatically.",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
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
      },{ // 17th item ; index : 16
        "widget": FadeInPositioned(
          left: 20,
          right: 20,
          child: SizedBox(
            width: screenW - 40,
            height: screenH,
            child: Padding(
              padding: EdgeInsets.only(top: screenH/2,),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(style: kBodyText1Roboto, children: [
                        const TextSpan(
                            text: "Now, ", style: kBodyText1Roboto),
                        TextSpan(
                            text: "this challenge ",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
                        const TextSpan(
                            text: "has unlocked, ", style: kBodyText1Roboto),
                        TextSpan(
                            text: "complete it ",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
                        const TextSpan(
                            text: "to get it's ", style: kBodyText1Roboto),
                        TextSpan(
                            text: "reward",
                            style: kBodyText1Roboto.apply(color: kPrimary)),
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
      },{ // index : 17
        "widget":FadeInPositioned(
          left: 20,
          right: 20,
          child: SizedBox(
            width: screenW-40,
            height: screenH-70,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
              child: Column(mainAxisAlignment:MainAxisAlignment.center, children: [
                const Text("Tutorial completed!", style: TextStyle(fontSize: 40),),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(style: kBodyText1Roboto, children: [
                          const TextSpan(
                              text: "Go enjoy the app! If you’ve got any ",
                              style: kBodyText1Roboto
                          ),
                          TextSpan(text: "questions ", style:kBodyText1Roboto.apply(color: kPrimary )),
                          const TextSpan(text: "or ", style: kBodyText1Roboto ),
                          TextSpan(text: "issue", style:kBodyText1Roboto.apply(color: kPrimary) ),
                          const TextSpan(text: ", send us a message! (on Instagram, Discord, or contact email...).", style:kBodyText1Roboto ),
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
    ];
    calculateNextValues();
  }
}