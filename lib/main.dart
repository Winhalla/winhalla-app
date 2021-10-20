import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:winhalla_app/screens/home.dart';
import 'package:winhalla_app/screens/play.dart';
import 'package:winhalla_app/screens/quests.dart';
import 'package:winhalla_app/screens/shop.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/userClass.dart';
import 'package:winhalla_app/widgets/app_bar.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:provider/provider.dart';
import 'config/themes/dark_theme.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static const List<Widget> screenList = [MyHomePage(), Quests(), PlayPage(),Shop()];

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winhalla',
      theme: ThemeData(fontFamily: "Bebas Neue"),

      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => SafeArea(
            child: FutureBuilder(
                future: initUser(),
                builder: (context, AsyncSnapshot<dynamic> res) {

                  if (res.data == "no data" || res.data?["data"].body == "") {
                    return LoginPage();
                  }
                  if (!res.hasData) return AppCore(isUserDataLoaded: false);
                  var providerData = jsonDecode(res.data["data"].body);
                  providerData["authKey"] = res.data["authKey"];
                  return ChangeNotifierProvider<User>(
                      create: (_) => new User(providerData),
                      child: AppCore(
                        isUserDataLoaded: true,
                      ));
                })),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class AppCore extends StatefulWidget {
  final bool isUserDataLoaded;

  AppCore({Key? key, required this.isUserDataLoaded}) : super(key: key);

  @override
  _AppCoreState createState() => _AppCoreState();
}

class _AppCoreState extends State<AppCore> {
  int _selectedIndex = 0;
  switchPage(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(134),
          child: MyAppBar(widget.isUserDataLoaded)),
      body: widget.isUserDataLoaded
          ? _selectedIndex == 2 ||
                  _selectedIndex ==
                      1 // If the page is a solo match, do not make it scrollable by default, because it's already a ListView
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(32, 15, 32, 0),
                  child: MyApp.screenList[_selectedIndex],
                )
              : SingleChildScrollView(
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 15, 32, 0),
                  child: MyApp.screenList[_selectedIndex],
                ))
          : Center(
              child: Container(
                  padding: EdgeInsets.only(left: 20, right: 10),
                  margin: EdgeInsets.only(top: 20),
                  child: Column(children: const [
                    Text(
                      'Loading...',
                      style: TextStyle(color: kText, fontSize: 50),
                    ),
                    Text(
                      'This might take a moment depending of your internet connection.',
                      style: TextStyle(color: kText, fontSize: 20),
                    ),
                  ]))),
      bottomNavigationBar: Container(
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
          )),
    );
  }
}
