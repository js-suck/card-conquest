import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/models/media.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:front/service/media_service.dart';

class CreateGuildPage extends StatefulWidget {
  const CreateGuildPage({super.key});

  @override
  _CreateGuildPageState createState() => _CreateGuildPageState();
}

class _CreateGuildPageState extends State<CreateGuildPage> {
  final _formKey = GlobalKey<FormState>();
  String _guildName = '';
  String _guildDescription = '';
  File? _imageFile;
  final mediaService = MediaService(
    storage: const FlutterSecureStorage(),
  );

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile = File(pickedFile.path);
      }
    });
  }

  void _submitForm() async {
    final t = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        Media media = await mediaService.uploadImage(_imageFile!);

         var data = {
        'Name': _guildName,
        'Description': _guildDescription,
        'media_id': media.id,
      };
        const storage = FlutterSecureStorage();
        String? token = await storage.read(key: 'jwt_token');
        var response = await http.post(
          Uri.parse('${dotenv.env['API_URL']}guilds'),
          headers: {
            HttpHeaders.authorizationHeader: '$token',
            HttpHeaders.contentTypeHeader: 'application/json',
          },
          body: jsonEncode(data),
        );

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.guildCreateWithSuccess),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/guild');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.guildCreateFailed),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.imageUploadFailed),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.invalidForm),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Guild', style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration:  InputDecoration(
                    labelText: t.guildName,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.guildInvalidName;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _guildName = value!;
                  },
                ),
                TextFormField(
                  decoration:  InputDecoration(
                    labelText: t.guildDescription,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.guildInvalidDescription;
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _guildDescription = value!;
                  },
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child:  Text(t.imagePick),
                ),
                if (_imageFile != null)
                  Image.file(_imageFile!),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text(t.guildCreate)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
