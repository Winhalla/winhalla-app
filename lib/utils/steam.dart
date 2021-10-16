import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:provider/provider.dart';
import 'package:steam_login/steam_login.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/screens/login.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;

import 'getUri.dart';

/*class LoginWithSteam extends StatefulWidget {
  const LoginWithSteam({Key? key}) : super(key: key);

  @override
  _LoginWithSteamState createState() => _LoginWithSteamState();
}

class _LoginWithSteamState extends State<LoginWithSteam> {
  String? steamId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Consumer<LoginPageManager>(builder: (context, page, _) {
          return GestureDetector(
            child: Container(
              padding: EdgeInsets.fromLTRB(19, 9, 19, 6),
              child: Text(
                'Click to Login',
                style: kHeadline1.apply(color: kPrimary),
              ),
              decoration: BoxDecoration(
                color: kBackgroundVariant,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onTap: () async {
              // Navigate to the login page.
              final result = await Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SteamLogin()));
              await secureStorage.write(key: "tempSteamId", value: result);
              print(await secureStorage.read(key: "tempSteamId"));
              page.next();
            },
          );
        }),
        Text('Steamid: $steamId', style: kBodyText2.apply(color: kGreen)),
      ],
    );
  }
}*/

class SteamLogin extends StatefulWidget {
  const SteamLogin({Key? key}) : super(key: key);

  @override
  _SteamLoginState createState() => _SteamLoginState();
}

class _SteamLoginState extends State<SteamLogin> {
  bool isSteamLoginInProgress = false;

  @override
  Widget build(BuildContext context) {
    if(isSteamLoginInProgress ) return Consumer<LoginPageManager>(
      builder:(context,page,_)=>SteamLoginWebView()
    );
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(19, 9, 19, 9),
        child: Consumer<LoginPageManager>(
            builder: (context, page, _) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSteamLoginInProgress = true;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.fromLTRB(19, 9, 19, 9),
                      child: Text(
                        "Use steam for faster login",
                        style: kHeadline1,
                      ),
                      decoration: BoxDecoration(color: kBackgroundVariant),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    "OR",
                    style: kBodyText2,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () => page.next(),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(19, 9, 19, 9),
                      child: Text(
                        "Enter BID manually",
                        style: kHeadline1,
                      ),
                      decoration: BoxDecoration(color: kBackgroundVariant),
                    ),
                  ),
                ],
              );
            }
        ),
      ),
    );
  }
}

class SteamLoginWebView extends StatelessWidget {

  final _webView = FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
    // Listen to the onUrlChanged events, and when we are ready to validate do so.
    _webView.onUrlChanged.listen((String url) async {
      var openId = OpenId.fromUri(Uri.parse(url));
      if (openId.mode == 'id_res') {
        await _webView.close();
        var result = await openId.validate();
        var accountData = jsonDecode((await http.get(getUri("/auth/getBIDFromSteamId/${result}"))).body);
        Navigator.pop(context, {"bid":accountData["brawlhalla_id"],"name":accountData["name"],"file":"steam"});
      }
    });

    var openId = OpenId.raw(
        'https://winhalla.app', 'https://winhalla.app/', {"name": "Winhalla"});
    return WebviewScaffold(
      url: openId.authUrl().toString(),
    );
  }
}
