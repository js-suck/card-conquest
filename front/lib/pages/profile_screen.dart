import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/service/user_service.dart';
import 'package:front/widget/app_bar.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/guild.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    userService = UserService();
    _initializeUserData();
  }

  Future<void> getUserId() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      setState(() {
        userId = decodedToken['user_id'];
      });
    }
  }

  Future<void> _initializeUserData() async {
    setState(() {
      _isLoading = true;
    });
    await getUserId();
    final user = await userService.fetchUser(userId, forceRefresh: true);
    setState(() {
      print("User data fetched and initialized." + user.toString());
      print(user.guilds?[0].name);
      userData = {
        'username': user.username,
        'email': user.email,
"guilds" : user.guilds
      };
      _isLoading = false;
    });
    print('User data fetched and initialized.');
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
    print(response.statusCode);
    print("Image uploaded successfully.");
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
        body: json.encode(userData),
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
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: TopAppBar(
        title: t.profileTitle,
        isPage: true,
        isAvatar: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    child: Text(t.profileChangeProfilePicture),
                  ),
                  Text(
                    t.profileUpdateProfileTitle,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    initialValue: userData['username'],
                    decoration: InputDecoration(
                      labelText: t.username,
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
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
                      labelText: t.email,
                      fillColor: Colors.grey[100],
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
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
                    child: Text(
                      t.profileUpdateProfile,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                if (userData['guilds'] != null && (userData['guilds'] as List).isNotEmpty)
  Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Your Guilds',
        style: TextStyle(
            fontSize: 24, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10),
      ...(userData['guilds'] as List<Guild>).map((guild) {
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
                context, '/guild/${guild.id}');
          },
          child: Center(
            child: Column(
              children: [
                if (guild.media != null)
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider(
                      '${dotenv.env['MEDIA_URL']}${guild.media!.fileName}',
                    ),
                    radius: 50,
                  ),
                const SizedBox(height: 10),
                Text('Guild: ${guild.name}'),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }).toList(),
    ],
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
