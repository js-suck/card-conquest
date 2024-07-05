import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/widget/app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front/widget/expandable_fab.dart';

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
  final storage = const FlutterSecureStorage();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late TextEditingController _maxPlayersController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    futureTournament = fetchTournament(widget.tournamentId);
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    _locationController = TextEditingController();
    _maxPlayersController = TextEditingController();
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
  }

  Future<Tournament> fetchTournament(int id) async {
    String? token = await storage.read(key: 'jwt_token');

    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}tournaments/$id'),
      headers: {
        'Authorization': '$token',
      },
    );
    debugPrint(response.body);
    if (response.statusCode == 200) {
      return Tournament.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tournament');
    }
  }

  Future<void> updateTournament(Tournament tournament) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}tournaments/${tournament.id}'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'name': _nameController.text,
        'description': _descriptionController.text,
        'location': _locationController.text,
        'max_players': int.parse(_maxPlayersController.text),
        'start_date': _startDateController.text,
        'end_date': _endDateController.text,
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

  Future<void> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _startTournament() async {
    String? token = await storage.read(key: 'jwt_token');
    int tournamentId = widget.tournamentId;

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}tournaments/$tournamentId/start'),
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tournoi démarré avec succès')),
      );
      // Mettez à jour l'interface utilisateur ou effectuez d'autres actions nécessaires après le démarrage du tournoi
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Échec du démarrage du tournoi: ${response.body}')),
      );
    }
  }

  void _finishTournament() {
    // Logique pour terminer le tournoi
  }
  @override
  Widget build(BuildContext context) {
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
            _nameController.text = tournament.name;
            _descriptionController.text = tournament.description;
            _locationController.text = tournament.location;
            _maxPlayersController.text = tournament.maxPlayers.toString();
            _startDateController.text = tournament.startDate;
            _endDateController.text = tournament.endDate;

            return Column(
              children: [
                Container(
                  color: Theme.of(context).primaryColor,
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
                      tournament.players.isEmpty
                          ? const Center(
                              child: Text('Aucun utilisateur inscrit'))
                          : ListView.builder(
                              itemCount: tournament.players.length,
                              itemBuilder: (context, index) {
                                final player = tournament.players[index];
                                return ListTile(
                                  leading: CircleAvatar(
                                    child: Text(player['username'][0]),
                                  ),
                                  title: Text(player['username']),
                                  subtitle: Text(player['email']),
                                );
                              },
                            ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Form(
                          key: _formKey,
                          child: ListView(
                            children: [
                              const Text(
                                'Designation du tournoi:',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Description:',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _descriptionController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Lieu:',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _locationController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Nombre max de joueurs:',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _maxPlayersController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Date de début:',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _startDateController,
                                  keyboardType: TextInputType.datetime,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Date de fin:',
                                style: TextStyle(fontSize: 18.0),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _endDateController,
                                  keyboardType: TextInputType.datetime,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              GestureDetector(
                                onTap: _pickImageFromGallery,
                                child: DottedBorder(
                                  color: Colors.grey,
                                  strokeWidth: 1,
                                  dashPattern: const [5, 5],
                                  child: Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: Colors.white,
                                    child: _selectedImage != null
                                        ? Image.file(
                                            _selectedImage!,
                                            fit: BoxFit.cover,
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.image,
                                              size: 40,
                                              color: Colors.grey,
                                            ),
                                          ),
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
                                child: const Text('Modifier le tournoi'),
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
      floatingActionButton: ExpandableFab(
        distance: 112.0,
        children: [
          FloatingActionButton(
            heroTag: "startTournament${widget.tournamentId}",
            onPressed: _startTournament,
            tooltip: 'Démarrer le tournoi',
            child: const Icon(Icons.play_arrow),
          ),
          FloatingActionButton(
            heroTag: "finishTournament${widget.tournamentId}",
            onPressed: _finishTournament,
            tooltip: 'Terminer le tournoi',
            child: const Icon(Icons.stop),
          ),
          FloatingActionButton(
            heroTag: "bracket${widget.tournamentId}",
            onPressed: () {
              Navigator.pushNamed(context, '/bracket');
            },
            tooltip: 'Voir le bracket',
            child: const Icon(Icons.format_list_numbered),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxPlayersController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
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
  final List<dynamic> players; // Changed type to dynamic

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageFilename,
    required this.maxPlayers,
    required this.players,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    print(json);
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      imageFilename: json['media']['file_name'],
      maxPlayers: json['max_players'] ?? 0,
      players: json['players'],
    );
  }
}
