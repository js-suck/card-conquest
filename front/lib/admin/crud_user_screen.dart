import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/user.dart';
import 'package:front/services/api_service.dart';

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
    _initialize();
  }

  Future<void> _initialize() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      apiService = ApiService('${dotenv.env['API_URL']}', token);
      await _fetchUsers();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final data = await apiService.get('users');
      setState(() {
        users = data.map<User>((json) => User.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createUser(User user, String password) async {
    try {
      final Map<String, dynamic> userData = user.toJson();
      userData['password'] = password;
      await apiService.post('users', userData);
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

  Future<void> _deleteUser(int? id) async {
    try {
      await apiService.delete('users/$id');
      _fetchUsers();
    } catch (e) {
      // Handle error
    }
  }

  void _showUserDialog(User? user) {
    final _usernameController =
    TextEditingController(text: user?.username ?? '');
    final _emailController = TextEditingController(text: user?.email ?? '');
    final _passwordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    String? _selectedRole = user?.role;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Create User' : 'Update User'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: ['user', 'organizer', 'admin']
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(role),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a role';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    return null;
                  },
                ),
                if (user == null)
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
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
                if (_formKey.currentState?.validate() ?? false) {
                  if (user == null) {
                    _createUser(
                      User(
                        id: 0,
                        username: _usernameController.text,
                        email: _emailController.text,
                        role: _selectedRole!,
                      ),
                      _passwordController.text,
                    );
                  } else {
                    _updateUser(User(
                      id: user.id,
                      username: _usernameController.text,
                      email: _emailController.text,
                      role: _selectedRole!,
                    ));
                  }
                  Navigator.of(context).pop();
                }
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
      appBar: AppBar(
        title: const Text('CRUD User', style: TextStyle(color: Colors.white, fontSize: 24.0)),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6.0,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              title: Text(user.username, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(user.email ?? ''),
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
