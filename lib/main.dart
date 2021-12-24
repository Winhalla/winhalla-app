import 'dart:async';
import 'dart:isolate';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
import 'config/themes/dark_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  // Non-flutter errors catching
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);

  // Flutter errors catching
  runZonedGuarded<Future<void>>(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

      if (kDebugMode) {
        // Force disable Crashlytics collection while doing every day development.
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(false);
      } else {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      }

      runApp(const MyApp());
    }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack)
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}
class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winhalla',
      theme: ThemeData(fontFamily: "Bebas Neue"),
      debugShowCheckedModeBanner: false,
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        '/': (context) => SafeArea(
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

                    try{
                      FirebaseAnalytics.instance.logAppOpen();
                      FirebaseCrashlytics.instance.setUserIdentifier(newData["steam"]["id"]);
                      FirebaseAnalytics.instance.setUserId(
                          id: newData["steam"]["id"]
                      );
                    } catch(e){}



                    var inGame = null;
                    if (currentMatch.length > 0) {
                      inGame = {
                        'id': currentMatch[0]["id"],
                        'joinDate': currentMatch[0]["joinDate"]
                      };
                    }
                    /*Future.delayed(const Duration(milliseconds:1),(){
                      showCoinDropdown(context, 1315.6, 100);
                    });*/

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
  String indexToScreenName(int index){
    switch (index) {
      case 0:
        return "Home";
      case 1:
        return "Quests";
      case 2:
        return "Play";
      case 3:
        return "Shop";
      default:
        return "Unknown page";
    }
  }
  void switchPage(index) {
    if (context.read<User>().inGame?["showMatch"] == false) {
      context.read<User>().resetInGame();
    }
    setState(() {
      _selectedIndex = index;
    });
    FirebaseAnalytics.instance.logScreenView(screenName: indexToScreenName(index));
    FirebaseAnalytics.instance.setCurrentScreen(screenName: indexToScreenName(index));
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
                preferredSize: const Size.fromHeight(134),
                child: MyAppBar(widget.isUserDataLoaded, _selectedIndex)),
        body: widget.isUserDataLoaded
            ? _selectedIndex == 2 ||
                    _selectedIndex ==
                        1 // If the page is a solo match or quest, do not make it scrollable by default, because it's already a ListView
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(32, 15, 32, 0),
                    child: screenList[_selectedIndex],
                  )
                : SingleChildScrollView(
                    child: Padding(
                    padding: const EdgeInsets.fromLTRB(32, 15, 32, 0),
                    child: screenList[_selectedIndex],
                  ))
            : Padding(
                padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Expanded(
                      child: RiveAnimation.asset(
                        "assets/animated/loading.riv",
                      ),
                    ),
                    Text(
                      "Loading...",
                      style: kHeadline1,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
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
              FirebaseAnalytics.instance.logTutorialBegin();
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
