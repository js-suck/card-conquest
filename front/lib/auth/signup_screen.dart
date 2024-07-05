import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;

import '../home_screen.dart';

Future<void> signUp(BuildContext context, String username, String email,
    String password) async {
  final t = AppLocalizations.of(context)!;
  final response = await http.post(
    Uri.parse('${dotenv.env['API_URL']}register'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 201) {
    // Handle successful registration
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => HomePage(showVerificationDialog: true)),
    );
  } else {
    // Handle error in registration
    throw Exception(t.signupError);
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _acceptTermsAndConditions = false;

  void _googleSignIn() {
    // Intégrer la logique de connexion avec Google ici
    // Après la connexion, naviguez vers HomePage
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _signUp() {
    final t = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() == true &&
        _acceptTermsAndConditions == true) {
      signUp(context, _usernameController.text, _emailController.text,
              _passwordController.text)
          .then((_) {
        // Optionally handle success in the UI
      }).catchError((error) {
        // Optionally handle error in the UI
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(t.error),
              content: Text(t.signupError),
              actions: [
                TextButton(
                  child: Text(t.modalClose),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    } else {
      // Show a message if terms and conditions are not accepted
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(t.signupTermsTitle),
            content: Text(t.signupTermsMessage),
            actions: [
              TextButton(
                child: Text(t.modalClose),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.end, // Alignement pour répartir l'espace
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Image.asset('assets/images/logo.png',
                  width: 30), // Logo à droite dans l'AppBar
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: <Widget>[
              Form(
                key: _formKey,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.signupTitle,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      Text(t.username,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: t.username.toLowerCase(),
                          hintStyle: TextStyle(
                              color: const Color(0xFF888888).withOpacity(0.5)),
                          fillColor: Colors.grey[100],
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return t.noUsername;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(t.email,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: t.emailHint,
                          hintStyle: TextStyle(
                              color: const Color(0xFF888888).withOpacity(0.5)),
                          fillColor: Colors.grey[100],
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return t.invalidEmail;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(t.password,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: '*******',
                          hintStyle: TextStyle(
                              color: const Color(0xFF888888).withOpacity(0.5)),
                          fillColor: Colors.grey[100],
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 6) {
                            return t.invalidPassword;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Text(t.passwordConfirmation,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _confirmPasswordController,
                        decoration: InputDecoration(
                          hintText: '*******',
                          hintStyle: TextStyle(
                              color: const Color(0xFF888888).withOpacity(0.5)),
                          fillColor: Colors.grey[100],
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return t.passwordMismatch;
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // add button for validate the terms and conditions
                      Row(
                        children: <Widget>[
                          Checkbox(
                            value: _acceptTermsAndConditions,
                            onChanged: (bool? value) {
                              setState(() {
                                _acceptTermsAndConditions = value!;
                              });
                            },
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: () {
                                // Ouvrir la page des terms & policy
                                Navigator.pushNamed(context, '/terms');
                              },
                              child: Text(
                                t.signupTermsAccept,
                                style: const TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.underline),
                              ),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _signUp,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          t.signupSignup,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            // Rend le texte flexible pour éviter le débordement
                            child: Text(
                              t.signupAlternative,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _googleSignIn,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFF5F4F6),
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Image.asset('assets/images/google.png', width: 30),
                            const SizedBox(width: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Flexible(
                            // Rend le texte flexible pour éviter le débordement
                            child: Text(
                              t.signupHaveAccount,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow
                                  .ellipsis, // Ajoute des points de suspension si le texte est trop long
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              t.signupLogin,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFFF933D),
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
