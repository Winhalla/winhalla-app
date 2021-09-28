import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import 'package:steam_login/steam_login.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:winhalla_app/utils/getUri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: kBackground,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(32, 26, 32, 0),
          child: Column(
            children: [
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.fromLTRB(19, 9, 19, 6),
                  child: Text(
                    'Click to Login With google',
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
                  var idToken = await http.post(getUri("/auth/createToken"), body: {
                    "token": temp?["auth"].accessToken,
                    "name": temp?['account'].displayName,
                    if(temp?['account'].photoUrl != null) "picture": temp?['account'].photoUrl
                  });
                  secureStorage.write(key: "authKey", value: jsonDecode(idToken.body)["_id"]);
                  setState(() {
                    gAccount = temp;
                  });
                  Navigator.pushReplacementNamed(context, "/");

                },
              ),
              Text('Google email: ${gAccount?["account"]?.email}', style: kBodyText2.apply(color: kGreen)),
              Text('Google token: ${gAccount?["auth"]?.accessToken}', style: kBodyText4.apply(fontFamily: "Roboto Condensed")),
              GestureDetector(
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
                onTap: (){
                  GoogleSignInApi.logout();
                },
              )
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
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
