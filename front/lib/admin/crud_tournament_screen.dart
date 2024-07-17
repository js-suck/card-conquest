import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/match/tournament.dart';
import 'package:front/models/match/user.dart';
import 'package:front/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:front/models/match/game_match.dart';

class CrudTournamentScreen extends StatefulWidget {
  const CrudTournamentScreen({Key? key}) : super(key: key);

  @override
  _CrudTournamentScreenState createState() => _CrudTournamentScreenState();
}

class _CrudTournamentScreenState extends State<CrudTournamentScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late ApiService apiService;
  List<Tournament> tournaments = [];
  bool _isLoading = true;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      apiService = ApiService('${dotenv.env['API_URL']}', token);
      await _fetchTournaments();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTournaments() async {
    try {
      final data = await apiService.get('tournaments');
      setState(() {
        tournaments =
            data.map<Tournament>((json) => Tournament.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching tournaments: $e'); // Debugging
    }
  }

  Future<void> _createTournament(Tournament tournament) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiService.baseUrl}tournaments'),
      )
        ..headers['Authorization'] = '${apiService.token}'
        ..fields['name'] = tournament.name
        ..fields['description'] = tournament.description!
        ..fields['start_date'] = tournament.startDate.toIso8601String()
        ..fields['end_date'] = tournament.endDate.toIso8601String()
        ..fields['organizer_id'] = tournament.organizer.id.toString()
        ..fields['game_id'] = tournament.game.id.toString()
        ..fields['rounds'] =
            (log(tournament.maxPlayers) / log(2)).ceil().toString()
        ..fields['tagsIDs[]'] = tournament.tags!.join(',')
        ..fields['location'] = tournament.location!
        ..fields['max_players'] = tournament.maxPlayers.toString();

      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          contentType:
              MediaType('image', path.extension(_imageFile!.path).substring(1)),
        ));
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        await _fetchTournaments();
      } else {
        print(
            'Failed to create tournament. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateTournament(Tournament tournament) async {
    try {
      final Map<String, dynamic> tournamentData = {
        'id': tournament.id,
        'name': tournament.name,
        'description': tournament.description,
        'location': tournament.location,
        'start_date': tournament.startDate.toIso8601String(),
        'end_date': tournament.endDate.toIso8601String(),
        'media': tournament.media?.toJson(),
        'max_players': tournament.maxPlayers,
        'rounds': (log(tournament.maxPlayers) / log(2)).ceil(),
        'organizer_id': tournament.organizer.id,
        'game_id': tournament.game,
        'tags': tournament.tags,
        'status': tournament.status,
      };
      final response =
          await apiService.put('tournaments/${tournament.id}', tournamentData);
      if (response.statusCode == 200) {
        await _fetchTournaments();
      } else {
        print(
            'Failed to update tournament. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteTournament(int id) async {
    try {
      final response = await apiService.delete('tournaments/$id');
      if (response.statusCode == 204) {
        await _fetchTournaments();
      } else {
        print(
            'Failed to delete tournament. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showTournamentDialog(Tournament? tournament) {
    final _nameController = TextEditingController(text: tournament?.name ?? '');
    final _descriptionController =
        TextEditingController(text: tournament?.description ?? '');
    final _locationController =
        TextEditingController(text: tournament?.location ?? '');
    final _startDateController = TextEditingController(
        text: tournament?.startDate.toIso8601String() ?? '');
    final _endDateController = TextEditingController(
        text: tournament?.endDate.toIso8601String() ?? '');
    final _maxPlayersController =
        TextEditingController(text: tournament?.maxPlayers.toString() ?? '0');
    final _gameIdController =
        TextEditingController(text: tournament?.game.id.toString() ?? '0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              tournament == null ? 'Create Tournament' : 'Update Tournament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                TextField(
                  controller: _startDateController,
                  decoration: const InputDecoration(
                      labelText: 'Start Date', hintText: 'YYYY-MM-DD'),
                ),
                TextField(
                  controller: _endDateController,
                  decoration: const InputDecoration(
                      labelText: 'End Date', hintText: 'YYYY-MM-DD'),
                ),
                TextField(
                  controller: _maxPlayersController,
                  decoration: const InputDecoration(labelText: 'Max Players'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _gameIdController,
                  decoration: const InputDecoration(labelText: 'Game ID'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Pick Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (tournament == null) {
                  _createTournament(
                    Tournament(
                      id: 0,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      location: _locationController.text,
                      startDate: DateTime.parse(_startDateController.text),
                      endDate: DateTime.parse(_endDateController.text),
                      media: null,
                      // Placeholder for media
                      maxPlayers: int.parse(_maxPlayersController.text),
                      organizer: Organizer(
                        id: 1,
                        username: 'Organizer Name',
                        email: 'organizer@example.com',
                      ),
                      // Placeholder for organizer
                      game: GameMatch(
                        id: int.parse(_gameIdController.text),
                        name: 'Game Name',
                      ),
                      // Placeholder for game
                      tags: null,
                      status: 'opened',
                      playersRegistered: 0, players: [], // Default status
                    ),
                  );
                } else {
                  _updateTournament(
                    Tournament(
                        id: tournament.id,
                        name: _nameController.text,
                        description: _descriptionController.text,
                        location: _locationController.text,
                        startDate: DateTime.parse(_startDateController.text),
                        endDate: DateTime.parse(_endDateController.text),
                        media: tournament.media,
                        maxPlayers: int.parse(_maxPlayersController.text),
                        organizer: tournament.organizer,
                        game: tournament.game,
                        tags: tournament.tags,
                        status: tournament.status,
                        playersRegistered: tournament.playersRegistered, players: []),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(tournament == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('CRUD Tournament'),
          centerTitle: true,
          automaticallyImplyLeading: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: tournaments.length,
              itemBuilder: (context, index) {
                final tournament = tournaments[index];
                return ListTile(
                  title: Text(tournament.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status: ${tournament.status}'),
                      Text('Start Date: ${tournament.startDate}'),
                      Text('End Date: ${tournament.endDate}'),
                      Text('Location: ${tournament.location}'),
                      Text('Max Players: ${tournament.maxPlayers}'),
                      Text('Organizer: ${tournament.organizer.username}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showTournamentDialog(tournament),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteTournament(tournament.id),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTournamentDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
