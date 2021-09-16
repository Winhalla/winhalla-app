import 'package:flutter/material.dart';


class AppColors {

  static const Color background = Color(0xFF0F0F12);
  static const Color backgroundVariant = Color(0xFF1A1A28);

  static const Color primary = Color(0xFF7172e3);
  static const Color green = Color(0xFF3DE488);
  static const Color epic = Color(0xFFDE54EB);
  static const Color orange = Color(0xFFFFA946);


  static const Color text = Color(0xFFFDFDFD);

  static const Color text95 = Color(0xFFFCFCFC);  // 95% opacity
  static const Color text90 = Color(0xFFFBFBFB);  // 90% opacity
  static const Color text80 = Color(0xFFF8F8F8);  // 80% opacity

  const AppColors();
}

class AppTheme {

  static const colors = AppColors();

  AppTheme._();

  static const textTheme = TextTheme(
      headline1: TextStyle(color: AppColors.text, fontSize: 40)
  );
}