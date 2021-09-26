import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:steam_login/steam_login.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class LoginWithSteam extends StatefulWidget {
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
        GestureDetector(
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
            final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => SteamLogin()));
            setState(() {
              steamId = result;
            });
          },
        ),
        Text('Steamid: $steamId', style: kBodyText2.apply(color: kGreen)),
      ],
    );
  }
}
class SteamLogin extends StatelessWidget {
  final _webView = FlutterWebviewPlugin();

  @override
  Widget build(BuildContext context) {
    // Listen to the onUrlChanged events, and when we are ready to validate do so.
    _webView.onUrlChanged.listen((String url) async {
      var openId = OpenId.fromUri(Uri.parse(url));
      if (openId.mode == 'id_res') {
        await _webView.close();
        Navigator.of(context).pop(openId.validate());
      }
    });

    var openId = OpenId.raw('https://winhalla.app', 'https://winhalla.app/', {"name": "Winhalla"});
    return WebviewScaffold(
        url: openId.authUrl().toString(),
        appBar: AppBar(
          title: Text('Steam Login'),
        ));
  }
}

