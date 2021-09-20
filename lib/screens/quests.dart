import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/widgets/navigation_bar.dart';
import 'package:winhalla_app/screens/quests.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class Quests extends StatelessWidget {
  const Quests({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
        backgroundColor: AppColors.background,
        body: FutureBuilder(
          future: http.get(Uri.parse('https://jsonplaceholder.typicode.com/albums/1')),
          builder: (dynamic context, dynamic res) {
            return Center(
                child: Text(
                  'QUESTS',
                  style: AppTheme.textTheme.headline1,
                ));
          },
        ));
  }
}
