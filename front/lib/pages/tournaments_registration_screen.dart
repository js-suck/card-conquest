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
import 'package:intl/intl.dart';

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
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    _checkUserRegistration();
  }

  Future<void> _checkUserRegistration() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      final decodedToken = _decodeToken(token);
      final userId = decodedToken['user_id'];
      final registered = await tournamentService.isUserRegistered(widget.tournamentId, userId);
      setState(() {
        isRegistered = registered;
      });
    }
  }

  Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw Exception('Invalid token');
    }
    final payload = base64Url.normalize(parts[1]);
    final payloadString = utf8.decode(base64Url.decode(payload));
    final payloadMap = json.decode(payloadString) as Map<String, dynamic>;
    return payloadMap;
  }

  Future<void> _registerForTournament() async {
    var t = AppLocalizations.of(context)!;
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      final decodedToken = _decodeToken(token);
      final role = decodedToken['role'];

      if (role == 'invite') {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      String? userId = decodedToken['user_id'].toString();

      final response = await http.post(
        Uri.parse(
            '${dotenv.env['API_URL']}tournaments/${widget.tournamentId}/register/$userId'),
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.tournamentRegistrationRegistered)),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.tournamentRegistrationFailed)),
        );
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(dateTime);
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
                                _formatDateTime(tournament.startDate),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
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
                    runSpacing: 4,
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
                  isRegistered
                      ? Center(
                    child: Text(
                      t.tournamentAlreadyRegistered,
                      style: const TextStyle(
                          color: Colors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                      : Center(
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
