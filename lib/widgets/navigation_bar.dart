import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class NavigationBar extends StatelessWidget {
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
    return Container(
        color: AppColors.background,
        padding: const EdgeInsets.fromLTRB(0, 12, 0, 14),
    child: BottomNavigationBar(
    elevation: 0,
      backgroundColor: AppColors.background,

      showSelectedLabels: false,
      showUnselectedLabels: false,
      onTap:(index){
        setState((){
          selectedItem = index;
          Navigator.pop(context);
          Navigator.pushNamed(context, indexToName(index));
        });
      },

      currentIndex: selectedItem,

      iconSize: 35,

      unselectedItemColor: AppColors.text95,
      selectedItemColor: AppColors.primary,

      items: const <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.home),
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
    ],);
  }
}
