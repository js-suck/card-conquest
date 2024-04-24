import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'user/home_screen.dart';

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
  }
}
