import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class Play extends StatelessWidget {
  const Play({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'PLAY',
        style: kHeadline1,
      )
    );
  }
}
