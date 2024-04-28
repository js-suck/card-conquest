import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'package:front/profile_screen.dart';
import 'package:front/settings_screen.dart';
import 'package:front/theme/dark_theme.dart';
import 'package:front/theme/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _lightTheme = theme;
  ThemeData _darkTheme = darkTheme;
  bool _isDarkMode;

  ThemeNotifier(this._isDarkMode) {
    _lightTheme = theme;
    _darkTheme = darkTheme;
  }

  ThemeData getTheme() => _isDarkMode ? _darkTheme : _lightTheme;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) =>
            ThemeNotifier(false), // Définit le thème initial sur clair
        child: Consumer(builder: (context, ThemeNotifier notifier, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            routes: {
              '/': (context) => HomePage(),
              '/login': (context) => LoginPage(),
              '/signup': (context) => SignUpPage(),
              '/profile': (context) => const ProfilePage(),
              '/settings': (context) => const SettingsPage(),
            },
            theme: notifier.getTheme(),
          );
        }));
  }
}
