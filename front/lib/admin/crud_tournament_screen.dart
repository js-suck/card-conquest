import 'package:flutter/material.dart';
import 'package:front/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/game.dart';
import '../models/match/tournament.dart';
import '../models/organizer.dart';

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

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      apiService = ApiService('http://localhost:8080/api/v1', token);
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
    }
  }

  Future<void> _createTournament(Tournament tournament) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${apiService.baseUrl}/tournaments'),
      )
        ..headers['Authorization'] = '${apiService.token}'
        ..fields['name'] = tournament.name
        ..fields['description'] = tournament.description!
        ..fields['start_date'] = tournament.startDate
        ..fields['end_date'] = tournament.endDate
        ..fields['organizer_id'] = tournament.organizer.id.toString()
        ..fields['game_id'] = tournament.game.id.toString()
        ..fields['rounds'] = tournament.rounds.toString()
        ..fields['tagsIDs[]'] = tournament.tags.join(',')
        ..fields['location'] = tournament.location!
        ..fields['max_players'] = tournament.maxPlayers.toString();

      final response = await request.send();
      if (response.statusCode == 200) {
        _fetchTournaments();
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
      final response = await apiService.put(
          'tournaments/${tournament.id}', tournament.toJson());
      if (response.statusCode == 200) {
        _fetchTournaments();
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
      if (response.statusCode == 200) {
        _fetchTournaments();
      } else {
        print(
            'Failed to delete tournament. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showTournamentDialog(Tournament? tournament) {
    final _nameController = TextEditingController(text: tournament?.name ?? '');
    final _descriptionController =
        TextEditingController(text: tournament?.description ?? '');
    final _locationController =
        TextEditingController(text: tournament?.location ?? '');
    final _startDateController =
        TextEditingController(text: tournament?.startDate ?? '');
    final _endDateController =
        TextEditingController(text: tournament?.endDate ?? '');
    final _maxPlayersController =
        TextEditingController(text: tournament?.maxPlayers.toString() ?? '0');
    final _roundsController =
        TextEditingController(text: tournament?.rounds.toString() ?? '1');

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
                  decoration: const InputDecoration(labelText: 'Start Date'),
                ),
                TextField(
                  controller: _endDateController,
                  decoration: const InputDecoration(labelText: 'End Date'),
                ),
                TextField(
                  controller: _maxPlayersController,
                  decoration: const InputDecoration(labelText: 'Max Players'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _roundsController,
                  decoration: const InputDecoration(labelText: 'Rounds'),
                  keyboardType: TextInputType.number,
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
                      startDate: _startDateController.text,
                      endDate: _endDateController.text,
                      imageUrl: '', // Placeholder
                      maxPlayers: int.parse(_maxPlayersController.text),
                      organizer: Organizer(
                          id: 1,
                          name: 'Organizer Name',
                          email: 'organizer@example.com'), // Placeholder
                      game: Game(
                          id: 1,
                          name: 'Game Name',
                          imageUrl: ''), // Placeholder
                      tags: [],
                      status: 'opened', // Default status
                      rounds: int.parse(_roundsController.text),
                    ),
                  );
                } else {
                  _updateTournament(
                    Tournament(
                      id: tournament.id,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      location: _locationController.text,
                      startDate: _startDateController.text,
                      endDate: _endDateController.text,
                      imageUrl: tournament.imageUrl,
                      maxPlayers: int.parse(_maxPlayersController.text),
                      organizer: tournament.organizer,
                      game: tournament.game,
                      tags: tournament.tags,
                      status: tournament.status,
                      rounds: int.parse(_roundsController.text),
                    ),
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
                      Text('Organizer: ${tournament.organizer.name}'),
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
