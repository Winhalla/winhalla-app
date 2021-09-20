import 'package:flutter/material.dart';
import 'package:winhalla_app/widgets/app_bar.dart';
import 'package:winhalla_app/widgets/navigation_bar.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PreferredSize(
          preferredSize: Size.fromHeight(134),
          child: MyAppBar()
        ),
        body: Center(

          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Daily challenge:',
                style: AppTheme.textTheme.headline1,
              ),
              const Text(
                'test mmmh',
                style: TextStyle(fontFamily: "Roboto Condensed", color: AppColors.primary),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const NavigationBar(),
      ),
    );
  }
}