import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:winhalla_app/screens/home.dart';
import 'package:winhalla_app/screens/play.dart';
import 'package:winhalla_app/screens/quests.dart';
import 'package:winhalla_app/screens/shop.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/user_class.dart';
import 'package:winhalla_app/widgets/app_bar.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:provider/provider.dart';
import 'config/themes/dark_theme.dart';

void main() async {
  runApp(const MyApp());
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
                  if (!res.hasData) return const AppCore(isUserDataLoaded: false);
                  if (res.data == "no data" || res.data["data"] == "" || res.data["data"] == null) {
                    return LoginPage(userData:res.data);
                  }
                  if(res.data["data"]["user"] == null) return LoginPage(userData: res.data);
                  // Do not edit res.data directly otherwise it calls the build function again for some reason
                  var newData = res.data as Map<String,dynamic>;
                  var callApi = res.data["callApi"];
                  newData["callApi"] = null;
                  newData["user"] = res.data["data"]["user"];
                  newData["steam"] = res.data["data"]["steam"];
                  FirebaseAnalytics.instance.logAppOpen();
                  // newData["data"] = null;
                  return ChangeNotifierProvider<User>(
                      create: (_) => User(newData,callApi),
                      child: const AppCore(
                        isUserDataLoaded: true,
                      ),
                  );
                }),
        ),
        '/login': (context) => LoginPage(),
      },
    );
  }
}

class AppCore extends StatefulWidget {
  final bool isUserDataLoaded;

  const AppCore({Key? key, required this.isUserDataLoaded}) : super(key: key);

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
    setState(() {
      _selectedIndex = index;
    });
    FirebaseAnalytics.instance.logScreenView(screenClass: "HomeClass",screenName: indexToScreenName(index));
  }
  @override
  void initState(){
    screenList = [MyHomePage(switchPage: switchPage,), const Quests(), const PlayPage(),const Shop()];
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackground,
        appBar: !widget.isUserDataLoaded
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(134),
                child: MyAppBar(widget.isUserDataLoaded)),
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
                padding: const EdgeInsets.only(left: 40,right: 40,bottom:40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Expanded(
                      child: RiveAnimation.asset(
                        "assets/animated/loading.riv",
                      ),
                    ),
                    Text("Loading...",style: kHeadline1,),
                    SizedBox(height: 15,),
                    Padding(
                      padding: EdgeInsets.only(right: 7.0),
                      child: CircularProgressIndicator(),
                    )
                  ],
                ),
              ),
        bottomNavigationBar: !widget.isUserDataLoaded
            ? null
            : Container(
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
                          child: Icon(
                            Icons.play_circle_outline_outlined,
                            color: _selectedIndex == 2 ? kPrimary : kText95,
                            size: 34,
                          ),
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
              ));
  }
}
