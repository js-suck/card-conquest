import 'package:flutter/material.dart';
import 'login_screen.dart'; // Assurez-vous que ce fichier existe et contient le widget LoginPage
import 'signup_screen.dart'; // Créez ce fichier pour votre page d'inscription

class HomePage extends StatelessWidget {
  final bool showVerificationDialog;

  const HomePage({Key? key, this.showVerificationDialog = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showVerificationDialog) {
      Future.microtask(() => _showVerificationDialog(context));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenue'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()), // Naviguer vers la page d'inscription
              ),
              child: Text('Inscription'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()), // Naviguer vers la page de connexion
              ),
              child: Text('Connexion'),
            ),
            ElevatedButton(
              onPressed: () {
                // Ajoutez ici votre logique pour continuer en tant qu'invité
                // Par exemple, naviguer vers une page principale de l'application pour les invités
                print('Continuer en tant qu\'invité');
              },
              child: Text('Continuer en tant qu\'Invité'),
            ),
          ],
        ),
      ),
    );
  }
  void _showVerificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Vérifiez votre email'),
          content: Text('Un email de vérification a été envoyé. Veuillez vérifier votre email pour compléter l\'inscription.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la pop-up
              },
            ),
          ],
        );
      },
    );
  }
}
