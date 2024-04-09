import 'package:flutter/material.dart';
import 'home_screen.dart'; // Assurez-vous que ce fichier existe et contient votre widget HomePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(), // Définir HomePage comme écran d'accueil
      theme: ThemeData(
        useMaterial3: true,
      ),
    );
  }
}
