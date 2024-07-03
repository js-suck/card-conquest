import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:http/http.dart' as http;

class RegistrationPage extends StatefulWidget {
  final int tournamentId;

  const RegistrationPage({Key? key, required this.tournamentId})
      : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final storage = const FlutterSecureStorage();
  late TournamentService tournamentService;

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    tournamentService.fetchTournament(widget.tournamentId);
  }

  Future<void> _registerForTournament() async {
    var t = AppLocalizations.of(context)!;
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      String? userId = jsonDecode(ascii.decode(
              base64.decode(base64.normalize(token.split(".")[1]))))['user_id']
          .toString();

      final response = await http.post(
        Uri.parse(
            '${dotenv.env['API_URL']}tournaments/${widget.tournamentId}/register/$userId'),
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        // Inscription réussie
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.tournamentRegistrationRegistered)),
        );
        // Rediriger vers la page principale
        Navigator.of(context).pop();
      } else {
        // Gérer les erreurs
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.tournamentRegistrationFailed)),
        );
      }
    } else {
      // Rediriger vers la page de connexion si l'utilisateur n'est pas connecté
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    var t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: TopAppBar(
          title: t.tournamentRegistrationTitle,
          isAvatar: false,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: CustomFutureBuilder(
            future: tournamentService.fetchTournament(widget.tournamentId),
            onLoaded: (tournament) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tournament.name,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(tournament.media?.fileName != null
                            ? '${dotenv.env['API_URL']}images/${tournament.media?.fileName}'
                            : '${dotenv.env['API_URL']}images/yugiho.webp'),
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
                                '${tournament.startDate.day.toString().padLeft(2, '0')}/${tournament.startDate.month.toString().padLeft(2, '0')}/${tournament.startDate.year}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${tournament.startDate.hour.toString().padLeft(2, '0')}:${tournament.startDate.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tournament.description ??
                        t.tournamentRegistrationDescription,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          color: context.themeColors.accentColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'J: ${tournament.playersRegistered}/${tournament.maxPlayers}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.teal[400],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${t.tournamentRegistrationGame}: ${tournament.game.name}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${t.tournamentRegistrationStatus}: ${tournament.status}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 15),
                      ),
                      child: Text(
                        t.tournamentRegistrationRegister,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
