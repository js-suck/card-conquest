// theme.dart
import 'package:flutter/material.dart';

const Color fontColor = Color(0xfff5f4f6);
const Color white = Colors.white;
const Color backgroundColor = Color(0xff1E1E36);
const Color invertedBackgroundColor = Colors.white;
const Color accentBackgroundColor = Color(0xff000000);
const Color secondaryAccentBackgroundColor = Color(0xff000000);
const Color accentColor = Color(0xffFF5500);

// Définissez votre thème dans un fichier séparé
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Lexend',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
  ),
  brightness: Brightness.dark,
  primaryColor: accentBackgroundColor,
  scaffoldBackgroundColor: backgroundColor,
  primarySwatch: Colors.blue,
  appBarTheme: const AppBarTheme(
    backgroundColor: accentBackgroundColor,
    foregroundColor: fontColor,
  ),
  tabBarTheme: const TabBarTheme(
    labelColor: accentColor,
    unselectedLabelColor: fontColor,
    indicatorColor: accentColor,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: accentColor,
    textTheme: ButtonTextTheme.primary,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: accentBackgroundColor,
    selectedItemColor: accentColor,
    unselectedItemColor: white,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(accentColor),
      foregroundColor: MaterialStateProperty.all<Color>(fontColor),
    ),
  ),
  badgeTheme: const BadgeThemeData(
    textColor: fontColor,
    backgroundColor: accentColor,
  ),
);
