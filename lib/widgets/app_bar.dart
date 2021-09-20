import 'package:flutter/material.dart';
import 'package:winhalla_app/config/themes/dark_theme.dart';

class MyAppBar extends StatelessWidget {
  const MyAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(28, 32, 38, 19),
        color: AppColors.background,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.search),

                color: AppColors.text95,
                iconSize: 34,

                onPressed: (){},
              ),
              Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.notifications_none_outlined),

                      color: AppColors.text95,
                      iconSize: 35,

                      onPressed: (){},
                    ),
                    const Padding(padding: EdgeInsets.only(right: 8)),
                    Container(
                      width: 55,
                      height: 55,
                      decoration: const BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.all(Radius.circular(10))
                      ),
                    )
                  ]
              )
            ]
        ),
      );
  }
}
