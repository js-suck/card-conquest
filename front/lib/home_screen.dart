import 'package:flutter/material.dart';
import 'login_screen.dart'; // Assurez-vous d'avoir ce fichier avec votre widget LoginPage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    // Ici, vous ajouterez votre logique pour vérifier si l'utilisateur est connecté
    // Pour cet exemple, nous allons simuler un utilisateur non connecté après un délai
    await Future.delayed(Duration(seconds: 2));

    // Simuler un utilisateur non connecté en naviguant vers la page de connexion
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Page d\'accueil'),
      ),
      body: Center(
        child: CircularProgressIndicator(), // Afficher un indicateur de chargement
      ),
    );
  }
}
