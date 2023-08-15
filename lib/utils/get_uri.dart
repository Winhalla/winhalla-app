import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/info_dropdown.dart';
import 'package:winhalla_app/widgets/inherited_text_style.dart';

import 'custom_http.dart';
const String apiUrl = "https://api.winhalla.app";

Uri getUri(
  String path,
) {
  return Uri.parse(apiUrl + path); // 192.168.1.33:4000
}

class CallApi {
  String authKey;
  BuildContext context;
  CallApi({required this.authKey, required this.context});

  Future get(String path, {bool showError = true}) async {
    late Response result;
    try {
      result = await http
          .get(Uri.parse(apiUrl + path), headers: {"authorization": authKey});
    } catch (e) {
      print(e);
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
                ?.merge(InheritedTextStyle.of(context).kBodyText4),
          ),
          fontSize: 25,
          column: true,
          isError: true,
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
                ?.merge(InheritedTextStyle.of(context).kBodyText4),
          ),
          fontSize: 25,
          column: true,
          isError: true,
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

  Future post(String path, body, {bool showError = true}) async {
    late Response result;
    try {
      result = await http.post(Uri.parse(apiUrl + path),
          headers: {
            "authorization": authKey,
            "Content-Type": "application/json"
          },
          body: body);
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
                ?.merge(InheritedTextStyle.of(context).kBodyText4),
          ),
          fontSize: 25,
          column: true,
          isError: true,
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
                ?.merge(InheritedTextStyle.of(context).kBodyText4),
          ),
          fontSize: 25,
          column: true,
          isError: true,
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
}
