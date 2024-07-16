import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';


class HomePage extends StatelessWidget {
  final bool showVerificationDialog;
  final storage = const FlutterSecureStorage();

  const HomePage({Key? key, this.showVerificationDialog = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (showVerificationDialog) {
      Future.microtask(() => _showVerificationDialog(context));
    }

    final ButtonStyle buttonStyle = ElevatedButton.styleFrom(
      foregroundColor: context.themeColors.secondaryBackgroundAccentColor,
      backgroundColor: context.themeColors.accentColor,
      minimumSize: const Size(230, 50),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.themeColors.secondaryBackgroundAccentActiveColor.withOpacity(0.8),
              context.themeColors.accentColor.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/logo.png', width: 200),
              const SizedBox(height: 20),
              Text(
                t.welcome,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SignUpPage()), // Navigate to SignUpPage
                ),
                child: Text(t.signup),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginPage()), // Navigate to LoginPage
                ),
                child: Text(t.login),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () {
                  //add jwt token
                  const storage = FlutterSecureStorage();
                  const token = "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiaW52aXRlIiwibmFtZSI6Ikludml0w6kifQ.1TMIPCEDolEVv1TMX77Y7-RA6AW4zCG2JrcjFT4hM90";
                  storage.write(key: 'jwt_token', value: token);

                  // Navigate to the main page
                  Navigator.pushNamed(context, '/main');
                },
                child: Text(t.guest),
              ),
            ],
          ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/images/logo.png', width: 200),
            const SizedBox(height: 10),
            const Text('Bienvenue sur notre application'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignUpPage()),
              ),
              child: const Text('Inscription'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              ),
              child: const Text('Connexion'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/main');
              },
              child: const Text('Continuer en tant qu\'Invité'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _loginAsAdmin(context);
              },
              child: const Text('Continuer en tant qu\'Admin'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginAsAdmin(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/v1/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': 'user',
          'password': 'password',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        await storage.write(key: 'jwt_token', value: data['token']);
        Navigator.pushNamed(context, '/admin');
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to login as admin.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error: $e');
      print('StackTrace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while trying to login as admin.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showVerificationDialog(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(t.verifyEmail),
          content: const Text(t.verifyEmailMessage),
          actions: <Widget>[
            TextButton(
              child:  const Text(t.ok),
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
