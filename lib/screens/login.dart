import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/widgets/login/account_creation.dart';
import 'package:winhalla_app/widgets/login/enter_link.dart';
import 'package:winhalla_app/widgets/login/google_apple_login.dart';

class LoginPage extends StatelessWidget {
  final userData;
  final accounts;
  final int? stepOverride;
  final Uri? steamLoginUri;
  LoginPage({Key? key, this.userData, this.accounts, this.stepOverride, this.steamLoginUri}) : super(key: key);

  int step = 0;
  @override
  Widget build(BuildContext context) {
    bool stepOverriden = false;
    if(stepOverride == null){
      try{
        if(userData?["data"]?["steam"] != null) {
          step = 1;
          stepOverriden = false;
        }
      } catch(e) {}
      if(accounts != null) {
        step = 2;
        stepOverriden = false;
      }
    } else {
      step = stepOverride!;
      stepOverriden = true;
    }

    List<Widget> screenList = [
      const GoogleAppleLogin(),
      const EnterLink(),
      AccountCreation(accounts: accounts, stepOverriden: stepOverriden, steamLoginUri:steamLoginUri ),
    ];


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
    if(page >= 2){
      page = 2;
      notifyListeners();
      FirebaseAnalytics.instance.setCurrentScreen(screenName: indexToScreenName(page), screenClassOverride: "MainActivity");
      return;
    }
    page++;
    FirebaseAnalytics.instance.setCurrentScreen(screenName: indexToScreenName(page), screenClassOverride: "MainActivity");
    notifyListeners();
  }

  LoginPageManager(this.page){
    FirebaseAnalytics.instance.setCurrentScreen(screenName: indexToScreenName(page), screenClassOverride: "MainActivity");
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