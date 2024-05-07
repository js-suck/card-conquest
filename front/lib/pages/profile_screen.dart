import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? userId;
  Map<String, dynamic> userData = {};

  XFile? _image;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      userId = jsonDecode(ascii.decode(base64.decode(base64.normalize(token.split(".")[1]))))['id'];
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/v1/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        // Handle errors
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }


  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? token = await storage.read(key: 'jwt_token');
      final response = await http.put(
        Uri.parse('http://10.0.2.2:8080/api/v1/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'email': userData['email'],
          'username': userData['username'],
          // Add other fields as necessary
        }),
      );
      if (response.statusCode == 200) {
        // Handle success
      } else {
        // Handle errors
      }
    }
  }

  Future<void> _uploadImage(String filePath) async {
    var uri = Uri.parse('http://10.0.2.2:8080/api/v1/users/$userId/upload/picture');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer your_jwt_token'
      ..files.add(await http.MultipartFile.fromPath(
        'file', // Assurez-vous que c'est le nom attendu par votre API
        filePath,
      ));

    var response = await request.send();
    if (response.statusCode == 200) {
      // Success
    } else {
      // Error
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: _isLoading ? const CircularProgressIndicator() : SingleChildScrollView(
        child: Center(
          child: Container(
            width: 320,
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_image != null)
                    Image.file(File(_image!.path)),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Change Profile Picture'),
                  ),
                  const Text(
                    'Update Your Profile',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: userData['username'],
                    decoration: InputDecoration(
                      labelText: 'Username',
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSaved: (value) => userData['username'] = value!,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: userData['email'],
                    decoration: InputDecoration(
                      labelText: 'Email',
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSaved: (value) => userData['email'] = value!,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _updateUserData,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFFFF933D),
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
