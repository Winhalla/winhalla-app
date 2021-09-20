import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class Quests extends StatelessWidget {

  const Quests({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Text(
          'QUESTS',
          style: AppTheme.textTheme.headline1,
        ));
  }
}
