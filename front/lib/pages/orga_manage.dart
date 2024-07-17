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
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:front/pages/bracket_screen.dart';

class OrganizerManagePage extends StatefulWidget {
  final int tournamentId;

  OrganizerManagePage({required this.tournamentId});

  @override
  _OrganizerManagePageState createState() => _OrganizerManagePageState();
}

class _OrganizerManagePageState extends State<OrganizerManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final storage = const FlutterSecureStorage();

  bool _loading = true;
  Tournament? _tournament;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  double? latitude;
  double? longitude;
  File? _selectedImage;
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _startDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _endDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatDateForBackend(DateTime date) {
    return '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(date.toUtc())}Z';
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final tournament = await fetchTournament(widget.tournamentId);
      setState(() {
        _nameController.text = tournament.name;
        _locationController.text = tournament.location;
        _descriptionController.text = tournament.description;
        _startDateController.text = _formatDateForDisplay(tournament.startDate);
        _endDateController.text = _formatDateForDisplay(tournament.endDate);
        _tournament = tournament;
        _loading = false;
      });
    });
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
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'start_date': _formatDateForBackend(_startDate!),
        'end_date': _formatDateForBackend(_endDate!),
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
      setState(() {
        _tournament?.status = 'started';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Échec du démarrage du tournoi: ${response.body}')),
      );
    }
  }

  Future<void> _finishTournament(int tournamentID) async {
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}tournaments/$tournamentID'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'status': 'finished',
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tournament finished successfully')),
      );
      setState(() {
        _tournament?.status = 'finished';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Failed to update tournament status: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String? status = _tournament?.status;

    return Scaffold(
      appBar: const TopAppBar(
        title: 'Gestion',
        roundedCorners: false,
      ),
      body: Builder(
        builder: (context) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
            // } else if (snapshot.hasError) {
            //   return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
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
                      (_tournament == null ||
                              _tournament?.players.isEmpty == true)
                          ? const Center(
                              child: Text('Aucun utilisateur inscrit'))
                          : ListView.builder(
                              itemCount: _tournament!.players.length,
                              itemBuilder: (context, index) {
                                final player = _tournament!.players[index];
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
                              child: TextField(
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
                              'Adresse:',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: TextField(
                                  controller: _locationController,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText: 'ex: 10 rue des ananas',
                                  ),
                                  onTap: () async {
                                    try {
                                      String? apiKey =
                                          dotenv.env['GOOGLE_API_KEY'];
                                      if (apiKey == null) {
                                        throw Exception(
                                            "API Key is not set in the environment variables");
                                      }

                                      Prediction? p =
                                          await PlacesAutocomplete.show(
                                        context: context,
                                        apiKey: apiKey,
                                        types: ["geocode"],
                                        mode: Mode.overlay,
                                        language: "fr",
                                        components: [
                                          Component(Component.country, "fr")
                                        ],
                                        strictbounds: false,
                                      );

                                      if (p != null) {
                                        GoogleMapsPlaces _places =
                                            GoogleMapsPlaces(apiKey: apiKey);
                                        PlacesDetailsResponse detail =
                                            await _places.getDetailsByPlaceId(
                                                p.placeId!);

                                        setState(() {
                                          _locationController.text =
                                              p.description!;
                                          latitude = detail
                                              .result.geometry!.location.lat;
                                          longitude = detail
                                              .result.geometry!.location.lng;
                                          print(
                                              'Inside setState: $_locationController.text');
                                        });
                                        print(_locationController.text);
                                        print('aahahah');
                                        // Perte de focus pour forcer la mise à jour visuelle
                                      }
                                    } catch (e) {
                                      print("Error occurred: $e");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content:
                                              Text('An error occurred: $e'),
                                        ),
                                      );
                                    }
                                  },
                                )),
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
                              child: TextField(
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
                              'Date de début du tournoi:',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            InkWell(
                              onTap: () => _selectStartDate(context),
                              child: IgnorePointer(
                                child: TextField(
                                  controller: _startDateController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Date de fin du tournoi:',
                              style: TextStyle(fontSize: 18.0),
                            ),
                            InkWell(
                              onTap: () => _selectEndDate(context),
                              child: IgnorePointer(
                                child: TextField(
                                  controller: _endDateController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
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
                                if (_tournament != null) {
                                  updateTournament(_tournament!);
                                }
                              },
                              child: const Text('Modifier le tournoi'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          // } else {
          //   return const Center(child: Text('Aucun tournoi trouvé'));
          // }
        },
      ),
      floatingActionButton: _tournament?.players.isEmpty == false
          ? ExpandableFab(
              distance: 112.0,
              children: [
                if (status == 'opened') ...[
                  FloatingActionButton(
                    heroTag: "startTournament${widget.tournamentId}",
                    onPressed: _startTournament,
                    tooltip: 'Démarrer le tournoi',
                    child: const Icon(Icons.play_arrow),
                  ),
                ] else if (status == 'started') ...[
                  FloatingActionButton(
                    heroTag: "finishTournament${widget.tournamentId}",
                    onPressed: () => _finishTournament(widget.tournamentId),
                    tooltip: 'Terminer le tournoi',
                    child: const Icon(Icons.stop),
                  ),
                  FloatingActionButton(
                    heroTag: "bracket${widget.tournamentId}",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BracketPage(tournamentID: widget.tournamentId),
                        ),
                      );
                    },
                    tooltip: 'Voir le bracket',
                    child: const Icon(Icons.format_list_numbered),
                  ),
                ] else if (status == 'finished') ...[
                  FloatingActionButton(
                    heroTag: "startTournament${widget.tournamentId}",
                    onPressed: _startTournament,
                    tooltip: 'Redémarrer le tournoi',
                    child: const Icon(Icons.play_arrow),
                  ),
                  FloatingActionButton(
                    heroTag: "bracket${widget.tournamentId}",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BracketPage(tournamentID: widget.tournamentId),
                        ),
                      );
                    },
                    tooltip: 'Voir le bracket',
                    child: const Icon(Icons.format_list_numbered),
                  ),
                ],
              ],
            )
          : null,
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
    super.dispose();
  }
}

class Tournament {
  final int id;
  final String name;
  final String description;
  final String location;
  late String status;
  final DateTime startDate;
  final DateTime endDate;
  final String imageFilename;
  final int maxPlayers;
  final List<dynamic> players; // Changed type to dynamic

  Tournament({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.imageFilename,
    required this.maxPlayers,
    required this.players,
  });

  factory Tournament.fromJson(Map<String, dynamic> json) {
    return Tournament(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      location: json['location'],
      status: json['status'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      imageFilename: json['media']['file_name'],
      maxPlayers: json['max_players'] ?? 0,
      players: json['players'] ?? [],
    );
  }
}
