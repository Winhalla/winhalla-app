import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:winhalla_app/widgets/popup.dart';


class LoginPage extends StatelessWidget {
  final userData;
  final accounts;
  LoginPage({Key? key, this.userData, this.accounts}) : super(key: key);

  int step = 0;
  @override
  Widget build(BuildContext context) {

    List<Widget> screenList = [
      // WinhallaPresentation(),
      const GoogleAppleLogin(),
      // SteamLogin(),
      AccountCreation(accounts: accounts)
    ];

    if(userData?["data"]?["steam"] != null) step = 1;
    if(accounts != null) step = 1;


    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackground,
        body: ChangeNotifierProvider<LoginPageManager>(
          create: (_) => LoginPageManager(step),
          child: Consumer<LoginPageManager>(
            builder: (context, page, _) {
              return screenList[page.page];
            },
          ),
        ),
      ),
    );
  }
}

class AccountCreation extends StatefulWidget {
  final accounts;
  const AccountCreation({Key? key, this.accounts}) : super(key: key);

  @override
  _AccountCreationState createState() => _AccountCreationState();
}

class _AccountCreationState extends State<AccountCreation> {
  List<dynamic> accounts = [];
  Map<String, dynamic>? gAccount;
  String? steamId;
  bool alreadyCreatedAccount = false;
  String file = "file";
  List<Map<String, String>> items = [
    {'name': "Steam (PC)", "file": "steam"},
    {'name': "PS3/4/5", "file": "ps"},
    {'name': "Xbox One/Series", "file": "xbox"},
    {'name': "Nintendo Switch", "file": "switch"},
    {"name": "Mobile", "file": 'phone'},
  ];
  String? _err;
  @override
  Widget build(BuildContext context) {
    if(widget.accounts != null && alreadyCreatedAccount == false) {
      accounts = widget.accounts;
      for (int i = 0; i < accounts.length; i++) {
        for (int ii = 0; ii < items.length; ii++) {
          var element = items[ii];

          if(element["file"] == accounts[i]["platformId"]){
            items.removeAt(ii);
          }
        }
      }
      alreadyCreatedAccount = true;
    }

    if(accounts.isNotEmpty) {
      file = accounts[0]["file"] == null ? "platformId" : "file";
    }
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
            physics: const NeverScrollableScrollPhysics(),
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
                        "assets/images/icons/pink/${accounts[index][file]}Pink.png",
                        height: 30,
                      ),
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    Expanded(
                      child: Text(
                        accounts[index]["name"],
                        style: kBodyText1.apply(color: kEpic),
                      ),
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
                    const SizedBox(
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
                if (result != null) {
                  setState(() {
                    accounts.add(result);
                    if(result["steamId"] != null){
                      steamId = result["steamId"];
                    }
                    items.removeWhere((item) => item["platformId"] == result["platformId"]);
                  });
                }
              },
            ),
          const Expanded(
            child: Text(""),
          ),
          if (accounts.isNotEmpty)
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                final authKey = await secureStorage.read(key: "authKey");
                if (authKey == null) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/login");
                  return;
                }
                CallApi callApi = CallApi(authKey: authKey , context: context);
                print(accounts);
                var accountData = await callApi.post(
                    alreadyCreatedAccount?"/auth/editBrawlhallaAccounts":'/auth/createAccount',
                    jsonEncode(
                        {
                          "accounts": accounts
                        },
                    ),
                    showError:false
                );
                if(accountData["successful"] == false) {
                  setState(() {
                    _err = accountData["data"];
                  });
                  return;
                }
                try{
                  if (accountData["data"]["accountExists"] == true) {
                    setState(() {
                      _err =
                      "You have already created an account using this google/apple account, please contact support at contact@winhalla.app if it was not you";
                    });
                    return;
                  }
                } catch(e){}
                if (ModalRoute.of(context)?.settings.name == "/") {
                  Navigator.pop(context, "/");
                  Navigator.pushNamed(context, "/");
                } else {
                  Navigator.pushReplacementNamed(context, "/");
                }

              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    margin: EdgeInsets.only(bottom: _err == null ? 50:10),
                    decoration: BoxDecoration(
                        color: kBackgroundVariant,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    child: Padding(
                        padding: const EdgeInsets.fromLTRB(10,6,6,6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 1.0),
                              child: Text(
                                "Finish",
                                style: kBodyText2.apply(color: kGreen),
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 4.75),
                              child: Icon(
                                Icons.check,
                                color: kGreen,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ),
                ],
              ),
            ),
            if(_err != null) Container(
              margin: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(child: Text("Error: " + (_err as String), style: kBodyText4.apply(color: kRed),))
              ],),
            )
        ],
      ),
    );
  }
}

class GoogleAppleLogin extends StatefulWidget {
  const GoogleAppleLogin({Key? key}) : super(key: key);

  @override
  _GoogleAppleLoginState createState() => _GoogleAppleLoginState();
}

class _GoogleAppleLoginState extends State<GoogleAppleLogin> {
  String? _err;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(42.5, 120, 42.5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Welcome to",
            style: TextStyle(
              fontSize: 60,
              color: kText,
            ),
          ),
          Row(
            children: const [
              Text(
                "Winhalla",
                style: TextStyle(fontSize: 60, color: kPrimary, height: 1),
              ),
              Text(
                "!",
                style: TextStyle(fontSize: 60, color: kText, height: 1),
              ),
            ],
          ),
          const SizedBox(
            height: 25,
          ),
          Row(
            children: const [
              Text(
                "Play",
                style: TextStyle(fontSize: 30, color: kRed, fontFamily: "Roboto condensed"),
              ),
              SizedBox(
                width: 7,
              ),
              Text(
                "Brawlhalla,",
                style: TextStyle(fontSize: 30, color: kText, fontFamily: "Roboto condensed"),
              ),
            ],
          ),
          Row(
            children: const [
              Text(
                "Earn",
                style: TextStyle(fontSize: 30, color: kRed, fontFamily: "Roboto condensed"),
              ),
              SizedBox(
                width: 7,
              ),
              Text(
                "Rewards",
                style: TextStyle(fontSize: 30, color: kText, fontFamily: "Roboto condensed"),
              ),
            ],
          ),
          const SizedBox(
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
                if(idToken.statusCode < 200 || idToken.statusCode > 299){
                  setState((){
                    _err = idToken.body;
                  });
                  return;
                }
                idToken = jsonDecode(idToken.body)["_id"];
              } catch (e) {
                setState(() {
                  _err = e.toString();
                });
              }
              await secureStorage.write(key: "authKey", value: idToken);
              try{
                var accountData = jsonDecode((await http.get(getUri("/account"), headers: {"authorization": idToken})).body)["user"];
                if (accountData != null) {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, "/");
                  return;
                }
              } catch(e){}
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
                  const SizedBox(
                    width: 18,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 1.5),
                    child: Text(
                      "Sign in with Google",
                      style: kBodyText2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
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
                  const SizedBox(
                    width: 18,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 1.5),
                    child: Text(
                      "Sign in with Apple",
                      style: kBodyText2,
                    ),
                  )
                ],
              ),
            ),
          ),
          if(_err != null) Padding(
            padding: const EdgeInsets.only(left:15.0,top:10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: Text("Error: " + (_err as String), style: kBodyText4.apply(color: kRed),))
              ],),
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
            const Text(
              "Winhalla Presentation here",
              style: kHeadline1,
            ),
            TextButton(
                onPressed: () => context.read<LoginPageManager>().next(),
                child: Text(
                  "Go to next page",
                  style: kBodyText2.apply(
                    fontFamily: "Bebas neue",
                    color: kPrimary,
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

  LoginPageManager(this.page);
}
