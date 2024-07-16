import 'package:flutter/material.dart';
import 'package:front/models/tag.dart';
import 'package:front/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CrudTagScreen extends StatefulWidget {
  const CrudTagScreen({Key? key}) : super(key: key);

  @override
  _CrudTagScreenState createState() => _CrudTagScreenState();
}

class _CrudTagScreenState extends State<CrudTagScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late ApiService apiService;
  List<Tag> tags = [];
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
      await _fetchTags();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchTags() async {
    try {
      final data = await apiService.get('tags');
      setState(() {
        tags = data.map<Tag>((json) => Tag.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTag(Tag tag) async {
    try {
      final response = await apiService.post('tags', tag.toJson());
      if (response.statusCode == 200) {
        _fetchTags();
      } else {
        print('Failed to create tag. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _updateTag(Tag tag) async {
    try {
      final response = await apiService.put('tags/${tag.id}', tag.toJson());
      if (response.statusCode == 200) {
        _fetchTags();
      } else {
        print('Failed to update tag. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteTag(int id) async {
    try {
      final response = await apiService.delete('tags/$id');
      if (response.statusCode == 200) {
        _fetchTags();
      } else {
        print('Failed to delete tag. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _showTagDialog(Tag? tag) {
    final _labelController = TextEditingController(text: tag?.label ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(tag == null ? 'Create Tag' : 'Update Tag'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _labelController,
                  decoration: const InputDecoration(labelText: 'Label'),
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
                if (tag == null) {
                  _createTag(
                    Tag(
                      id: 0,
                      label: _labelController.text,
                    ),
                  );
                } else {
                  _updateTag(
                    Tag(
                      id: tag.id,
                      label: _labelController.text,
                    ),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(tag == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD Tag'), centerTitle: true, automaticallyImplyLeading: false),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: tags.length,
        itemBuilder: (context, index) {
          final tag = tags[index];
          return ListTile(
            title: Text(tag.label),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showTagDialog(tag),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTag(tag.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTagDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
