import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class CreateGuildPage extends StatefulWidget {
  const CreateGuildPage({super.key});

  @override
  _CreateGuildPageState createState() => _CreateGuildPageState();
}

class _CreateGuildPageState extends State<CreateGuildPage> {
  final _formKey = GlobalKey<FormState>();
  String _guildName = '';
  String _guildDescription = '';

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      const storage = FlutterSecureStorage();
      String? token = await storage.read(key: 'jwt_token');

      // Convert the data to JSON
      var data = {
        'Name': _guildName,
        'Description': _guildDescription,
      };

      // Send a POST request
      var response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}guilds'),
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Guilde créée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/guild');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la création de la guilde: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Le formulaire est invalide'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Guild'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Guild Name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a guild name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _guildName = value!;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Guild Description',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a guild description';
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
                child: const Text('Create Guild'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
