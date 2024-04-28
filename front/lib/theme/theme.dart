// theme.dart
import 'package:flutter/material.dart';

const Color fontColor = Color(0xfff5f4f6);
const Color backgroundColor = Colors.white;
const Color accentBackgroundColor = Color(0xff1a4ccb);
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
);
