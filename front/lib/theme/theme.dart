// theme.dart
import 'package:flutter/material.dart';

const Color fontColor = Colors.black;
const Color backgroundColor = Colors.white;
const Color invertedBackgroundColor = Color(0xff1a1a1a);
const Color accentBackgroundColor = Color(0xff1a4ccb);
const Color secondaryAccentBackgroundColor = Color(0xFFf1f1f1);
const Color secondaryBackgroundAccentActiveColor = Color(0xFFE2DFE0);
const Color accentColor = Color(0xffff933d);

// Définissez votre thème dans un fichier séparé
final ThemeData theme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Lexend',
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(fontSize: 16),
  ),
  brightness: Brightness.light,
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
    unselectedItemColor: backgroundColor,
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
