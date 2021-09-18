import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class NavigationBar extends StatelessWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
        child: BottomNavigationBar(
          elevation: 0,
          showSelectedLabels: false,
          showUnselectedLabels: false,

          iconSize: 35,

          unselectedItemColor: AppColors.text95,
          selectedItemColor: AppColors.primary,

          backgroundColor: AppColors.background,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                label: 'Home'

            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.check_box_outlined),
                label: 'Quests'

            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.play_circle_outline_outlined),
                label: 'Play'

            ),
          ],
        )
    );

  }
}
