import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:steam_login/steam_login.dart';
import 'package:http/http.dart' as http;
import 'get_uri.dart';

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
        Navigator.pop(context, {"BID":accountData["brawlhalla_id"].toString(),"name":accountData["name"],"platformId":"steam","steamId":result});
      }
    });

    var openId = OpenId.raw(
        'https://winhalla.app', 'https://winhalla.app/', {"name": "Winhalla"});
    return WebviewScaffold(
      url: openId.authUrl().toString(),
    );
  }
}
