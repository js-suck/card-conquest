import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:front/routes/routes.dart';
import 'package:front/theme/dark_theme.dart';
import 'package:front/theme/theme.dart';
import 'package:provider/provider.dart';

void main() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
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
            initialRoute: '/main',
            routes: routes,
            theme: notifier.getTheme(),
          );
        }));
  }
}
