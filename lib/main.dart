import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:rive/rive.dart';
import 'package:winhalla_app/screens/home.dart';
import 'package:winhalla_app/screens/play.dart';
import 'package:winhalla_app/screens/quests.dart';
import 'package:winhalla_app/screens/shop.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/tutorial_controller.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/app_bar.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/widgets/coin_dropdown.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';
import 'config/themes/dark_theme.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return InheritedTextStyle(
          kHeadline0: TextStyle(color: kText, fontSize: 33.sp > 60 ? 60 : 33.sp),
          kHeadline1: TextStyle(color: kText, fontSize: 28.sp > 40 ? 40 : 28.sp),
          kHeadline2: TextStyle(color: kText, fontSize: 24.5.sp > 35 ? 35 : 24.5.sp),
          kBodyText1: TextStyle(color: kText95, fontSize: 22.35.sp > 30 ? 30 : 22.35.sp,fontFamily: "Bebas neue",),
          kBodyText1Roboto: TextStyle(color: kText95, fontSize: 22.35.sp > 30 ? 30 : 22.35.sp, fontFamily: "Roboto Condensed"),
          kBodyText1bis: TextStyle(color: kText95, fontSize: 21.35.sp > 26 ? 26 : 21.35.sp), //TODO: review this value (the .sp part)
          kBodyText2: TextStyle(color: kText95, fontSize: 20.sp > 24 ? 24 : 20.sp, fontFamily: "Roboto Condensed"),
          kBodyText2bis: TextStyle(color: kText95, fontSize: 19.sp > 22 ? 22 : 19.sp), //TODO: review this value (the .sp part)
          kBodyText3: TextStyle(color: kText90, fontSize: 18.25.sp > 20 ? 20 : 18.25.sp,fontFamily: "Roboto Condensed"),
          kBodyText4: TextStyle(color: kText, fontSize: 18.25.sp > 20 ? 20 : 18.25.sp),
          child: MaterialApp(
            title: 'Winhalla',
            theme: ThemeData(fontFamily: "Bebas Neue"),
            debugShowCheckedModeBanner: false,
            // Start the app with the "/" named route. In this case, the app starts
            // on the FirstScreen widget.
            initialRoute: '/',
            routes: {
              '/': (context) =>
                  SafeArea(
                    child: FutureBuilder(
                        future: initUser(context),
                        builder: (context, AsyncSnapshot<dynamic> res) {
                          if (!res.hasData) {
                            return const AppCore(isUserDataLoaded: false);
                          }

                          if (res.data == "no data" ||
                              res.data["data"] == "" ||
                              res.data["data"] == null) {
                            return LoginPage(userData: res.data);
                          }

                          if (res.data["data"]["user"] == null) {
                            return LoginPage(userData: res.data);
                          }

                          // Do not edit res.data directly otherwise it calls the build function again for some reason
                          Map<String, dynamic> newData = res.data as Map<String, dynamic>;
                          var callApi = res.data["callApi"];

                          newData["callApi"] = null;
                          newData["user"] = res.data["data"]["user"];
                          newData["steam"] = res.data["data"]["steam"];
                          newData["tutorial"] = res.data["tutorial"];

                          List<GlobalKey?> keys = [];
                          for (int i = 0; i < 18; i++) {
                            if (i == 0 ||
                                i == 4 ||
                                i == 5 ||
                                i == 10 ||
                                i == 11 ||
                                i == 17) {
                              keys.add(null);
                            } else {
                              keys.add(GlobalKey());
                            }
                          }
                          var inGameData = newData["user"]["inGame"];
                          var currentMatch = inGameData
                              .where((g) => g["isFinished"] == false)
                              .toList();

                          var inGame = null;
                          if (currentMatch.length > 0) {
                            inGame = {
                              'id': currentMatch[0]["id"],
                              'joinDate': currentMatch[0]["joinDate"]
                            };
                          }

                          return ChangeNotifierProvider<User>(
                              create: (_) => User(newData, callApi, keys, inGame, res.data["oldDailyChallengeData"]),
                              child: AppCore(
                                isUserDataLoaded: true,
                                tutorial: newData["tutorial"],
                              ));
                        }),
                  ),
              '/login': (context) => LoginPage(),
            },
          ),
        );
      }
    );
  }
}

class AppCore extends StatefulWidget {
  final bool isUserDataLoaded;
  final tutorial;

  const AppCore({Key? key, required this.isUserDataLoaded, this.tutorial})
      : super(key: key);

  @override
  _AppCoreState createState() => _AppCoreState();
}

class _AppCoreState extends State<AppCore> {
  int _selectedIndex = 0;
  List<Widget> screenList = [];
  void switchPage(index) {
    if (context.read<User>().inGame?["showMatch"] == false) {
      context.read<User>().resetInGame();
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    screenList = [
      MyHomePage(
        switchPage: switchPage,
      ),
      const Quests(),
      const PlayPage(),
      const Shop()
    ];
    super.initState();
  }

  bool hasSummonedTutorial = false;

  @override
  Widget build(BuildContext context) {
    Widget child = Scaffold(
        backgroundColor: kBackground,
        appBar: !widget.isUserDataLoaded
            ? null
            : PreferredSize(
                preferredSize: Size.fromHeight(18.h),
                child: MyAppBar(widget.isUserDataLoaded, _selectedIndex)),
        body: widget.isUserDataLoaded
            ? _selectedIndex == 2 ||
                    _selectedIndex ==
                        1 // If the page is a solo match or quest, do not make it scrollable by default, because it's already a ListView
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: screenList[_selectedIndex],
                  )
                : SingleChildScrollView(
                    child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
                    child: screenList[_selectedIndex],
                  ))
            : Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: RiveAnimation.asset(
                        "assets/animated/loading.riv",
                      ),
                    ),
                    Text(
                      "Loading...",
                      style: InheritedTextStyle.of(context).kHeadline1,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 7.0),
                      child: CircularProgressIndicator(),
                    )
                  ],
                ),
              ),
        bottomNavigationBar: !widget.isUserDataLoaded
            ? null
            : StatefulBuilder(
              builder: (context,setState) {
                void rebuildBottomNavbar(){
                  setState((){});
                }
                context.read<User>().setKeyFx(rebuildBottomNavbar, "rebuildBottomNavbar");
                return Container(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    decoration: const BoxDecoration(
                      color: kBackground,
                      /*boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, -8),
                                      blurRadius: 8,
                                      color: Colors.black.withOpacity(0.20)
                                    )
                                  ]*/
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              switchPage(0);
                            },
                            child: SizedBox(
                              height: 90,
                              child: Icon(
                                Icons.home_outlined,
                                key: context.read<User>().keys[13],
                                color: _selectedIndex == 0 ? kPrimary : kText95,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              switchPage(1);
                            },
                            child: SizedBox(
                              height: 90,
                              child: Icon(
                                Icons.check_box_outlined,
                                key: context.read<User>().keys[8],
                                color: _selectedIndex == 1 ? kPrimary : kText95,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              switchPage(2);
                            },
                            child: SizedBox(
                              height: 90,
                              child: Consumer<User>(builder: (context, user, _) {
                                /*if (user.inGame == false) {
                                    Future.delayed(Duration(milliseconds: 1), () {
                                      switchPage(0);
                                    });
                                  }*/
                                return Icon(
                                  Icons.play_circle_outline_outlined,
                                  key: user.keys[1],
                                  color: _selectedIndex == 2
                                      ? kPrimary
                                      : user.inGame != null &&
                                              user.inGame["showActivity"] !=
                                                  false &&
                                              user.inGame != false &&
                                              user.inGame["joinDate"] +
                                                      3600 * 1000 >
                                                  DateTime.now()
                                                      .millisecondsSinceEpoch
                                          ? kOrange
                                          : kText95,
                                  size: 34,
                                );
                              }),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              switchPage(3);
                            },
                            child: SizedBox(
                              height: 90,
                              child: Icon(
                                Icons.card_giftcard,
                                color: _selectedIndex == 3 ? kPrimary : kText95,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
              }
            ));
    if (widget.tutorial?["needed"] == true) {
      double screenH = MediaQuery.of(context).size.height;
      double screenW = MediaQuery.of(context).size.width;
      return ChangeNotifierProvider<TutorialController>(
        create: (context) => TutorialController(widget.tutorial["tutorialStep"],
            context.read<User>().keys, screenW, screenH, context),
        child: Builder(builder: (context) {
          if (!hasSummonedTutorial) {
            hasSummonedTutorial = true;
            User user = context.read<User>();
            user.setKeyFx(switchPage, "switchPage");
            Future.delayed(const Duration(milliseconds: 100), () async {
              try{
                if(user.value["user"]["solo"]["dailyQuests"].length < 2 && user.value["user"]["solo"]["lastDaily"] != null) {
                  await user.callApi.get("/newDailyQuestsTutorial");
                }
              }catch(e){}

              if(user.inGame != null){
                user.exitMatch(isOnlyLayout:true);
              }
              context.read<TutorialController>().summon(context);
            });
          }
          return child;
        }),
      );
    } else {
      return child;
    }
  }
}
/*
/// Text size tester
Scaffold(
  backgroundColor: kBackground,
  body: Padding(
    padding: const EdgeInsets.all(20.0),
    child: Column(
      children: [
        Row(
          children: [
            Text("TEST text", style: InheritedTextStyle.of(context).kHeadline1,),
            const SizedBox(width: 10,),
            Text("TEST text", style: kHeadline1,),
        ],),Row(
          children: [
            Text("TEST text", style: InheritedTextStyle.of(context).kHeadline2,),
            const SizedBox(width: 10,),
            Text("TEST text", style: kHeadline2,),
        ],),Row(
          children: [
            Text("TEST text", style: InheritedTextStyle.of(context).kBodyText1,),
            const SizedBox(width: 10,),
            Text("TEST text", style: kBodyText1,),
        ],),Row(
          children: [
            Text("TEST text", style: InheritedTextStyle.of(context).kBodyText1Roboto,),
            const SizedBox(width: 10,),
            Text("TEST text", style: kBodyText1Roboto,),
        ],),Row(
          children: [
            Text("TEST text", style: InheritedTextStyle.of(context).kBodyText2,),
            const SizedBox(width: 10,),
            Text("TEST text", style: kBodyText2,),
        ],),Row(
          children: [
            Text("TEST text", style: InheritedTextStyle.of(context).kBodyText3,),
            const SizedBox(width: 10,),
            Text("TEST text", style: kBodyText3,),
        ],),Row(
          children: [
            Text("TEST text", style: InheritedTextStyle.of(context).kBodyText4,),
            const SizedBox(width: 10,),
            Text("TEST text", style: kBodyText4,),
        ],),
      ],
    ),
  ),
),*/