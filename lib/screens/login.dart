import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:winhalla_app/widgets/popup.dart';
import 'package:winhalla_app/widgets/popup_link.dart';


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
      const EnterLink(),
      AccountCreation(accounts: accounts),
    ];
    try{
      if(userData?["data"]?["steam"] != null) step = 1;
    } catch(e) {}
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
  final GlobalKey<AnimatedListState> listKey = GlobalKey<AnimatedListState>();
  List<Map<String, String>> items = [
    {'name': "Steam (PC)", "platformId": "steam"},
    {'name': "PS3/4/5", "platformId": "ps"},
    {'name': "Xbox One/Series", "platformId": "xbox"},
    {'name': "Nintendo Switch", "platformId": "switch"},
    {"name": "Mobile", "platformId": 'phone'},
  ];
  String? _err;
  String fileToName(String file){
    switch (file){
      case "steam": return "Steam (PC)";
      case "ps": return "PS3/4/5";
      case "xbox": return "Xbox One/Series";
      case "switch": return "Nintendo Switch";
      case "phone": return "Mobile";
      default: return "Steam (PC)";
    }
  }
  @override
  Widget build(BuildContext context) {
    if(widget.accounts != null && alreadyCreatedAccount == false) {
      accounts = widget.accounts;
      for (int i = 0; i < accounts.length; i++) {
        for (int ii = 0; ii < items.length; ii++) {
          var element = items[ii];

          if(element["platformId"] == accounts[i]["platformId"]){
            items.removeAt(ii);
          }
        }
      }
      alreadyCreatedAccount = true;
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
          AnimatedList(
            key: listKey,
            initialItemCount: accounts.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (BuildContext context, int index, Animation<double> animation) {
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
                        "assets/images/icons/pink/${accounts[index]["platformId"]}Pink.png",
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
                    ),
                    GestureDetector(
                        child: const Icon(Icons.clear_outlined, size: 40, color: kEpic,),
                        onTap:(){
                          var name = accounts[index]["name"];
                          var fileName = accounts[index]["platformId"];
                          setState(() {
                            listKey.currentState?.removeItem(
                                index, (_, animation) => animatedFakeContainer(
                                context,
                                index,
                                animation,
                                name,
                                fileName
                              ),
                                duration: const Duration(milliseconds: 150));
                            items.add({"platformId":accounts[index]["platformId"], "name":fileToName(accounts[index]["platformId"])});
                            accounts.removeAt(index);
                          });
                        }
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
                    listKey.currentState?.insertItem(
                        accounts.length,
                    );
                    accounts.add(result);
                    if(result["steamId"] != null){
                      steamId = result["steamId"];
                    }
                    print(result["platformId"]);
                    print(items);
                    items.removeWhere((item) => item["platformId"] == result["platformId"]);
                  });
                }
              },
            ),
          const Expanded(
            child: Text(""),
          ),
            Row(
              mainAxisAlignment: alreadyCreatedAccount && accounts.isNotEmpty
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.end,
              children: [
                if(alreadyCreatedAccount) GestureDetector(
                  onTap: (){
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    margin: EdgeInsets.only(bottom: _err == null ? 50:10),
                    decoration: BoxDecoration(
                      color: kBackgroundVariant,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10,8,6,8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0),
                            child: Text(
                              "Cancel",
                              style: kBodyText2.apply(color: kRed),
                            ),
                          ),
                          const SizedBox(
                            width: 6,
                          ),
                          const Icon(
                            Icons.clear_outlined,
                            color: kRed,
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (accounts.isNotEmpty) GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () async {
                    final authKey = await secureStorage.read(key: "authKey");
                    if (authKey == null) {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, "/login");
                      return;
                    }
                    var link = await getNonNullSSData("link");
                    CallApi callApi = CallApi(authKey: authKey , context: context);
                    var accountData = await callApi.post(
                        alreadyCreatedAccount?"/auth/editBrawlhallaAccounts" : '/auth/createAccount'+ (link == "no data" ? "" : '?linkId=$link'),
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

                    await secureStorage.write(key:'link',value: null);
                    if (ModalRoute.of(context)?.settings.name == "/") {
                      Navigator.pop(context, "/");
                      Navigator.pushNamed(context, "/");
                    } else {
                      Navigator.pushReplacementNamed(context, "/");
                    }
                    try{
                      print(accountData["data"]["isLinkDetected"] == true);
                      if(accountData["data"]["isLinkDetected"] == true){
                        showDialog(context: context, builder:(_)=>LinkActivatedWidget());
                      }
                    } catch(e){}
                  },
                  child: Container(
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
                                alreadyCreatedAccount ? "Save" : "Finish",
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
                ),
              ],
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
Widget animatedFakeContainer(item, int index, Animation<double> animation, String name, String file) =>
    FadeTransition(
      opacity: Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: SizeTransition(
        sizeFactor: Tween(
          begin: 0.0,
          end: 1.0,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut),
        ),
        child: Container(
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
                      "assets/images/icons/pink/${file}Pink.png",
                      height: 30,
                    ),
                  ),
                  const SizedBox(
                    width: 18,
                  ),
                  Expanded(
                    child: Text(
                      name,
                      style: kBodyText1.apply(color: kEpic),
                    ),
                  ),
                  const Icon(Icons.clear_outlined, size: 40, color: kEpic,),
                ],
              ),
            ),
      ),
    );

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
      padding: const EdgeInsets.fromLTRB(42.5, 120, 42.5, 125),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 20),
          const Expanded(child:Text("")),
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
              var skipReferralLink = await http.get(getUri("/auth/checkDetectedLink"));
              if(skipReferralLink.body == "true") {
                context.read<LoginPageManager>().next();
              }
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
          ),
        ],
      ),
    );
  }
}

/*class WinhallaPresentation extends StatelessWidget {
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
}*/

class EnterLink extends StatefulWidget {
  const EnterLink({Key? key}) : super(key: key);

  @override
  _EnterLinkState createState() => _EnterLinkState();
}

class _EnterLinkState extends State<EnterLink> {
  TextEditingController link = TextEditingController();
  Timer t = Timer(const Duration(milliseconds: 400), () {});
  bool? linkValid;
  bool loading = false;
  bool isMounted = false;
  @override
  void dispose() {
    link.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(42.5, 60, 42.5, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Referral link",
            style: TextStyle(
            fontSize: 60,
            color: kText,
          ),),
          const SizedBox(height: 20,),
          Text(
            "If a friend shared the app with you, enter his link here. \nIf not, skip this step.",
            style: kBodyText2.apply(color:kText80),
          ),
          const SizedBox(height: 50,),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: kBackgroundVariant),
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 10),
            child: TextField(
              controller: link,
              onChanged: (String text){
                if(text.isNotEmpty){
                  setState(() {
                    loading = true;
                  });
                  t.cancel();
                  t = Timer(const Duration(milliseconds: 500), () async {
                    String linkId = "";
                    try{
                      linkId = Uri.parse(text).pathSegments[1];
                    } catch(e){
                      setState(() {
                        linkValid = false;
                        loading = false;
                      });
                      return;
                    }
                    var isLinkValid = await http.get(getUri("/auth/checkLink/$linkId"));
                    setState(() {
                      linkValid = isLinkValid.body == "true";
                      loading = false;
                    });
                  });
                } else {
                  t.cancel();
                  setState(() {
                    loading = false;
                    linkValid = null;
                  });
                }
              },
              style: const TextStyle(fontSize: 18, color:kText,fontFamily: "Roboto condensed"),
              decoration: InputDecoration(
                  suffixIconConstraints: const BoxConstraints(maxHeight: 37, maxWidth: 35),
                  suffixIcon: loading == true
                          ? const Padding(
                            padding: EdgeInsets.fromLTRB(10, 6, 0, 6),
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                            ),
                          )
                          : linkValid == false
                          ? const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.clear_outlined,
                                color: kRed,
                                size: 34,
                              ),
                            )
                          : linkValid == true
                          ?const Padding(
                              padding: EdgeInsets.only(left: 4.0),
                              child: Icon(
                                Icons.check,
                                color: kGreen,
                                size: 34,
                              ),
                            ):null,
                  border: InputBorder.none,
                  hintText: 'Paste your referral link here',
                  hintStyle: const TextStyle(fontSize: 18, color: kText80, fontFamily: "Roboto Condensed")),
              ),
          ),

          if(linkValid == false) const Padding(
            padding: EdgeInsets.only(left: 8.0, top:8),
            child: Text("This link doesn't exist", style: TextStyle(color: kRed, fontSize: 17, fontFamily: "Roboto condensed"),),
          )
          else if(linkValid == true) const Padding(
            padding: EdgeInsets.only(left: 8.0, top:8),
            child: Text("Link valid and boost applied!", style: TextStyle(color: kGreen, fontSize: 17, fontFamily: "Roboto condensed"),),
          ),

          const Expanded(child:Text("")),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () async {
                if(linkValid != true){
                  context.read<LoginPageManager>().next();
                  return;
                }
                try{
                  var linkId = Uri.parse(link.text).pathSegments[1];
                  await secureStorage.write(key: "link", value: linkId);
                  context.read<LoginPageManager>().next();
                } catch(e){
                  context.read<LoginPageManager>().next();
                  return;
                }

              },
              child: Container(
                decoration: BoxDecoration(
                  color:kBackgroundVariant,
                  borderRadius: BorderRadius.circular(14),
                ),
                padding:const EdgeInsets.fromLTRB(25, 15, 25, 15),
                child:Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(linkValid == true ? "Next" : "Skip", style: kBodyText2.apply(color:kPrimary),),
                    const SizedBox(width: 7,),
                    const Icon(Icons.arrow_forward, color:kPrimary)
                  ],
                )
              ),
            )
          ),
          const SizedBox(height: 40,)
      ],),
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

  static Future logout() => _googleSignIn.signOut();
}

class LoginPageManager extends ChangeNotifier {
  int page = 0;

  void next() {
    FirebaseAnalytics.instance.logScreenView(screenClass: "Login",screenName: indexToScreenName(page));
    page++;
    notifyListeners();
  }

  LoginPageManager(this.page){
    FirebaseAnalytics.instance.logScreenView(screenClass: "Login",screenName: indexToScreenName(page));
  }
}

String indexToScreenName(int index){
  switch (index) {
    case 0:
      return "Google/Apple login";
    case 1:
      return "Enter Link";
    case 2:
      return "Create account";
    default:
      return "Unknown page";
  }
}