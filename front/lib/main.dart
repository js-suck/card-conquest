import 'package:flutter/material.dart';
import 'package:front/routes/routes.dart';
import 'package:front/theme/dark_theme.dart' as dark_theme;
import 'package:front/theme/theme.dart' as theme;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front/services/user_service.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      Provider(create: (_) => UserService('http://10.0.2.2:8080/api/v1')),
    ],
    child: const MyApp(),
    ),
  );
}

class ThemeColors {
  final Color backgroundColor;
  final Color backgroundAccentColor;
  final Color invertedBackgroundColor;
  final Color secondaryBackgroundAccentColor;
  final Color accentColor;
  final Color fontColor;

  ThemeColors({
    required this.backgroundColor,
    required this.backgroundAccentColor,
    required this.invertedBackgroundColor,
    required this.secondaryBackgroundAccentColor,
    required this.accentColor,
    required this.fontColor,
  });
}

class ThemeNotifier with ChangeNotifier {
  ThemeData _lightTheme = theme.theme;
  ThemeData _darkTheme = dark_theme.darkTheme;
  bool _isDarkMode;

  ThemeNotifier(this._isDarkMode) {
    _lightTheme = theme.theme;
    _darkTheme = dark_theme.darkTheme;
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  ThemeData getTheme() => _isDarkMode ? _darkTheme : _lightTheme;

  ThemeColors get themeColors {
    return ThemeColors(
        backgroundColor:
            _isDarkMode ? dark_theme.backgroundColor : theme.backgroundColor,
        backgroundAccentColor: _isDarkMode
            ? dark_theme.accentBackgroundColor
            : theme.accentBackgroundColor,
        invertedBackgroundColor: _isDarkMode
            ? dark_theme.invertedBackgroundColor
            : theme.invertedBackgroundColor,
        secondaryBackgroundAccentColor: _isDarkMode
            ? dark_theme.secondaryAccentBackgroundColor
            : theme.secondaryAccentBackgroundColor,
        accentColor: _isDarkMode ? dark_theme.accentColor : theme.accentColor,
        fontColor: _isDarkMode ? dark_theme.fontColor : theme.fontColor);
  }

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    await _saveTheme(_isDarkMode);
  }

  Future<void> _saveTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
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
            routes: routes,
            theme: notifier.getTheme(),
          );
        }));
  }
}
