import 'package:flutter/material.dart';

const Color kBackground = Color(0xFF0F0F12);
const Color kBackgroundVariant = Color(0xFF1A1A28);

const Color kPrimary = Color(0xFF7172e3);
const Color kGreen = Color(0xFF3DE488);
const Color kEpic = Color(0xFFDE54EB);
const Color kOrange = Color(0xFFFFA946);

const Color kText = Color(0xFFFDFDFD);

const Color kText95 = Color(0xFFFCFCFC); // 95% opacity
const Color kText90 = Color(0xFFFBFBFB); // 90% opacity
const Color kText80 = Color(0xFFF8F8F8); // 80% opacity

class AppTheme {
  AppTheme._();

  static const textTheme = TextTheme(
      headline1: TextStyle(color: kText, fontSize: 40),
      bodyText1: TextStyle(color: kText95, fontSize: 30));
}
