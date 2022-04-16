import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/coin_dropdown.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';

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
  final int status;

  const TutorialStack({Key? key, required this.tutorial, this.isTransition = false, required this.status}) : super(key: key);
  @override
  _TutorialStackState createState() => _TutorialStackState();
}
class _TutorialStackState extends State<TutorialStack> {
  bool _visible = true;
  bool _dontResetNextBuild = false;
  bool _hasMadeTransition = false;
  late int status;

  @override
  void initState(){
    status = widget.status;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(!_dontResetNextBuild) {
      if (status != widget.status) {
        status = widget.status;
        _hasMadeTransition = false;
      }
      if (widget.isTransition && !_hasMadeTransition) {
        _visible = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _visible = true;
            _dontResetNextBuild = true;
            _hasMadeTransition = true;
          });
        });
      }
    } else {
      _dontResetNextBuild = false;
    }
    Tutorial tutorial = widget.tutorial;
    return AnimatedOpacity(
      opacity: _visible?1:0,
      duration: Duration(milliseconds: _visible ? 400 : 0),
      child: Stack(children: [
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
                try{
                  var x = user.quests["finished"]["daily"][0];
                } on RangeError {
                  tutorial.next();
                  return;
                }
                var questData = user.quests["finished"]["daily"][0];
                await user.collectQuest(questData["id"], "daily", questData["reward"], isTutorial:true);

              } else if (tutorial.status == 16) {
                user.keyFx["playAd"]();
                Future.delayed(const Duration(seconds: 1), () => tutorial.next());
                return;
              }

              if(tutorial.status <= 17) {
                Timer.periodic(const Duration(milliseconds: 100), (timer) {
                  if (user.keys[tutorial.status + 1]?.currentContext != null) {
                    tutorial.next();
                    timer.cancel();
                  }
                });
              }
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        for (int i = 0; i < 4; i++)
          Positioned.fromRect(
            rect: tutorial.currentWidgetPosition[i],
            child: Container(
              color: Colors.black.withOpacity(0.86),
            ),
          ),
        tutorial.currentTextWidget,
        Positioned(
          bottom: 24,
          left: 30,
          right: 30,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            if (tutorial.backButtonEnabled)
              TextButton(
                onPressed: () => tutorial.previous(),
                child: Text(
                  "Back",
                  style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color:kText80),
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
                      style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: tutorial.status == 17 ? kGreen : kOrange),
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
                status: i,
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
  bool _isLoadingNextStep = false;

  void calculateNextValues(){
    currentTextWidget = tutorials[status]["widget"];
    currentWidgetPosition = _calculateRectFromKey(status);
    backButtonEnabled = tutorials[status]["controlButtonsEnabled"]["back"];
    nextButtonEnabled = tutorials[status]["controlButtonsEnabled"]["next"];
  }

  void next(){
    if(_isLoadingNextStep == true){
      print("test");
      return;
    }

    _isLoadingNextStep = true;

    status ++;
    if(nextStatus != null){
      status = nextStatus as int;
      nextStatus = null;
    }
    if(status >= 17) {
      ctxt.read<User>().callApi.post("/finishedTutorial","{}");
      return ctxt.read<TutorialController>().endTutorial();
    }
    calculateNextValues();
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 250), (){
      _isLoadingNextStep = false;
      print("setFalse");
    });
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

    if(index == 6) {
      Future.delayed(const Duration(milliseconds: 4000), () async {
        User user = ctxt.read<User>();
        await user.exitMatch(isOnlyLayout: true);
        showCoinDropdown(ctxt, 0, 400);
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
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW-40,
                height: screenH-70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
                  child: Column(mainAxisAlignment:MainAxisAlignment.center, children: [
                    Text(nextStatus != null ? "Hey! Welcome back to Winhalla!" : "Hey! Welcome to Winhalla!", style: InheritedTextStyle.of(context).kHeadline1.apply(fontFamily: "Roboto Condensed"),),
                    const SizedBox(height: 20,),
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(style: InheritedTextStyle.of(context).kBodyText1Roboto, children: [
                              TextSpan(
                                  text: nextStatus != null ? "Let's take the " : "Here’s a ",
                                  style: InheritedTextStyle.of(context).kBodyText1Roboto
                              ),
                              TextSpan(text: nextStatus != null ? "tutorial " : "quick tutorial ", style:InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary )),
                              TextSpan(text: nextStatus != null ? "where you left it, it takes no more than " : "for you to understand the app in less than ", style: InheritedTextStyle.of(context).kBodyText1Roboto ),
                              TextSpan(text: "a minute!", style:InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary) )
                            ]),
                          ),
                        ),
                      ],
                    )
                  ],),
                ),
              );
            }
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
          top: 40.h,
          left: 20,
          right: 20,
          // bottom: 10,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW-40,
                height: screenH/2,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            "Let's jump in a match!",
                            textAlign: TextAlign.center,
                            style: InheritedTextStyle.of(context).kHeadline2.apply(fontFamily: "Roboto condensed")
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 2.h, 8.w, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                                "Matches are the fastest way to earn Coins, you just have to start one when you start a Brawlhalla ranked games session, refresh after 7 games and you will earn coins!",
                                textAlign: TextAlign.left,
                                style: InheritedTextStyle.of(context).kBodyText3.apply(color: kText80)
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }
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
          top: 306,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW-40,
                height: screenH/3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                          "This is your player card",
                          textAlign: TextAlign.center,
                          style: InheritedTextStyle.of(context).kBodyText1Roboto
                      ),
                    ),
                  ],
                ),
              );
            }
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
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW-80,
                height: screenH/1.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                          "Let’s pretend you just played some Brawlhalla ranked games.",
                          style: InheritedTextStyle.of(context).kBodyText1Roboto
                      ),
                    ),
                  ],
                ),
              );
            }
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
                        children: [
                          Expanded(
                            child: Text(
                              "Pull down to refresh",
                              style: InheritedTextStyle.of(context).kBodyText1Roboto,
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
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW - 80,
                height: screenH - 70,
                child: Padding(
                  padding:
                      EdgeInsets.only(top: screenH/2,),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(style: InheritedTextStyle.of(context).kBodyText1Roboto, children: [
                            TextSpan(
                                text: "Recently played ", style: InheritedTextStyle.of(context).kBodyText1Roboto),
                             TextSpan(
                                text: "Winhalla ",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto),
                            TextSpan(
                                text:
                                    "matches ",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                            TextSpan(
                                text:
                                    "will show up there. It will display the ",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto),
                            TextSpan(
                                text: "number of coins ",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                            TextSpan(
                                text: "you earned, and your rank in the match.",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto)
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
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
          top: 86,
          left: 20,
          right: 20,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW - 40,
                height: screenH,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(style: InheritedTextStyle.of(context).kBodyText1Roboto, children: [
                          TextSpan(
                              text: "Here are the quests, Complete them in ", style: InheritedTextStyle.of(context).kBodyText1Roboto),
                          TextSpan(
                              text: "any online Brawlhalla gamemode ",
                              style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                          TextSpan(
                              text:
                                  "(unless a gamemode is specified)",
                              style: InheritedTextStyle.of(context).kBodyText1Roboto),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            }
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":true
        },
      }, {
        "widget":FadeInPositioned(
          left: 40,
          right: 40,
          bottom: 10,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW-80,
                height: screenH/1.5,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                          "Let’s pretend you just completed one of these goals.",
                          style: InheritedTextStyle.of(context).kBodyText1Roboto
                      ),
                    ),
                  ],
                ),
              );
            }
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
                        children: [
                          Expanded(
                            child: Text(
                              "Pull down to refresh",
                              textAlign: TextAlign.center,
                              style: InheritedTextStyle.of(context).kBodyText1Roboto,
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
          top: screenH/2,

          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW - 80,
                height: screenH - 70,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: InheritedTextStyle.of(context).kBodyText1Roboto,
                          children: [
                            TextSpan(
                                text: "This quest is now completed. ", style: InheritedTextStyle.of(context).kBodyText1Roboto),
                            TextSpan(
                                text: "Tap it ",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                            TextSpan(
                                text:
                                    "to collect it and get the coins",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto),
                          ]
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
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
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW - 40,
                height: screenH,
                child: Padding(
                  padding: EdgeInsets.only(top: screenH/2,),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(style: InheritedTextStyle.of(context).kBodyText1Roboto, children: [
                            TextSpan(
                                text: "Now that this quest is completed, let's check the ", style: InheritedTextStyle.of(context).kBodyText1Roboto),
                            TextSpan(
                                text: "daily challenges",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":false
        },
      },{ // 15th item ; index : 14
        "widget": FadeInPositioned(
          top: 90,
          left: 24,
          right: 24,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW - 48,
                height: screenH - 40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RichText(
                        text: TextSpan(style: InheritedTextStyle.of(context).kBodyText1Roboto, children: [
                          TextSpan(
                              text: "These are the ",
                              style: InheritedTextStyle.of(context).kBodyText1Roboto),
                          TextSpan(
                              text: "daily challenges: ",
                              style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                          TextSpan(
                              text:
                              "complete them by doing different actions ",
                              style: InheritedTextStyle.of(context).kBodyText1Roboto),
                          TextSpan(
                              text:
                              "in the app.",
                              style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                        ]),
                      ),
                    ),
                  ],
                ),
              );
            }
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
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW - 40,
                height: screenH,
                child: Padding(
                  padding: EdgeInsets.only(top: screenH/2,),
                  child: Row(
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(style: InheritedTextStyle.of(context).kBodyText1Roboto, children: [
                            TextSpan(
                                text: "You just completed this one, so it has updated ", style: InheritedTextStyle.of(context).kBodyText1Roboto),
                            TextSpan(
                                text: "automatically.",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":true
        },
      }/*,{ // 17th item ; index : 16
        "widget": FadeInPositioned(
          top: screenH/3,
          left: 20,
          right: 20,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW - 40,
                height: screenH,
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(style: InheritedTextStyle.of(context).kBodyText1Roboto, children: [
                            TextSpan(
                                text: "Now, ", style: InheritedTextStyle.of(context).kBodyText1Roboto),
                            TextSpan(
                                text: "this challenge ",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                            TextSpan(
                                text: "has been unlocked, ", style: InheritedTextStyle.of(context).kBodyText1Roboto),
                            TextSpan(
                                text: "complete it ",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                            TextSpan(
                                text: "to get it's ", style: InheritedTextStyle.of(context).kBodyText1Roboto),
                            TextSpan(
                                text: "reward.",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary)),
                            TextSpan(
                                text: "\n You can also skip this for now if you want (\"Next\" button on the bottom-right corner)",
                                style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kText80, fontSizeFactor: 0.9)),
                          ]),
                        ),
                      ),
                    ],
                  ),
              );
            }
          ),
        ),
        "controlButtonsEnabled":{
          "back":false,
          "next":true
        },
      }*/,{ // index : 17
        "widget":FadeInPositioned(
          left: 20,
          right: 20,
          child: Builder(
            builder: (context) {
              return SizedBox(
                width: screenW-40,
                height: screenH-70,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
                  child: Column(mainAxisAlignment:MainAxisAlignment.center, children: [
                    Text("Tutorial completed!", style: InheritedTextStyle.of(context).kHeadline1.apply(fontSizeFactor: 1.2, color: kGreen),),
                    const SizedBox(height: 28,),
                    Row(
                      children: [
                        Expanded(
                          child: RichText(
                            text: TextSpan(style: InheritedTextStyle.of(context).kBodyText1Roboto, children: [
                              TextSpan(
                                  text: "Go enjoy the app! If you’ve got any ",
                                  style: InheritedTextStyle.of(context).kBodyText1Roboto
                              ),
                              TextSpan(text: "questions ", style:InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary )),
                              TextSpan(text: "or ", style: InheritedTextStyle.of(context).kBodyText1Roboto ),
                              TextSpan(text: "issue", style:InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kPrimary) ),
                              TextSpan(text: ", send us a message! (on Instagram, Discord, or contact email...).", style:InheritedTextStyle.of(context).kBodyText1Roboto ),
                            ]),
                          ),
                        ),
                      ],
                    )
                  ],),
                ),
              );
            }
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