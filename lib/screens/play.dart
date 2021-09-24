import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class Play extends StatelessWidget {
  const Play({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        child: Text(
          'PLAY',
          style: kHeadline1,
        ),
        onTap: (){
          Navigator.pushNamed(context, "/soloMatch");
          
        },
      )
    );
  }
}