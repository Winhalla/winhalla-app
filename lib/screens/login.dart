import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:winhalla_app/utils/get_uri.dart';
import 'package:winhalla_app/utils/services/secure_storage_service.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/widgets/login/account_creation.dart';
import 'dart:convert';

import 'package:winhalla_app/widgets/login/enter_link.dart';
import 'package:winhalla_app/widgets/login/google_apple_login.dart';


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

  LoginPageManager(this.page);
}