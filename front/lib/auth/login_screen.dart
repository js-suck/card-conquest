import 'package:flutter/material.dart';
import '../home_screen.dart'; // Assurez-vous que ce fichier existe et contient le widget HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  void _login() {
    final isValid = _formKey.currentState?.validate();
    if (isValid != null && isValid) {
      // Après la validation, naviguez vers HomePage
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  void _googleSignIn() {
    // Intégrer la logique de connexion avec Google ici
    // Après la connexion, naviguez vers HomePage
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body:SingleChildScrollView(
       child: Center(
        child: Column(
          children: <Widget>[
            Image.asset('assets/images/logo.png', width: 150),
            const SizedBox(height: 30),
            Form(
              key: _formKey,
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Connectez-vous à votre compte',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text('Email',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'tcg@gmail.com',
                        hintStyle: TextStyle(color: Color(0xFF888888).withOpacity(0.5)),
                        fillColor: Colors.grey[100],
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),  // Réduit le padding interne
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty || !value.contains('@')) {
                          return 'Veuillez entrer un email valide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Text('Mot de passe',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    SizedBox(height: 10),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: '*******',
                        hintStyle: TextStyle(color: Color(0xFF888888).withOpacity(0.5)),
                        fillColor: Colors.grey[100],
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),  // Réduit le padding interne
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty || value.length < 6) {
                          return 'Le mot de passe doit contenir au moins 6 caractères';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _login,
                  child: Text(
                    'Connexion',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), // Texte en blanc
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFFFF933D), // Couleur du texte (utile pour les effets de pression)
                    minimumSize: Size(double.infinity, 45), // Prend toute la largeur disponible et hauteur de 50
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bords arrondis
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(  // Rend le texte flexible pour éviter le débordement
                      child: Text(
                        'ou connectez-vous avec',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _googleSignIn,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Color(0xFFF5F4F6), // Couleur du texte (utile pour les effets de pression)
                    minimumSize: Size(double.infinity, 45), // Prend toute la largeur disponible et hauteur de 50
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Bords arrondis
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Image.asset('assets/images/google.png', width: 30),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
                SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Flexible(  // Rend le texte flexible pour éviter le débordement
                      child: Text(
                        'Vous n\'avez pas de compte ?',
                        style: TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,  // Ajoute des points de suspension si le texte est trop long
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Inscrivez-vous',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFFFF933D),
                      ),
                    ),
                    ),
                  ],
                ),
                  ],
              ),
              ),
            ),
          ],
        ),
      ),
    ),
    );

  }
}
