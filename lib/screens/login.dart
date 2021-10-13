import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import 'package:steam_login/steam_login.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:winhalla_app/utils/steam.dart';
import 'package:winhalla_app/utils/userClass.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:winhalla_app/widgets/popup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Map<String, dynamic>? gAccount;

  List<Widget> screenList = [
    WinhallaPresentation(),
    GoogleAppleLogin(),
    // SteamLogin(),
    WinhallaAccountCreation()
  ];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getNonNullSSData("loginStep"),
        builder: (context, AsyncSnapshot<String> step) {
          if (!step.hasData)
            return SafeArea(
              child: Scaffold(
                  backgroundColor: kBackground,
                  body: Center(
                    child: Text(
                      "Loading...",
                      style: kHeadline1,
                    ),
                  )),
            );
          return SafeArea(
            child: Scaffold(
                backgroundColor: kBackground,
                body: ChangeNotifierProvider<LoginPageManager>(
                    create: (_) => LoginPageManager(step.data == "no data"
                        ? 0
                        : int.parse(step.data as String)),
                    child:
                        Consumer<LoginPageManager>(builder: (context, page, _) {
                      return screenList[page.page == "no data" ? 0 : page.page];
                    })) // Can't be null but the compiler doesn't sees it so bidouillage
                ),
          );
        });
  }
}

class WinhallaAccountCreation extends StatelessWidget {
  WinhallaAccountCreation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 70, 32, 0),
      child: Column(
        children: [
          Text(
            "Link a Brawlhalla account",
            style: TextStyle(color: kText, fontSize: 50),
          ),
          SizedBox(height: 10,),
          Text(
            "Link at least one Brawlhalla account",
            style: TextStyle(color: kText80, fontSize: 26,fontFamily: "Roboto Condensed"),
          ),
          SizedBox(height: 50,),
          GestureDetector(
            child: Container(
              padding: EdgeInsets.fromLTRB(30, 20, 30, 20),
              decoration: BoxDecoration(
                color: kBackgroundVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: kPrimary,
                    size: 34,
                  ),
                  Text(
                    "Add an account",
                    style: kBodyText1.apply(color: kPrimary),
                  )
                ],
              ),
            ),
            onTap: ()async {
              print(await showDialog(context: context, builder: (context) => PopupWidget(context)));
            },
          )
        ],
      ),
    );
  }
}

class GoogleAppleLogin extends StatelessWidget {
  const GoogleAppleLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(42.5, 0, 42.5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Welcome to",
            style: TextStyle(
              fontSize: 60,
              color: kText,
            ),
          ),
          Row(
            children: [
              const Text(
                "Winhalla",
                style: TextStyle(fontSize: 60, color: kPrimary, height: 1),
              ),
              const Text(
                "!",
                style: TextStyle(fontSize: 60, color: kText, height: 1),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            children: [
              const Text(
                "Play",
                style: TextStyle(
                    fontSize: 30, color: kRed, fontFamily: "Roboto condensed"),
              ),
              const SizedBox(
                width: 7,
              ),
              const Text(
                "Brawlhalla,",
                style: TextStyle(
                    fontSize: 30, color: kText, fontFamily: "Roboto condensed"),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                "Earn",
                style: TextStyle(
                    fontSize: 30, color: kRed, fontFamily: "Roboto condensed"),
              ),
              const SizedBox(
                width: 7,
              ),
              const Text(
                "Rewards",
                style: TextStyle(
                    fontSize: 30, color: kText, fontFamily: "Roboto condensed"),
              ),
            ],
          ),
          SizedBox(
            height: 150,
          ),
          GestureDetector(
            onTap: () async {
              var temp = await GoogleSignInApi.login();
              if (temp?["auth"].accessToken == null) return;
              dynamic idToken;
              try {
                idToken = await http.post(getUri("/auth/createToken"), body: {
                  "token": temp?["auth"].accessToken,
                  "name": temp?['account'].displayName,
                  if (temp?['account'].photoUrl != null)
                    "picture": temp?['account'].photoUrl
                });
              } catch (e) {
                print(e);
              }
              print("ID: $idToken");
              await secureStorage.write(
                  key: "authKey", value: jsonDecode(idToken.body)["_id"]);
              context.read<LoginPageManager>().next();
            },
            child: Container(
              decoration: BoxDecoration(
                color: kBlack,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.fromLTRB(26.5, 20, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/google_icon.png",
                    height: 32,
                    width: 32,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1.5),
                    child: Text(
                      "Sign in with Google",
                      style: kBodyText2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          GestureDetector(
            onTap: () {
              print("apple login");
            },
            child: Container(
              decoration: BoxDecoration(
                color: kBlack,
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.fromLTRB(25, 20, 20, 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/images/apple_icon.png",
                    height: 32,
                    width: 32,
                    color: kText90,
                  ),
                  SizedBox(
                    width: 18,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 1.5),
                    child: Text(
                    "Sign in with Apple",
                    style: kBodyText2,
                  ),)
                ],
              ),
            ),
          )
        ],
      ),
    );
    /*return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: Consumer<LoginPageManager>(builder: (context, page, _) {
                return GestureDetector(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(19, 9, 19, 6),
                    child: Text(
                      'Login With google',
                      style: kHeadline1.apply(color: kRed),
                    ),
                    decoration: BoxDecoration(
                      color: kBackgroundVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  Text(
                    "Sign in with Google",
                    style: kBodyText2,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class WinhallaPresentation extends StatelessWidget {
  const WinhallaPresentation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 50, 30, 0),
        child: Column(
          children: [
            Text(
              "Winhalla Presentation here",
              style: kHeadline1,
            ),
            Consumer<LoginPageManager>(
              builder: (context, page, _) => TextButton(
                onPressed: () => page.next(),
                child: Text(
                  "Go to next page",
                  style: kBodyText2.apply(
                    fontFamily: "Bebas neue",
                    color: kPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleSignInApi {
  static final _googleSignIn = GoogleSignIn();

  static Future<Map<String, dynamic>?> login() async {
    var test = await _googleSignIn.signIn();
    var ggAuth = await test?.authentication;

    return {"account": test, "auth": ggAuth};
  }

  static Future logout() => _googleSignIn.disconnect();
}

class LoginPageManager extends ChangeNotifier {
  int page = 0;

  void changePage(number) {
    page = number;
    notifyListeners();
  }

  void next() {
    page++;
    notifyListeners();
  }

  LoginPageManager(page) {
    this.page = page;
  }
}
