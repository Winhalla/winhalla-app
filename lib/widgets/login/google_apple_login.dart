import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:winhalla_app/utils/custom_http.dart';
import 'package:winhalla_app/utils/get_uri.dart';
// import 'package:http/http.dart' as http;
import 'package:winhalla_app/utils/services/secure_storage_service.dart';

import '../inherited_text_style.dart';

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
      padding: const EdgeInsets.fromLTRB(42.5, 20, 42.5, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // mainAxisSize: MainAxisSize.max,
        children: [
          Column(
            children: [
              Text(
                "Welcome to",
                style: InheritedTextStyle.of(context).kHeadline0,
              ),
              Row(
                children: [
                  Text(
                    "Winhalla",
                    style: InheritedTextStyle.of(context).kHeadline0.apply(color: kPrimary),
                  ),
                  Text(
                    "!",
                    style: InheritedTextStyle.of(context).kHeadline0,
                  ),
                ],
              ),
            ],
          ),
          Column(
            children: [
              Row(
                children: [
                  Text(
                    "Play",
                    style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kRed),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    "Brawlhalla,",
                    style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kText),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    "Earn",
                    style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kRed),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Text(
                    "Rewards",
                    style: InheritedTextStyle.of(context).kBodyText1Roboto.apply(color: kText),
                  ),
                ],
              ),
            ],
          ),

          Column(
            children: [
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1.5),
                          child: Text(
                            "Sign in with Google",
                            style: InheritedTextStyle.of(context).kBodyText2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20,),
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
                    mainAxisSize: MainAxisSize.min,
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
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 1.5),
                          child: Text(
                            "Sign in with Apple",
                            style: InheritedTextStyle.of(context).kBodyText2,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          if(_err != null) Padding(
            padding: const EdgeInsets.only(left:15.0,top:10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(child: Text("Error: " + (_err as String), style: InheritedTextStyle.of(context).kBodyText4.apply(color: kRed),))
              ],),
          ),
        ],
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

  static Future logout() => _googleSignIn.signOut();
}