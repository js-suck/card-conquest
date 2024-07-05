import 'dart:convert';
import 'package:front/main.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:provider/src/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/notifier/theme_notifier.dart';

class Tournament {
  final int id;
  final String name;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final String imageFilename;
  final int maxPlayers;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageFilename,
    required this.maxPlayers,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      imageFilename: json['media']['file_name'],
      maxPlayers: json['max_players'],
    );
  }
}

//Image.network(
//           'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif');

class OrganizerHomePage extends StatefulWidget {
  @override
  _OrganizerHomePageState createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  final storage = const FlutterSecureStorage();
  late Future<List<Tournament>> futureTournaments;

  @override
  void initState() {
    super.initState();
    futureTournaments = fetchTournaments();
  }

  Future<List<Tournament>> fetchTournaments() async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments'),
      headers: {
        'Authorization': '$token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((tournament) => Tournament.fromJson(tournament))
          .toList();
    } else {
      throw Exception('Failed to load tournaments');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    final fontColor = isDarkMode ? Colors.red : Colors.blue;

    return Scaffold(
      appBar: const TopAppBar(title: 'Accueil'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/orga/add/tournament');
                },
                child: Center(
                  // Utilisation de Center
                  child: Text(
                    'Créer un nouveau tournoi +',
                    style: TextStyle(
                      color: fontColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Vos tournois en cours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Tournament>>(
                future: futureTournaments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucun tournoi en cours'));
                  } else {
                    var ongoingTournaments = snapshot.data!
                        .where((t) => DateTime.parse(t.endDate)
                            .toUtc()
                            .isAfter(DateTime.now().toUtc()))
                        .toList();
                    return SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: ongoingTournaments.length,
                        itemBuilder: (context, index) {
                          var tournament = ongoingTournaments[index];
                          DateTime startDate =
                              DateTime.parse(tournament.startDate);
                          String formattedDate =
                              DateFormat('dd.MM.yyyy').format(startDate);
                          String formattedTime =
                              DateFormat('HH:mm').format(startDate);

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/orga/manage/tournament',
                                arguments: tournament.id,
                              );
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.8,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  image: NetworkImage(
                                      '${dotenv.env['MEDIA_URL']}${tournament.imageFilename}'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(
                                      8.0), // Ajout de padding pour éviter que le texte ne touche les bords
                                  child: Column(
                                    mainAxisSize: MainAxisSize
                                        .min, // Pour que la colonne ne prenne pas plus de place que nécessaire
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tournament.name,
                                        style: const TextStyle(
                                          fontSize: 20.0,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize
                                            .min, // Pour que la rangée ne prenne que la place nécessaire
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  8.0), // Espacement entre la date et le point
                                          const Icon(
                                            Icons.circle,
                                            size: 6.0,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(
                                              width:
                                                  8.0), // Espacement entre le point et l'heure
                                          Text(
                                            formattedTime,
                                            style: const TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Tous vos tournois',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              FutureBuilder<List<Tournament>>(
                future: futureTournaments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Aucun tournois'));
                  } else {
                    var draftTournaments = snapshot.data!.toList();
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: draftTournaments.length,
                      itemBuilder: (context, index) {
                        var tournament = draftTournaments[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/orga/manage/tournament',
                              arguments: tournament.id,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: NetworkImage(
                                    'http://192.168.252.44:8080/api/v1/images/${tournament.imageFilename}'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  color: Colors.black54,
                                  child: ListTile(
                                    title: Text(
                                      tournament.name,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    subtitle: Text(
                                      '${tournament.startDate.substring(0, 10)} ${tournament.startDate.substring(11, 16)}', // Date et heure formatées
                                      style: const TextStyle(
                                          color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
