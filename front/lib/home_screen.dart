import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class HomePage extends StatelessWidget {
  final bool showVerificationDialog;

  const HomePage({Key? key, this.showVerificationDialog = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (showVerificationDialog) {
      Future.microtask(() => _showVerificationDialog(context));
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png', width: 200),
            const SizedBox(height: 10),
            Text(t.welcome),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        SignUpPage()), // Naviguer vers la page d'inscription
              ),
              child: Text(t.signup),
            ),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LoginPage()), // Naviguer vers la page de connexion
              ),
              child: Text(t.login),
            ),
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page principale
                Navigator.pushNamed(context, '/main');
              },
              child: Text(t.guest),
            ),
          ],
        ),
      ),
    );
  }

  void _showVerificationDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.verifyEmail),
          content: Text(t.verifyEmailMessage),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
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
