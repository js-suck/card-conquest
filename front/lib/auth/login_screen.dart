import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../generated/chat.pb.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/feature_flag_provider.dart';

import '../generated/chat.pb.dart';

Future<void> login(
    BuildContext context, String username, String password) async {
  const storage = FlutterSecureStorage();
  String? fcmToken = await storage.read(key: 'fcm_token');
  final response = await http.post(
    Uri.parse('${dotenv.env['API_URL']}login'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'username': username,
      'password': password,
      'fcm_token': fcmToken ?? '',
    }),
  );
  String userRole = '';

  if (response.statusCode == 200) {
    var responseData = jsonDecode(response.body);
    String token = responseData['token'];
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    if (kIsWeb) {
      print(decodedToken['role']);
      if (decodedToken['role'] != 'admin') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vous n\'êtes pas autorisé à accéder à cette page'),
            duration: Duration(seconds: 1),
          ),
        );
        return;
      }
      // Store the token in secure storage
      await storage.write(key: 'jwt_token', value: token);
      Navigator.pushReplacementNamed(context, '/admin');
      return;
    }
    // Store the token in secure storage

    await storage.write(key: 'jwt_token', value: token);

    var tokenData = jsonDecode(
        ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))));
    int userId = tokenData['user_id'];

    await storage.delete(key: 'jwt_token');

    await storage.write(key: 'user_id', value: userId.toString());

    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userRole = decodedToken['role'];
    }
    if (userRole == 'organizer') {
      Navigator.pushReplacementNamed(context, '/orga/home');
    } else {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  } else {
    final t = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.loginError),
        duration: Duration(seconds: 1),
      ),
    );
    throw Exception('Failed to log in');
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  late bool isGoogleSignInEnabled = false;

  @override
  void initState() {
    super.initState();

    final featureNotifier = Provider.of<FeatureNotifier>(context, listen: false);
    isGoogleSignInEnabled = featureNotifier.isFeatureEnabled('googleSignIn');
  }



  void _login() {
    if (_formKey.currentState?.validate() == true) {
      try {
        login(context, _usernameController.text, _passwordController.text);
      } catch (e) {
        if (kDebugMode) {
          print('Erreur de connexion: $e');
        }
      }
    }
  }

  Future<void> sendUserDataToServer(auth.User user) async {
    print('Sending user data to server...');
    const storage = FlutterSecureStorage();
    String? fcmToken = await storage.read(key: 'fcm_token');
    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}auth/google'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'uid': user.uid,
        'email': user.email!,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'fcm_token': fcmToken ?? '',
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      var responseData = jsonDecode(response.body);

      String token = responseData['token'];
      await storage.write(key: 'jwt_token', value: token);

      try {
        String normalizedToken = base64.normalize(token.split(".")[1]);
        var tokenData =
            jsonDecode(utf8.decode(base64Url.decode(normalizedToken)));
        print('Token data: $tokenData');

        int userId = tokenData['user_id'];

        await storage.write(key: 'user_id', value: userId.toString());
      } catch (e) {
        print('Error during token decoding: $e');
      }
    } else {
      throw Exception('Failed to add/update user ${response.reasonPhrase}');
    }
  }

  Future<void> _googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      auth.User? user =
          (await auth.FirebaseAuth.instance.signInWithCredential(credential))
              .user;

      if (user != null) {
        await sendUserDataToServer(user);
        Navigator.of(context).pushReplacementNamed('/main');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Welcome, ${user.displayName}')),
        );
      }
    } catch (e) {
      final t = AppLocalizations.of(context)!;
      print('Error during Google sign in: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.loginErrorGoogle)),
      );
      return;
    }
    Navigator.of(context).pushReplacementNamed('/main');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const Text('Username',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'username',
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
                            return 'Veuillez entrer un username valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Mot de passe',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.black),
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
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _login,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Connexion',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (!kIsWeb)
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                'ou connectez-vous avec',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 10),
                      if (!kIsWeb && isGoogleSignInEnabled)
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
                              Image.asset('assets/images/google.png',
                                  width: 30),
                              const SizedBox(width: 10),
                            ],
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (!kIsWeb)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Flexible(
                              child: Text(
                                'Vous n\'avez pas de compte ?',
                                style: TextStyle(fontSize: 14),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushNamed(context, '/signup');
                              },
                              child: const Text(
                                'Inscrivez-vous',
                                style: TextStyle(
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
