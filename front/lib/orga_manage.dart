import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/widget/app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class OrganizerManagePage extends StatefulWidget {
  final int tournamentId;

  OrganizerManagePage({required this.tournamentId});

  @override
  _OrganizerManagePageState createState() => _OrganizerManagePageState();
}

class _OrganizerManagePageState extends State<OrganizerManagePage>
    with SingleTickerProviderStateMixin {
  late Future<Tournament> futureTournament;
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _maxPlayersController;

  @override
  void initState() {
    super.initState();
    futureTournament = fetchTournament(widget.tournamentId);
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<Tournament> fetchTournament(int id) async {
    final response = await http.get(
      Uri.parse('http://192.168.252.44:8080/api/v1/tournaments/$id'),
      headers: {
        'Authorization':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTk1OTI5MDgsIm5hbWUiOiJ1c2VyIiwicm9sZSI6ImFkbWluIiwidXNlcl9pZCI6MX0.QFT78-oBjAgr8brfBBQUhTJQ-FM4C1FU3looiY32mx4',
      },
    );

    if (response.statusCode == 200) {
      return Tournament.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tournament');
    }
  }

  Future<void> updateTournament(Tournament tournament) async {
    print(_nameController.text);
    print(_descriptionController.text);
    print(_locationController.text);
    print(_startDateController.text);
    print(_endDateController.text);

    final response = await http.put(
      Uri.parse(
          'http://192.168.252.44:8080/api/v1/tournaments/${tournament.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization':
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTk1OTI5MDgsIm5hbWUiOiJ1c2VyIiwicm9sZSI6ImFkbWluIiwidXNlcl9pZCI6MX0.QFT78-oBjAgr8brfBBQUhTJQ-FM4C1FU3looiY32mx4',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
        'max_players': '5',
        // Ajoutez d'autres attributs selon vos besoins
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tournament updated successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to update tournament: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeNotifier>(context).isDarkMode;
    const colorBGInput = Color(0xfafafafa);
    final fontColor =
        isDarkMode ? const Color(0xff000000) : const Color(0xff1a4ccb);

    return Scaffold(
      appBar: const TopAppBar(
        title: 'Gestion',
        roundedCorners: false,
      ),
      body: FutureBuilder<Tournament>(
        future: futureTournament,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            Tournament tournament = snapshot.data!;

            // Initialisation des contrôleurs de texte avec les valeurs actuelles du tournoi
            _nameController = TextEditingController(text: tournament.name);
            _descriptionController =
                TextEditingController(text: tournament.description);
            _locationController =
                TextEditingController(text: tournament.location);
            _startDateController =
                TextEditingController(text: tournament.startDate);
            _endDateController =
                TextEditingController(text: tournament.endDate);
            _maxPlayersController =
                TextEditingController(text: tournament.maxPlayers.toString());

            return Column(
              children: [
                Container(
                  color: fontColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).tabBarTheme.labelColor,
                    unselectedLabelColor:
                        Theme.of(context).tabBarTheme.unselectedLabelColor,
                    indicatorColor:
                        Theme.of(context).tabBarTheme.indicatorColor,
                    tabs: const [
                      Tab(icon: Icon(Icons.account_tree)),
                      Tab(icon: Icon(Icons.edit)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      const Center(
                          child: Text('Arbre du tournoi (vue de test)')),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: colorBGInput,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText: 'Nom du tournoi',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorBGInput,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _descriptionController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText: 'Description',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorBGInput,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _locationController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText: 'Lieu',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorBGInput,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _startDateController,
                                  keyboardType: TextInputType.datetime,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText: 'Date de début',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorBGInput,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _endDateController,
                                  keyboardType: TextInputType.datetime,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText: 'Date de fin',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Container(
                                decoration: BoxDecoration(
                                  color: colorBGInput,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _maxPlayersController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText: 'Nombre max de joueurs',
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    updateTournament(tournament);
                                  }
                                },
                                child: const Text('Sauvegarder'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('Aucun tournoi trouvé'));
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }
}

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
