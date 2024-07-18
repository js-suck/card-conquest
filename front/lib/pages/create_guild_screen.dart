import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/media.dart';
import 'package:front/service/media_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:front/extension/theme_extension.dart';
import 'package:dotted_border/dotted_border.dart';

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
        title: Text(t.guildCreateTitle, style: const TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_imageFile != null)
                  Center(child: Image.file(_imageFile!))
                else
                  GestureDetector(
                    onTap: _pickImage,
                    child: DottedBorder(
                      color: Colors.black,
                      strokeWidth: 1,
                      padding: const EdgeInsets.all(20),
                      child: const Center(
                        child: SizedBox(
                          width: 150,
                          height: 150,
                          child: Icon(
                            Icons.image,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  t.guildName,
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: InputDecoration(
                    fillColor: context.themeColors.secondaryBackgroundAccentColor,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
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
                const SizedBox(height: 20),
                Text(
                  t.guildDescription,
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  decoration: InputDecoration(
                    fillColor: context.themeColors.secondaryBackgroundAccentColor,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFFF933D),
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    t.guildCreate,
                    style: const TextStyle(
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
  }
}
