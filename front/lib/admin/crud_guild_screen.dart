import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/guild.dart';
import 'package:front/services/api_service.dart';

class CrudGuildScreen extends StatefulWidget {
  const CrudGuildScreen({Key? key}) : super(key: key);

  @override
  _CrudGuildScreenState createState() => _CrudGuildScreenState();
}

class _CrudGuildScreenState extends State<CrudGuildScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late ApiService apiService;
  List<Guild> guilds = [];
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
      await _fetchGuilds();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchGuilds() async {
    try {
      final data = await apiService.get('guilds');
      setState(() {
        guilds = data.map<Guild>((json) => Guild.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createGuild(Guild guild) async {
    try {
      final response = await apiService.post('guilds', guild.toJson());
      if (response.statusCode == 200) {
        _fetchGuilds();
      } else {
        print('Failed to create guild. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateGuild(Guild guild) async {
    try {
      final response = await apiService.put('guilds/${guild.id}', guild.toJson());
      if (response.statusCode == 200) {
        _fetchGuilds();
      } else {
        print('Failed to update guild. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteGuild(int id) async {
    try {
      final response = await apiService.delete('guilds/$id');
      if (response.statusCode == 200) {
        _fetchGuilds();
      } else {
        print('Failed to delete guild. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showGuildDialog(Guild? guild) {
    final _nameController = TextEditingController(text: guild?.name ?? '');
    final _descriptionController = TextEditingController(text: guild?.description ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(guild == null ? 'Create Guild' : 'Update Guild'),
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
                if (guild == null) {
                  _createGuild(
                    Guild(
                      id: 0,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      media: Media(id: 0, createdAt: '', updatedAt: '', fileName: '', fileExtension: ''),
                      players: [],
                    ),
                  );
                } else {
                  _updateGuild(
                    Guild(
                      id: guild.id,
                      name: _nameController.text,
                      description: _descriptionController.text,
                      media: guild.media,
                      players: guild.players,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(guild == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Guild'), centerTitle: true, automaticallyImplyLeading: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
          itemCount: guilds.length,
          itemBuilder: (context, index) {
            final guild = guilds[index];
            return ListTile(
              title: Text(guild.name),
              subtitle: Text(guild.description),
              trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showGuildDialog(guild),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteGuild(guild.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGuildDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
