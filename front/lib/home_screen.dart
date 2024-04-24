import 'package:flutter/material.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class HomePage extends StatelessWidget {
  final bool showVerificationDialog;

  const HomePage({super.key, this.showVerificationDialog = false});

  @override
  Widget build(BuildContext context) {
    if (showVerificationDialog) {
      Future.microtask(() => _showVerificationDialog(context));
    }
    return Scaffold(
      appBar: AppBar(
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png', width: 200),
            SizedBox(height: 10),
            Text('Bienvenue sur notre application'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              ),
              child: Text('Inscription'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ),
              child: Text('Connexion'),
            ),
            ElevatedButton(
              onPressed: () {
                // Logique pour continuer en tant qu'invité
                Navigator.pushReplacementNamed(context, '/user');
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
