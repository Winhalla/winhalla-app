import 'dart:async';
import 'dart:isolate';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_applovin_max/flutter_applovin_max.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:rive/rive.dart' as Rive;
import 'package:winhalla_app/screens/contact.dart';
import 'package:winhalla_app/screens/home.dart';
import 'package:winhalla_app/screens/play.dart';
import 'package:winhalla_app/screens/quests.dart';
import 'package:winhalla_app/screens/shop.dart';
import 'package:winhalla_app/utils/ad_helper.dart';
import 'package:winhalla_app/utils/ffa_match_class.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/tutorial_controller.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/app_bar.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/widgets/coin_dropdown.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';
import 'package:winhalla_app/widgets/popup_leave_match.dart';
import 'package:winhalla_app/widgets/popup_link.dart';
import 'package:winhalla_app/widgets/popups/popup_ad.dart';
import 'config/themes/dark_theme.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // Non-flutter errors catching
  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
    );
  }).sendPort);
  initializeDateFormatting(Platform.localeName);
  // Flutter errors catching
  runZonedGuarded<Future<void>>(() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      FirebaseRemoteConfig frc = FirebaseRemoteConfig.instance;
      frc.setDefaults(<String, dynamic>{
        'isAdButtonActivated': false,
      });
      frc.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 60),
        minimumFetchInterval: const Duration(minutes: 15),
      ));
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
      FirebaseAnalytics.instance.logAppOpen();
    }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack)
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(builder: (context, orientation, screenType) {
      return InheritedTextStyle(
        kHeadline0: TextStyle(color: kText, fontSize: 33.sp > 60 ? 60 : 33.sp),

        kHeadline1: TextStyle(color: kText, fontSize: 28.sp > 40 ? 40 : 28.sp),

        kHeadline2: TextStyle(color: kText, fontSize: 24.5.sp > 35 ? 35 : 24.5.sp),

        kBodyText1: TextStyle(
          color: kText95,
          fontSize: 22.35.sp > 30 ? 30 : 22.35.sp,
          fontFamily: "Bebas neue",
        ),

        kBodyText1Roboto: TextStyle(color: kText95, fontSize: 22.35.sp > 30 ? 30 : 22.35.sp, fontFamily: "Roboto Condensed"),

        kBodyText1bis: TextStyle(color: kText95, fontSize: 21.35.sp > 26 ? 26 : 21.35.sp),

        kBodyText2: TextStyle(color: kText95, fontSize: 20.sp > 24 ? 24 : 20.sp, fontFamily: "Roboto Condensed"),

        kBodyText2bis: TextStyle(color: kText95, fontSize: 19.sp > 22 ? 22 : 19.sp),

        kBodyText3: TextStyle(color: kText90, fontSize: 18.25.sp > 20 ? 20 : 18.25.sp, fontFamily: "Roboto Condensed"),

        kBodyText4: TextStyle(
          color: kText,
          fontSize: 18.25.sp > 20 ? 20 : 18.25.sp,
          fontFamily: "Bebas neue",
        ),

        child: MaterialApp(
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

                        if (res.data == "no data" || res.data["data"] == "" || res.data["data"] == null) {
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
                        newData["informations"] = res.data["data"]["informations"];
                        newData["tutorial"] = res.data["tutorial"];

                        List<GlobalKey?> keys = [];
                        for (int i = 0; i < 17; i++) {
                          if (i == 0 || i == 4 || i == 5 || i == 10 || i == 11 || i == 16) {
                            keys.add(null);
                          } else {
                            keys.add(GlobalKey());
                          }
                        }
                        var inGameData = newData["user"]["inGame"];
                        var currentMatch = inGameData.where((g) => g["isFinished"] == false).toList();

                        try {
                          FirebaseCrashlytics.instance.setUserIdentifier(newData["steam"]["id"]);
                          FirebaseAnalytics.instance.setUserId(id: newData["steam"]["id"]);
                        } catch (e) {}

                        var inGame;
                        if (currentMatch.length > 0) {
                          inGame = {'id': currentMatch[0]["id"], 'joinDate': currentMatch[0]["joinDate"]};
                        }


                        return ChangeNotifierProvider<User>(
                            create: (_) => User(newData, callApi, keys, inGame, res.data["oldDailyChallengeData"]),
                            child: AppCore(
                              isUserDataLoaded: true,
                              tutorial: newData["tutorial"],
                            ));
                      }),
                ),
            '/login': (context) => SafeArea(child: LoginPage()),
            '/contact': (context) => const SafeArea(child: ContactPage()),
          },
        ),
      );
    });
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
      selectedShopTab = "shop";
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
  String selectedShopTab = "shop";
  @override
  Widget build(BuildContext context) {
    Widget child = GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Stack(
          children: [
            Scaffold(
              floatingActionButton: kDebugMode && widget.isUserDataLoaded ? FloatingActionButton(
                onPressed: ()=>FlutterApplovinMax.showMediationDebugger(),
                child: Image.asset(
                  "assets/images/video_ad.png",
                  color: kText,
                  width: 20,
                ),
              ) : null,
            backgroundColor: kBackground,
            appBar: !widget.isUserDataLoaded
                ? null
                : PreferredSize(
                    preferredSize: Size.fromHeight(14.5.h),
                    child: MyAppBar(widget.isUserDataLoaded, _selectedIndex)),
            body:
                widget.isUserDataLoaded
                    ? _selectedIndex == 2 ||
                            _selectedIndex ==
                                1 // If the page is a solo match or quest, do not make it scrollable by default, because it's already a ListView
                        ? Padding(
                            padding: EdgeInsets.fromLTRB(8.25.w, 1.25.h, 8.25.w, 0),
                            child: screenList[_selectedIndex],
                          )
                        : SingleChildScrollView(
                            child: Padding(
                            padding: EdgeInsets.fromLTRB(8.25.w, 1.25.h, 8.25.w, 0),
                            child: screenList[_selectedIndex],
                          ))
                    : Padding(
                        padding: const EdgeInsets.only(left: 40, right: 40, bottom: 40),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Expanded(
                              child: Rive.RiveAnimation.asset(
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
                : StatefulBuilder(builder: (context, setState) {
                    void rebuildBottomNavbar() {
                      setState(() {});
                    }

                    context
                        .read<User>()
                        .setKeyFx(rebuildBottomNavbar, "rebuildBottomNavbar");
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
                  })),
            if (_selectedIndex == 3) Positioned(
              bottom: 89,
              left: 0,
              child: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        stops: const [0,0.7,1],
                        colors: [
                          kBackground,
                          kBackground.withOpacity(0.67),
                          kBackground.withOpacity(0.0)
                        ]
                    )
                ),
                child: SizedBox(height: 15.h,width: 100.w,),
              ),
            ),
            if (_selectedIndex == 3) Positioned(
              left: 18.w,
              right: 18.w,
              bottom: 2.5.h+89,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 3),
                decoration: BoxDecoration(
                    border: Border.all(color: kBlack, width: 1),
                    borderRadius: BorderRadius.circular(14),
                    color: kBackgroundVariant
                ),
                child: StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              minWidth: 27.5.w,
                              elevation: 0,
                              color: kBackgroundVariant,
                              disabledColor: kBackground,
                              onPressed: selectedShopTab != "shop" ? () {
                                context.read<User>().keyFx["switchShopTab"]("shop");
                                FirebaseAnalytics.instance.setCurrentScreen(screenName: "Shop", screenClassOverride: "MainActivity");
                                setState(() => selectedShopTab = "shop");
                              } : null,
                              padding: EdgeInsets.fromLTRB(6.w, 0.75.h, 6.w, 0.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Text(
                                  "Shop",
                                  style: InheritedTextStyle.of(context).kBodyText1bis.apply(color: selectedShopTab != "shop"? kGray : null)
                              ),
                            ),
                            SizedBox(width: 2.5.w),
                            MaterialButton(
                              minWidth: 27.5.w,
                              elevation: 0,
                              color: kBackgroundVariant,
                              disabledColor: kBackground,
                              onPressed: selectedShopTab == "shop" ? () {
                                context.read<User>().keyFx["switchShopTab"]("orders");
                                FirebaseAnalytics.instance.setCurrentScreen(screenName: "Orders", screenClassOverride: "MainActivity");
                                setState(() => selectedShopTab = "orders");
                              } : null,
                              padding: EdgeInsets.fromLTRB(6.w, 0.75.h, 6.w, 0.5.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.0),
                              ),
                              child: Text("Orders", style: InheritedTextStyle.of(context).kBodyText1bis.apply(color: selectedShopTab == "shop"? kGray : null)),
                            ),
                          ]
                      );
                    }
                ),
              ),
            )
          ],
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
            if(user.value["user"]["needsLinkAlertPopup"] == true){
              user.callApi.post("/deactivateLinkPopup","{}");
              Future.delayed(const Duration(milliseconds: 2500), (){
                late OverlayEntry overlayEntry;
                overlayEntry = OverlayEntry(builder: (_) => LinkActivatedWidget(overlayEntry));
                Overlay.of(context)!.insert(overlayEntry);
              });
            }
            user.setKeyFx(switchPage, "switchPage");
            Future.delayed(const Duration(milliseconds: 100), () async {
              try {
                if (user.value["user"]["solo"]["dailyQuests"].length < 2 &&
                    user.value["user"]["solo"]["lastDaily"] != null) {
                  await user.callApi.get("/newDailyQuestsTutorial");
                }
              } catch (e) {}

              if (user.inGame != null) {
                user.exitMatch(isOnlyLayout: true);
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