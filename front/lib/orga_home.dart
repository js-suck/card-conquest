import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:front/widget/app_bar.dart';

class Tournament {
  final int id;
  final String name;
  final String description;
  final String location;
  final String startDate;
  final String endDate;
  final String imageUrl;
  final int maxPlayers;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
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
      imageUrl:
          'http://192.168.1.36:8080/uploads/${json['media']['file_name']}',
      maxPlayers: json['max_players'],
    );
  }
}

Future<List<Tournament>> fetchTournaments() async {
  final response = await http.get(
    Uri.parse('http://192.168.1.36:8080/api/v1/tournaments'),
    headers: {
      'Authorization':
          'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTY4NzU3NjUsIm5hbWUiOiJ1c2VyIiwicm9sZSI6ImFkbWluIiwidXNlcl9pZCI6MX0.kpcwXFhLDiNSCXliRvjD85aJElCUBk2bq1jEFRbvsjM',
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

class OrganizerHomePage extends StatefulWidget {
  @override
  _OrganizerHomePageState createState() => _OrganizerHomePageState();
}

class _OrganizerHomePageState extends State<OrganizerHomePage> {
  late Future<List<Tournament>> futureTournaments;

  @override
  void initState() {
    super.initState();
    futureTournaments = fetchTournaments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TopAppBar(title: 'Accueil Organisateur'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lien pour créer un nouveau tournoi
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/orga/tournament');
                },
                child: const Text(
                  'Créer un nouveau tournoi +',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 18,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Label pour les tournois en cours
              const Text(
                'Vos tournois en cours',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Carrousel pour les tournois en cours
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
                        .where((t) =>
                            DateTime.parse(t.endDate).isAfter(DateTime.now()))
                        .toList();
                    return CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        autoPlay: true,
                        enlargeCenterPage: true,
                      ),
                      items: ongoingTournaments.map((tournament) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                image: DecorationImage(
                                  image: NetworkImage(tournament.imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Text(
                                tournament.name,
                                style: const TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),
              // Label pour les tournois en brouillons
              const Text(
                'Vos tournois en brouillons',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              // Grid pour les tournois en brouillons
              FutureBuilder<List<Tournament>>(
                future: futureTournaments,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('Aucun tournoi en brouillon'));
                  } else {
                    var draftTournaments = snapshot.data!
                        .where((t) =>
                            DateTime.parse(t.endDate).isBefore(DateTime.now()))
                        .toList();
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
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              image: NetworkImage(tournament.imageUrl),
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
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    '${tournament.startDate.substring(0, 10)} ${tournament.startDate.substring(11, 16)}', // Date et heure formatées
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              ),
                            ],
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
