import 'dart:convert';
import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:winhalla_app/utils/custom_http.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
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

  void login(String loginMethod) async {
    bool isGoogleLogin = loginMethod == "google";
    dynamic credential;
    if(isGoogleLogin){
      credential = await GoogleSignInApi.login();
    } else {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        webAuthenticationOptions: WebAuthenticationOptions(
          // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
          clientId:'com.winhalla.app.serviceid',
          redirectUri:Uri.parse('https://api.winhalla.app/auth/redirect/apple'),
          // For web your redirect URI needs to be the host of the "current page",
          // while for Android you will be using the API server that redirects back into your app via a deep link
        ),
      );
      await http.post(getUri("/auth/createToken"), body: {
        "token": credential.authorizationCode,
        "name": credential.familyName != null && credential.givenName != null
            ? (credential.givenName as String) + (credential.familyName as String)
            : "",
        "mode": "apple",
        'useBundleId':Platform.isIOS ? "true"
            : "false",
      });
    }

    if (isGoogleLogin ? credential["auth"].accessToken == null : credential.authorizationCode == null) return;

    dynamic idToken;
    try {
      idToken = await http.post(getUri("/auth/createToken"), body: {
        "token": isGoogleLogin ? credential["auth"].accessToken : credential.authorizationCode,
        "name": isGoogleLogin
            ? credential['account'].displayName
            : credential.familyName != null && credential.givenName != null
              ? (credential.givenName as String) + (credential.familyName as String)
              : "",
        if (isGoogleLogin) if (credential['account'].photoUrl != null) "picture": credential['account'].photoUrl,
        "mode": loginMethod,
        'useBundleId':Platform.isIOS ? "true"
            : "false",
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
      var accountData = jsonDecode((await http.get(getUri("/account"), headers: {"authorization": idToken})).body);
      print(accountData);
      FirebaseCrashlytics.instance.setUserIdentifier(accountData["steam"]["id"]);
      FirebaseAnalytics.instance.setUserId(
          id: accountData["steam"]["id"]
      );
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
    FirebaseAnalytics.instance.logEvent(
        name: "SignIn",
        parameters: {
          "method":loginMethod
        }
    );

  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
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
              SizedBox(height: 5.h,),
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
                onTap: () => login("google"),
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
                onTap: () async {
                  login('apple');
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