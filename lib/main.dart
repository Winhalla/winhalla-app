import 'package:flutter/material.dart';
import 'package:winhalla_app/screens/home.dart';
import 'package:winhalla_app/screens/play.dart';
import 'package:winhalla_app/screens/quests.dart';
import 'package:winhalla_app/widgets/app_bar.dart';
import 'package:provider/provider.dart';
import 'config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/userClass.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static const List<Widget> screenList = [ MyHomePage(), Quests(), Play()];

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int _selectedIndex = 0;

  switchPage(index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Winhalla',

      theme: ThemeData(
        fontFamily: "Bebas Neue"
      ),

      home: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: const PreferredSize(
              preferredSize: Size.fromHeight(134),
              child: MyAppBar()
          ),
          body: FutureBuilder(future:http.get(Uri.parse('http://192.168.1.33/sampleData')),
          builder:(context,snapshot){
            if(!snapshot.hasData) return Center(child:Text("Loading"));
            return ChangeNotifierProvider(
            create: (_) => new User(snapshot.data),
            child:MyApp.screenList[_selectedIndex]
            );}),
          bottomNavigationBar: Container(

              padding: const EdgeInsets.fromLTRB(32, 19, 32, 28),
              decoration: const BoxDecoration(
                color: AppColors.background,
                /*boxShadow: [
            BoxShadow(
              offset: Offset(0, -8),
              blurRadius: 8,
              color: Colors.black.withOpacity(0.20)
            )
          ]*/
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <IconButton>[
                  IconButton(
                    icon: const Icon(Icons.home_outlined),
                    color: AppColors.text95,
                    iconSize: 34,

                    onPressed: (){
                      switchPage(0);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.check_box_outlined),
                    color: AppColors.text95,
                    iconSize: 34,

                    onPressed: (){
                      switchPage(1);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.play_circle_outline_outlined),
                    color: AppColors.text95,
                    iconSize: 34,

                    onPressed: (){
                      switchPage(2);
                    },
                  ),
                ],
              )
          ),
        ),
      )

      /*
      // Start the app with the "/" named route. In this case, the app starts
      // on the FirstScreen widget.
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/': (context) => const MyHomePage(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/login': (context) => const Quests(),
      },*/
    );
  }
}


