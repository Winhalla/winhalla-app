import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:rive/rive.dart' as rive;
import 'package:winhalla_app/screens/contact.dart';
import 'package:winhalla_app/screens/home.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:winhalla_app/screens/play.dart';
import 'package:winhalla_app/screens/quests.dart';
import 'package:winhalla_app/screens/shop.dart';
import 'package:winhalla_app/utils/build_app_controller.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/firebase_notifications.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/tutorial_controller.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/app_bar.dart';
import 'package:winhalla_app/widgets/info_dropdown.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';
import 'package:winhalla_app/widgets/popup_link.dart';

import 'config/themes/dark_theme.dart';

final facebookAppEvents = FacebookAppEvents();
const MethodChannel _channel = MethodChannel('winhalla.app/methodChannel');
void main() async {
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
    GlobalKey<NavigatorState> navKey = GlobalKey();
    runApp(MyApp(navKey: navKey));
    initializeDateFormatting(Platform.localeName);


    for (int i = 0; i < notificationChannelsMaps.length; i++){
      if(i == notificationChannelsMaps.length - 1){
        await _channel.invokeMethod('createNotificationChannel', notificationChannelsMaps[i]).then((e)=>null);
      } else {
        _channel.invokeMethod('createNotificationChannel', notificationChannelsMaps[i]).then((e)=>null);
      }
    }
    facebookAppEvents.setAutoLogAppEventsEnabled(true);
    await Firebase.initializeApp();
    // -------------- Firebase messaging -------------
    FirebaseMessaging.onBackgroundMessage(firebaseNotifications);
    FirebaseMessaging.onMessage.listen(firebaseNotifications);
    void handleMessage(RemoteMessage message) async {

      if(navKey.currentContext != null) {
        Navigator.of(navKey.currentContext as BuildContext).pushNamedAndRemoveUntil(
            message.data["route"],
                (route) => false,
            arguments: message.data);
      }
    }
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage);
    }

    // -------------- Firebase Dynamic Links -------------
  FirebaseDynamicLinks.instance.onLink.listen((PendingDynamicLinkData dynamicLinkData) {
    print("sentToLink ${dynamicLinkData.link.toString()}");
    Navigator.of(navKey.currentContext as BuildContext).pushNamedAndRemoveUntil(
      dynamicLinkData.link.toString(),
          (route) => false,
    );
  });

  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  if(initialLink != null){
    print("sentToLink ${initialLink.link.toString()}");
    Navigator.of(navKey.currentContext as BuildContext).pushNamedAndRemoveUntil(
      initialLink.link.toString(),
          (route) => false,
    );
  }


  // -------------- Firebase Remote config -------------
    FirebaseRemoteConfig frc = FirebaseRemoteConfig.instance;
    frc.setDefaults(<String, dynamic>{
      'isAdButtonActivated': false,
    });
    frc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 60),
      minimumFetchInterval: const Duration(minutes: 15),
    ));
    frc.fetchAndActivate();
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack)
  );
}

class MyApp extends StatelessWidget {
  final GlobalKey<NavigatorState> navKey;
  const MyApp({Key? key, required this.navKey}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    facebookAppEvents.logViewContent(content: {"page": "main"});
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
        child:  MaterialApp(
          navigatorKey: navKey,
            title: 'Winhalla',
            theme: ThemeData(fontFamily: "Bebas Neue"),
            debugShowCheckedModeBanner: false,
            // Start the app with the "/" named route. In this case, the app starts
            // on the FirstScreen widget.
            initialRoute: '/',
            onGenerateRoute: (RouteSettings settings) {

              Uri? uri = Uri.tryParse(apiUrl + (settings.name ?? "/"));
              if(uri != null && uri.path == "/auth/steamCallback" && uri.queryParameters.isNotEmpty){
                // Navigator.of(context).pop();
                return MaterialPageRoute(
                    settings: settings,
                    builder: (_)=> SafeArea(child: LoginPage(stepOverride: 2, steamLoginUri: uri))
                );
              }



              print(uri?.queryParameters);
              if(uri != null){
                if(uri.path.contains("/home")){
                  int pageNb = 0;
                  if(uri.queryParameters["page"] != null){
                    pageNb = int.tryParse(uri.queryParameters["page"] as String) ?? 0;
                  }
                  return buildAppController(pageNb, settings);
                }
                if(uri.path.startsWith("/sponsorship/")){
                  secureStorage.read(key: "authKey").then((value) {
                    if(value == null) {
                      secureStorage.write(key: "sponsorshipReferral", value: uri.path.substring("/sponsorship/".length));
                      print("test");
                      showInfoDropdown(
                        context,
                        kPrimary,
                        "Note",
                        body: Text(
                          "Has wrote referral link",
                          style: Theme.of(context)
                              .textTheme
                              .bodyText2
                              ?.merge(InheritedTextStyle.of(context).kBodyText1bis),
                        ),
                        // fontSize: 25,
                        column: true,
                      );
                    }
                  });
                }
              }

              switch (settings.name) {
                case "/contact":
                  return MaterialPageRoute(
                      settings: settings,
                    builder: (context) {
                      return const SafeArea(child: ContactPage());
                    }
                  );
                case "/login":
                  return MaterialPageRoute(
                      settings: settings,
                    builder: (_)=> SafeArea(child: LoginPage())
                  );
                case "/":
                  return buildAppController(0, settings);
                default:
                  return buildAppController(0, settings);
              }
            },
        ),
      );
    });
  }
}

class AppCore extends StatefulWidget {
  final bool isUserDataLoaded;
  final tutorial;
  final int startIndex;

  const AppCore({Key? key, required this.isUserDataLoaded, this.tutorial, this.startIndex = 0})
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
    _selectedIndex = widget.startIndex;
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
                onPressed: () {
                  context.read<User>().refresh();
                  setState(() {
                    _selectedIndex = 0;
                  });
                  // FlutterApplovinMax.showMediationDebugger();
                  // launchURLBrowser(apiUrl+"/auth/steamCallback?t=q");
                },
                child: const Icon(Icons.refresh)
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
                              child: rive.RiveAnimation.asset(
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
              child: IgnorePointer(
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
void createNotificationChannel(){

}