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

  void changePage(number) {
    page = number;
    notifyListeners();
  }

  void next() {
    if(page >= 2){
      page = 2;
      notifyListeners();
      return;
    }
    page++;
    notifyListeners();
  }

  LoginPageManager(this.page);
}