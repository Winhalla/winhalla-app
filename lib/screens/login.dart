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
    AccountCreation()
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
                    create: (_) =>
                        LoginPageManager(step.data == "no data" ? 0 : int.parse(step.data as String)),
                    child: Consumer<LoginPageManager>(builder: (context, page, _) {
                      return screenList[page.page == "no data" ? 0 : page.page];
                    })) // Can't be null but the compiler doesn't sees it so bidouillage
                ),
          );
        });
  }
}

class AccountCreation extends StatefulWidget {
  const AccountCreation({Key? key}) : super(key: key);

  @override
  _AccountCreationState createState() => _AccountCreationState();
}

class _AccountCreationState extends State<AccountCreation> {
  Map<String, dynamic>? gAccount;

  List<dynamic> accounts = [];

  List<Map<String, String>> items = [
    {'name': "Steam (PC)", "file": "steam"},
    {'name': "PS3/4/5", "file": "ps"},
    {'name': "Xbox One/Series", "file": "xbox"},
    {'name': "Nintendo Switch", "file": "switch"},
    {"name": "Mobile", "file": 'phone'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 70, 32, 0),
      child: Column(
        children: [
          const Text(
            "Link a Brawlhalla account",
            style: TextStyle(color: kText, fontSize: 50),
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            "Link at least one Brawlhalla account",
            style: TextStyle(color: kText80, fontSize: 26, fontFamily: "Roboto Condensed"),
          ),
          const SizedBox(
            height: 50,
          ),
          ListView.builder(
            itemCount: accounts.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: const EdgeInsets.fromLTRB(25, 20, 25, 20),
                margin: EdgeInsets.only(top: index == 0 ? 0 : 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: kEpic,
                    width: 1,
                  ),
                  color: kBackgroundVariant,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 3.0),
                      child: Image.asset(
                        "assets/images/icons/pink/${accounts[index]["file"]}Pink.png",
                        height: 30,
                      ),
                    ),
                    SizedBox(
                      width: 30,
                    ),
                    Text(
                      accounts[index]["name"],
                      style: kBodyText1.apply(color: kEpic),
                    )
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 50),
          if (accounts.length < 3)
            GestureDetector(
              child: Container(
                padding: const EdgeInsets.fromLTRB(30, 20, 30, 20),
                decoration: BoxDecoration(
                  color: kBackgroundVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.add_circle_outline,
                      color: kPrimary,
                      size: 34,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        "Add an account",
                        style: kBodyText1.apply(color: kPrimary),
                      ),
                    )
                  ],
                ),
              ),
              onTap: () async {
                var result =
                    await showDialog(context: context, builder: (context) => PopupWidget(context, items));
                if (result != null)
                  setState(() {
                    accounts.add(result);
                    items.removeWhere((item) => item["file"] == result["file"]);
                  });
              },
            ),
          Expanded(
            child: Text(""),
          ),
          if (accounts.length > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    margin: const EdgeInsets.only(bottom: 50),
                    decoration: BoxDecoration(
                      color: kBackgroundVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: GestureDetector(
                      onTap: () async {
                        print("test");
                        final authKey = await secureStorage.read(key: "authKey");
                        if (authKey == null) {
                          Navigator.pushReplacementNamed(context, "/login");
                          return;
                        }
                        ;
                        var accountData = await http.post(
                            getUri('/auth/createAccount?linkId=null&BID=${accounts[0]["bid"]}'),
                            headers: {"authorization": authKey});
                        try {
                          if (jsonDecode(accountData.body)["accountExists"] == true) return;
                        } catch (e) {
                          // If the response is a string (containing the link ID) bc a string throws an error with jsonDecode()
                          if (ModalRoute.of(context)?.settings.name == "/") {
                            Navigator.pop(context, "/");
                            Navigator.pushNamed(context, "/");
                          } else {
                            Navigator.pushReplacementNamed(context, "/");
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10,6,10,6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Finish",
                              style: kBodyText2.apply(color: kGreen),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 5.0),
                              child: const Icon(
                                Icons.check,
                                color: kGreen,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
              ],
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
                style: TextStyle(fontSize: 30, color: kRed, fontFamily: "Roboto condensed"),
              ),
              const SizedBox(
                width: 7,
              ),
              const Text(
                "Brawlhalla,",
                style: TextStyle(fontSize: 30, color: kText, fontFamily: "Roboto condensed"),
              ),
            ],
          ),
          Row(
            children: [
              const Text(
                "Earn",
                style: TextStyle(fontSize: 30, color: kRed, fontFamily: "Roboto condensed"),
              ),
              const SizedBox(
                width: 7,
              ),
              const Text(
                "Rewards",
                style: TextStyle(fontSize: 30, color: kText, fontFamily: "Roboto condensed"),
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
                  if (temp?['account'].photoUrl != null) "picture": temp?['account'].photoUrl
                });
              } catch (e) {
                print(e);
              }
              await secureStorage.write(key: "authKey", value: jsonDecode(idToken.body)["_id"]);
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
                    ),
                  )
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
