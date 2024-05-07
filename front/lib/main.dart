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
<<<<<<< HEAD
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => SignUpPage(),
        '/user': (context) => const UserHomePage(),
        // Ajoutez d'autres routes selon vos besoins
      },
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
=======
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
>>>>>>> f2d7ee0a43c190b9b70c1da33ef7f73c885adb6e
  }
}
