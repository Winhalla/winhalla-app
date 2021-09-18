import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';
class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {
  @override
  int selectedItem = 0;
  String indexToName(index){
    switch (index){
      case 1: return "/quests";
      case 0: return "/";
      default: return "/";
    }
  }
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        backgroundColor: AppColors.background,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        iconSize: 30,
        currentIndex: selectedItem,
        unselectedItemColor: AppColors.text95,
        selectedItemColor: AppColors.primary,
        onTap:(index){
          setState((){
              selectedItem = index;
              Navigator.pop(context);
              Navigator.pushNamed(context, indexToName(index));
          });
        },
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
