import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class NavigationBar extends StatefulWidget {
  const NavigationBar({Key? key}) : super(key: key);

  @override
  _NavigationBarState createState() => _NavigationBarState();
}

class _NavigationBarState extends State<NavigationBar> {

  int selectedItem = 0;
  String indexToName(index){
    switch (index){
      case 1: return "/quests";
      case 0: return "/";
      default: return "/";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(

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

              onPressed: (){},
            ),
            IconButton(
              icon: const Icon(Icons.check_box_outlined),
              color: AppColors.text95,
              iconSize: 34,

              onPressed: (){},
            ),
            IconButton(
              icon: const Icon(Icons.play_circle_outline_outlined),
              color: AppColors.text95,
              iconSize: 34,

              onPressed: (){},
            ),
          ],
        )

      /*BottomNavigationBar(
          elevation: 0,
          backgroundColor: AppColors.background,

          showSelectedLabels: false,
          showUnselectedLabels: false,

          onTap: (index) {
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
      ],
    )*/
    );
  }
}
