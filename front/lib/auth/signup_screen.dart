import 'package:flutter/material.dart';
import '../home_screen.dart'; // Assurez-vous que ce fichier existe et contient le widget HomePage pour la navigation après l'inscription

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  void _signUp() {
    if (_formKey.currentState?.validate() == true) {
      // Intégrer votre logique d'inscription ici

      // Naviguez vers la HomePage avec l'indicateur pour montrer la pop-up
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage(showVerificationDialog: true)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView( // Utilisez SingleChildScrollView pour éviter les problèmes de débordement
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'Nom d\'utilisateur'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un nom d\'utilisateur';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Veuillez saisir un email valide';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Le mot de passe doit contenir au moins 6 caractères';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(labelText: 'Confirmer le mot de passe'),
                  obscureText: true,
                  validator: (value) {
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _signUp,
                  child: Text('S\'inscrire'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
