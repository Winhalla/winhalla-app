import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/login/account_creation.dart';
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
      const GoogleAppleLogin(),
      const EnterLink(),
      AccountCreation(accounts: accounts),
    ];

    try{
      if(userData?["data"]?["steam"] != null) step = 1;
    } catch(e) {}
    if(accounts != null) step = 2;

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

  void next() {
    FirebaseAnalytics.instance.logScreenView(screenClass: "Login",screenName: indexToScreenName(page));
    FirebaseAnalytics.instance.setCurrentScreen(screenName: indexToScreenName(page));
    page++;
    notifyListeners();
  }

  LoginPageManager(this.page){
    FirebaseAnalytics.instance.logScreenView(screenClass: "Login",screenName: indexToScreenName(page));
    FirebaseAnalytics.instance.setCurrentScreen(screenName: indexToScreenName(page));
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