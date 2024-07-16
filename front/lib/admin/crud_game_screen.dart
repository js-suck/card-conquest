import 'package:flutter/material.dart';
import 'package:front/models/game.dart';
import 'package:front/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CrudGameScreen extends StatefulWidget {
  const CrudGameScreen({Key? key}) : super(key: key);

  @override
  _CrudGameScreenState createState() => _CrudGameScreenState();
}

class _CrudGameScreenState extends State<CrudGameScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late ApiService apiService;
  List<Game> games = [];
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
      await _fetchGames();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchGames() async {
    try {
      final data = await apiService.get('games');
      setState(() {
        games = data.map<Game>((json) => Game.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createGame(Game game) async {
    try {
      final response = await apiService.post('games', game.toJson());
      if (response.statusCode == 200) {
        _fetchGames();
      } else {
        print('Failed to create game. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateGame(Game game) async {
    try {
      final response = await apiService.put('games/${game.id}', game.toJson());
      if (response.statusCode == 200) {
        _fetchGames();
      } else {
        print('Failed to update game. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteGame(int id) async {
    try {
      final response = await apiService.delete('games/$id');
      if (response.statusCode == 204) {
        _fetchGames();
      } else {
        print('Failed to delete game. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showGameDialog(Game? game) {
    final _nameController = TextEditingController(text: game?.name ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(game == null ? 'Create Game' : 'Update Game'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
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
                if (game == null) {
                  _createGame(
                    Game(
                      id: 0,
                      name: _nameController.text,
                      media: null, // Placeholder
                    ),
                  );
                } else {
                  _updateGame(
                    Game(
                      id: game.id,
                      name: _nameController.text,
                      media: game.media,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(game == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Game'), centerTitle: true, automaticallyImplyLeading: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return ListTile(
            title: Text(game.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showGameDialog(game),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteGame(game.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGameDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
