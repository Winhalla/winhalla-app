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
    SteamLogin(),
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

  final bidTextController = TextEditingController();

  final linkTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getNonNullSSData("tempSteamId"),
      builder: (context,AsyncSnapshot<String> key) {
        if(!key.hasData) return Container();
        bidTextController.text = key.data == null?"":key.data as String;
        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(width: 1, color: kText, style: BorderStyle.solid),
                  color: kText),
              child: TextField(
                controller: bidTextController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Brawlhalla ID',
                  contentPadding: EdgeInsets.all(15),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border:
                      Border.all(width: 1, color: kText, style: BorderStyle.solid),
                  color: kText),
              child: TextField(
                controller: linkTextController,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Link id',
                  contentPadding: EdgeInsets.all(15),
                  border: InputBorder.none,
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.fromLTRB(19, 9, 19, 6),
                child: Text(
                  'Create winhalla account',
                  style: kHeadline1.apply(color: kRed),
                ),
                decoration: BoxDecoration(
                  color: kBackgroundVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onTap: () async {
                final String? secureStorageKey =
                    await secureStorage.read(key: "authKey");
                if (secureStorageKey == null) return;
                print(secureStorageKey);
                var linkId = await http.post(
                  getUri(
                      "/auth/createAccount?linkId=${linkTextController.text}&BID=${bidTextController.text}"),
                  headers: {"authorization": secureStorageKey},
                );
                print(linkId.body);
              },
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        );
      }
    );
  }
}

class GoogleAppleLogin extends StatelessWidget {
  const GoogleAppleLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30,50,30,0),
        child: Column(
          children: [
            SizedBox(
              width: 300,
              child: Consumer<LoginPageManager>(
                builder: (context, page,_) {
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
                      secureStorage.write(
                          key: "authKey", value: jsonDecode(idToken.body)["_id"]);
                      page.next();
                    },
                  );
                }
              ),
            ),
            SizedBox(height: 20,),
            SizedBox(
              width: 300,
              child: Container(
                child: GestureDetector(child:Container(
                  padding: EdgeInsets.fromLTRB(19, 9, 19, 6),
                  child: Text(
                    'Login With Apple',
                    style: kHeadline1.apply(color: kRed),
                  ),
                  decoration: BoxDecoration(
                    color: kBackgroundVariant,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),),
              ),
            )
            /*GestureDetector(
              child: Container(
                padding: EdgeInsets.fromLTRB(19, 9, 19, 6),
                child: Text(
                  'Logout',
                  style: kHeadline1.apply(color: kRed),
                ),
                decoration: BoxDecoration(
                  color: kBackgroundVariant,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onTap: () {
                GoogleSignInApi.logout();
              },
            ),*/
          ],
        ),
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
        padding: const EdgeInsets.fromLTRB(30,50,30,0),
        child: Column(
          children: [
            Text(
              "Winhalla Presentation here",
              style: kHeadline1,
            ),
            Consumer<LoginPageManager>(
              builder: (context, page, _) => TextButton(
                onPressed: () => page.next(),
                child: Text("Go to next page",style: kBodyText2.apply(fontFamily: "Bebas neue",color: kPrimary,),),
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