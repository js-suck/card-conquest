import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => LoginPage(),
        '/signup': (context) => SignUpPage(),
        // Ajoutez d'autres routes selon vos besoins
      },
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
