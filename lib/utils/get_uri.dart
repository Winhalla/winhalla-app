import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/infoDropdown.dart';
const String url = "https://api.winhalla.app";

Uri getUri (String path,){
  return Uri.parse(url+path); // 192.168.1.33:4000
}
class CallApi {
  String authKey;
  BuildContext context;
  CallApi({required this.authKey, required this.context});

  Future get(String path,{bool showError = true}) async {
    late http.Response result;
    try {
      result = await http
          .get(Uri.parse(url + path), headers: {"authorization": authKey});
    } catch (e) {
      if (showError) {
        showInfoDropdown(
          context,
          kRed,
          "Error:",
          body: Text(
            "Winhalla's servers are unreachable, please check your internet connection or try again later",
            style: Theme.of(context)
                .textTheme
                .bodyText2
                ?.merge(const TextStyle(color: kText, fontSize: 20)),
          ),
          fontSize: 25,
          column: true,
        );
      }
      return {
        "data":
            "Winhalla's servers are unreachable, please check your internet connection or try again later",
        "successful": false,
        "addText": false
      };
    }

    if (result.statusCode < 200 || result.statusCode > 299) {
      if (showError) {
        showInfoDropdown(
          context,
          kRed,
          "Error:",
          body: Text(
            result.body.toString(),
            style: Theme.of(context)
                .textTheme
                .bodyText2
                ?.merge(const TextStyle(color: kText, fontSize: 20)),
          ),
          fontSize: 25,
          column: true,
        );
      }
      return {
        "data": result.body,
        "successful": false,
        "statusCode": result.statusCode
      };
    }

    try {
      return {"data": jsonDecode(result.body), "successful": true};
    } on FormatException {
      return {"data": result.body, "successful": true};
    }
  }

  Future post(String path, body, {bool showErrors = true}) async {
    var result = await http.post(
        Uri.parse(url+path),
        headers: {"authorization":authKey,"Content-Type": "application/json"},
        body: body
    );

    if (result.statusCode < 200 || result.statusCode > 299){
      if (showErrors) {
        showInfoDropdown(
        context,
        kRed,
        "Error:",
        column: true,
        body: Text(
          result.toString(),
          style: Theme.of(context)
              .textTheme
              .bodyText2
              ?.merge(const TextStyle(color: kText, fontSize: 20)),
        ),
        fontSize:25,
      );
      }
      return {"data":result.body,"successful":false};
    }

    try {
      return {"data":jsonDecode(result.body),"successful":true};
    } on FormatException {
      return {"data":result.body,"successful":true};
    }
  }
}