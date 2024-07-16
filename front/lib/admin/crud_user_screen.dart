import 'package:flutter/material.dart';
import 'package:front/models/user.dart';
import 'package:front/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class CrudUserScreen extends StatefulWidget {
  const CrudUserScreen({Key? key}) : super(key: key);

  @override
  _CrudUserScreenState createState() => _CrudUserScreenState();
}

class _CrudUserScreenState extends State<CrudUserScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late ApiService apiService;
  List<User> users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // token
    String? token = _storage.read(key: 'jwt_token') as String?;
    apiService = ApiService('http://localhost:8080/api/v1', token!);
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await apiService.get('users');
      setState(() {
        users = data.map<User>((json) => User.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _createUser(User user) async {
    try {
      await apiService.post('users', user.toJson());
      _fetchUsers();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateUser(User user) async {
    try {
      await apiService.put('users/${user.id}', user.toJson());
      _fetchUsers();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteUser(int id) async {
    try {
      await apiService.delete('users/$id');
      _fetchUsers();
    } catch (e) {
      // Handle error
    }
  }

  void _showUserDialog(User? user) {
    final _usernameController = TextEditingController(text: user?.username ?? '');
    final _emailController = TextEditingController(text: user?.email ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Create User' : 'Update User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (user == null) {
                  _createUser(User(
                    id: 0,
                    username: _usernameController.text,
                    email: _emailController.text,
                    role: 'user',
                  ));
                } else {
                  _updateUser(User(
                    id: user.id,
                    username: _usernameController.text,
                    email: _emailController.text,
                    role: user.role,
                  ));
                }
                Navigator.of(context).pop();
              },
              child: Text(user == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CRUD User')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text(user.email),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showUserDialog(user),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteUser(user.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserDialog(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
