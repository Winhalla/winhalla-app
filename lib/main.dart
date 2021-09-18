import 'package:flutter/material.dart';
import 'package:winhalla_app/widgets/navigation_bar.dart';

import 'config/themes/dark_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: "Bebas Neue"
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(

        title: Text(widget.title),
        backgroundColor: AppColors.background,
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
    );
  }
}
