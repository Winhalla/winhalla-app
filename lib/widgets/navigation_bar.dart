import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class NavigationBar extends StatelessWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.background,

      showSelectedLabels: false,
      showUnselectedLabels: false,

      iconSize: 30,

      unselectedItemColor: AppColors.text95,
      selectedItemColor: AppColors.primary,

      items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Play'

      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.check_box_outlined),
        label: 'Play'

      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.play_circle_outline_outlined),
        label: 'Play'
      ),
    ],);
  }
}
