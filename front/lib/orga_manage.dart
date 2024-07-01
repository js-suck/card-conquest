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
  late TextEditingController _roundsController;
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
    _roundsController = TextEditingController();
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
        'rounds': int.parse(_roundsController.text),
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
            _nameController.text = tournament.name;
            _descriptionController.text = tournament.description;
            _locationController.text = tournament.location;
            _roundsController.text = tournament.rounds.toString();
            _maxPlayersController.text = tournament.maxPlayers.toString();
            _startDateController.text = tournament.startDate;
            _endDateController.text = tournament.endDate;

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
                      tournament.users.isNotEmpty
                          ? ListView.builder(
                              itemCount: tournament.users.length,
                              itemBuilder: (context, index) {
                                User user = tournament.users[index];
                                return ListTile(
                                  title: Text(user.username),
                                );
                              },
                            )
                          : const Center(
                              child: Text('Aucun utilisateur inscrit')),
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
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Email:',
                                style: TextStyle(fontSize: 18.0),
                              ),
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
                              Container(
                                decoration: BoxDecoration(
                                  color: colorBGInput,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextFormField(
                                  controller: _roundsController,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText: 'Nombre de rounds',
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
                              GestureDetector(
                                onTap: _pickImageFromGallery,
                                child: DottedBorder(
                                  color: Colors.grey,
                                  strokeWidth: 1,
                                  dashPattern: const [5, 5],
                                  child: Container(
                                    height: 150,
                                    width: double.infinity,
                                    color: colorBGInput,
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
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _roundsController.dispose();
    _maxPlayersController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}

class User {
  final int id;
  final String username;

  User({
    required this.id,
    required this.username,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
    );
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
  final int rounds;
  final List<User> users;

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.imageFilename,
    required this.maxPlayers,
    required this.rounds,
    required this.users,
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
      rounds: json['rounds'] ?? 0,
      users: (json['user_tournaments'] as List<dynamic>?)
              ?.map((userJson) => User.fromJson(userJson))
              .toList() ??
          [], // Utiliser une liste vide si null
    );
  }
}
