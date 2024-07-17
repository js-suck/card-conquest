import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';

class HomePage extends StatelessWidget {
  final bool showVerificationDialog;
  final storage = const FlutterSecureStorage();

  const HomePage({Key? key, this.showVerificationDialog = false})
      : super(key: key);

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
      textStyle:
          const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              context.themeColors.secondaryBackgroundAccentActiveColor
                  .withOpacity(0.8),
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
              if (!kIsWeb)
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SignUpPage()), // Navigate to SignUpPage
                  ),
                  child: Text(t.signup),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: buttonStyle,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const LoginPage()), // Navigate to LoginPage
                ),
                child: Text(t.login),
              ),
              const SizedBox(height: 20),
              if (!kIsWeb)
                ElevatedButton(
                  style: buttonStyle,
                  onPressed: () {
                    //add jwt token
                    const storage = FlutterSecureStorage();
                    const token =
                        "eyJhbGciOiJIUzI1NiJ9.eyJyb2xlIjoiaW52aXRlIiwibmFtZSI6Ikludml0w6kifQ.1TMIPCEDolEVv1TMX77Y7-RA6AW4zCG2JrcjFT4hM90";
                    storage.write(key: 'jwt_token', value: token);

                    // Navigate to the main page
                    Navigator.pushNamed(context, '/main');
                  },
                  child: Text(t.guest),
                ),
              const SizedBox(height: 20),
              if (kIsWeb)
                ElevatedButton(
                  onPressed: () {
                    _loginAsAdmin(context);
                  },
                  child: const Text('Dashboard Admin'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loginAsAdmin(BuildContext context) async {
    // get token if exist
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      if (decodedToken['role'] == 'admin') {
        Navigator.pushNamed(context, '/admin');
      }
    } else {
      Navigator.pushNamed(context, '/login');
    }
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
              child: Text(t.ok),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
