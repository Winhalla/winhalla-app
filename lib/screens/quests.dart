import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:winhalla_app/config/themes/dark_theme.dart';
import 'package:winhalla_app/utils/userClass.dart';

class Quests extends StatelessWidget {
  const Quests({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      'QUESTS',
      style: kHeadline1,
    ));
  }
}
