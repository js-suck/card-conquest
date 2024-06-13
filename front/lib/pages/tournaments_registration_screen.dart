import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


class RegistrationPage extends StatefulWidget {
  final int tournamentId;

  const RegistrationPage({Key? key, required this.tournamentId}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final storage = const FlutterSecureStorage();
  Map<String, dynamic> tournamentData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTournamentData();
  }

  Future<void> _fetchTournamentData() async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8080/api/v1/tournaments/${widget.tournamentId}'),
      headers: {
        'Authorization': '$token',
      },
    );
    if (response.statusCode == 200) {
      setState(() {
        tournamentData = jsonDecode(response.body);
        _isLoading = false;
      });
    } else {
      // Gérer les erreurs
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec de la récupération des données du tournoi.')),
      );
    }
  }

  Future<void> _registerForTournament() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      String? userId = jsonDecode(
          ascii.decode(base64.decode(base64.normalize(token.split(".")[1])))
      )['user_id'].toString();

      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/v1/tournaments/${widget.tournamentId}/register/$userId'),
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        // Inscription réussie
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inscription réussie !')),
        );
        // Rediriger vers la page principale
        Navigator.of(context).pop();
      } else {
        // Gérer les erreurs
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'inscription. Veuillez réessayer.')),
        );
      }
    } else {
      // Rediriger vers la page de connexion si l'utilisateur n'est pas connecté
      Navigator.pushReplacementNamed(context, '/login');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          title: const Text('Inscription au tournoi'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tournamentData['name'] ?? 'Nom du tournoi',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage('http://10.0.2.2:8080/api/v1/images/${tournamentData['media']['file_name']}'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournamentData['start_date'].split('T')[0],
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          tournamentData['start_date'].split('T')[1].substring(0, 5),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Wrap(
                      spacing: 8,
                      children: tournamentData['tags'] != null
                          ? (tournamentData['tags'] as List<dynamic>).map((tag) => Chip(
                        label: Text(tag, style: const TextStyle(color: Colors.white)),
                        backgroundColor: Colors.orange,
                      )).toList()
                          : [],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              tournamentData['description'] ?? 'Description',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _registerForTournament,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF933D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: const Text(
                  'S\'inscrire',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
