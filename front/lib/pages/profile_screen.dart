import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/service/user_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:front/widget/app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final storage = const FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  int userId = 0;
  Map<String, dynamic> userData = {};
  XFile? _image;
  final ImagePicker _picker = ImagePicker();
  late UserService userService;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    userService.fetchUser(userId);
  }

  getUserId() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      userId = decodedToken['user_id'];
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _image = image;
      });
      await _uploadImage(image.path);
    }
  }

  Future<void> _uploadImage(String filePath) async {
    String? token = await storage.read(key: 'jwt_token');
    var uri = Uri.parse('${dotenv.env['API_URL']}users/$userId/upload/picture');
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = '$token'
      ..files.add(await http.MultipartFile.fromPath(
        'file', // Assurez-vous que c'est le nom attendu par votre API
        filePath,
      ));

    var response = await request.send();
    if (response.statusCode == 200) {
      _showSuccess('Image uploaded successfully.');
    } else {
      _showError('Failed to upload image.');
    }
  }

  Future<void> _updateUserData() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      String? token = await storage.read(key: 'jwt_token');
      final response = await http.put(
        Uri.parse('${dotenv.env['API_URL']}users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': '$token',
        },
        body: json.encode({
          'email': userData['email'],
          'username': userData['username'],
          // Add other fields as necessary
        }),
      );
      if (response.statusCode == 200) {
        _showSuccess('Profile updated successfully.');
      } else {
        _showError('Failed to update profile.');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopAppBar(
        title: 'Profile',
        isPage: true,
        isAvatar: false,
      ),
      body: CustomFutureBuilder(
          future: userService.fetchUser(userId),
          onLoaded: (user) {
            return SingleChildScrollView(
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
                        if (_image != null) Image.file(File(_image!.path)),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Change Profile Picture'),
                        ),
                        const Text(
                          'Update Your Profile',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: user.username,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSaved: (value) => user.username = value!,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          initialValue: user.email,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            fillColor: Colors.grey[100],
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSaved: (value) => user.email = value!,
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
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }
}
