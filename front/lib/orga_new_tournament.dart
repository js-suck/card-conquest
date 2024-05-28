//import 'dart:html';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';

class OrgaPage extends StatelessWidget {
  const OrgaPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TopAppBar(
        title: 'Creation Tournoi',
        isAvatar: false,
        isPage: true,
        isSettings: false,
      ),
      body: Scaffold(
        body: SingleChildScrollView(
          child: Center(
            child: MyForm(),
          ),
        ),
      ),
    );
  }
}

class MyForm extends StatefulWidget {
  const MyForm({super.key});

  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _selectGameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  static const colorBGInput = Color(0xfafafafa);
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _typeController.text = 'TKO';
    _selectGameController.text = 'Magic';
    _sizeController.text = '8';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          const Text(
            'Créer un nouveau tournoi',
            style: TextStyle(fontSize: 24.0),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 8.0),
                const Text(
                  'Designation du tournoi:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorBGInput, // Couleur du rectangle gris
                    borderRadius: BorderRadius.circular(8.0), // Bords arrondis
                  ),
                  child: TextField(
                    controller: _designationController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      border: InputBorder.none,
                      labelText: 'ex: Jon Smith',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Email:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorBGInput, // Couleur du rectangle gris
                    borderRadius: BorderRadius.circular(8.0), // Bords arrondis
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      border: InputBorder.none,
                      labelText: 'ex: jon.smith@email.com',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Game:',
                  style: TextStyle(fontSize: 18.0),
                ),
                DropdownMenu(
                  controller: _selectGameController,
                  inputDecorationTheme: const InputDecorationTheme(
                      outlineBorder: BorderSide(color: colorBGInput),
                      fillColor: colorBGInput),
                  menuStyle: const MenuStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(colorBGInput),
                  ),
                  label: const Text(
                    'Sélectionnez un jeu',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  width: 300,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'hearstone', label: 'Hearstone'),
                    DropdownMenuEntry(value: 'magic', label: 'Magic'),
                    DropdownMenuEntry(value: 'yugi oh', label: 'Yugi oh'),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Type de tournoi:',
                  style: TextStyle(fontSize: 18.0),
                ),
                DropdownMenu(
                  controller: _typeController,
                  inputDecorationTheme: const InputDecorationTheme(
                      outlineBorder: BorderSide(color: colorBGInput),
                      fillColor: colorBGInput),
                  menuStyle: const MenuStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(colorBGInput),
                  ),
                  label: const Text(
                    'Sélectionnez un type',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  width: 300,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 'suisse', label: 'Suisse'),
                    DropdownMenuEntry(value: 'tko', label: 'TKO'),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Image',
                  style: TextStyle(fontSize: 18.0),
                ),
                GestureDetector(
                  onTap: () {
                    _pickImageFromGallery();
                  },
                  child: _selectedImage != null
                      ? Image.file(_selectedImage!)
                      : DottedBorder(
                          color: Colors.black,
                          strokeWidth: 1,
                          padding: const EdgeInsets.all(20),
                          child: const Center(
                            child: SizedBox(
                              width: 150,
                              height: 150,
                              child: Icon(
                                Icons.image, // Utiliser l'icône image
                                size: 100, // Taille de l'icône
                                color: Colors.grey, // Couleur de l'icône
                              ),
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nombre de place:',
                  style: TextStyle(fontSize: 18.0),
                ),
                DropdownMenu(
                  controller: _sizeController,
                  inputDecorationTheme: const InputDecorationTheme(
                      outlineBorder: BorderSide(color: colorBGInput),
                      fillColor: colorBGInput),
                  menuStyle: const MenuStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(colorBGInput),
                  ),
                  label: const Text(
                    'Nombre max de places',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  width: 300,
                  dropdownMenuEntries: const [
                    DropdownMenuEntry(value: 8, label: '8 places'),
                    DropdownMenuEntry(value: 16, label: '16 places'),
                    DropdownMenuEntry(value: 32, label: '32 places'),
                    DropdownMenuEntry(value: 64, label: '64 places'),
                    DropdownMenuEntry(value: 128, label: '128 places'),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Description de votre tournoi:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: colorBGInput, // Couleur du rectangle gris
                    borderRadius: BorderRadius.circular(8.0), // Bords arrondis
                  ),
                  child: TextField(
                    controller: _descController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 8, //or null
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      border: InputBorder.none,
                      labelText: 'Entrez votre description',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 20),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _designationController.dispose();
    _emailController.dispose();
    _typeController.dispose();
    _selectGameController.dispose();
    _sizeController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      _selectedImage = File(returnImage!.path);
    });
  }

  Future<void> _submitForm() async {
    if (_designationController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _descController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Please fill in all required fields.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // All required fields are filled, proceed to submit the form
      try {
        var uri = Uri.parse('http://192.168.238.44:8080/api/v1/tournaments');
        // var uri = Uri.parse('http://127.0.0.1:8080/api/v1/tournaments');

        var request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] =
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MTY5MjQzMTgsIm5hbWUiOiJ1c2VyIiwicm9sZSI6ImFkbWluIiwidXNlcl9pZCI6MX0.JZKNDO3Dweh27eIDd6afZr4I5HA8ZVWWTkAflTAI_TU';

        DateTime startDate = DateTime(2024, 4, 12);
        DateTime endDate = DateTime(2024, 5, 12);

        String startDateIso = startDate.toUtc().toIso8601String();
        String endDateIso = endDate.toUtc().toIso8601String();

        // Ajoutez les champs de formulaire
        request.fields['name'] = _designationController.text;
        request.fields['description'] = _descController.text;
        request.fields['start_date'] = startDateIso;
        request.fields['end_date'] = endDateIso;
        request.fields['location'] = '10 rue de la chaussette';
        request.fields['organizer_id'] = '1';
        request.fields['game_id'] = '1';
        request.fields['rounds'] = _sizeController.text;
        request.fields['max_players'] = '5';

        if (_selectedImage != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'image', // le nom du champ de formulaire pour l'image
            _selectedImage!.path,
          ));
        }
        var response = await request.send();

        if (response.statusCode == 200) {
          // Traitement en cas de succès
          var responseData = await http.Response.fromStream(response);
          print('Success: ${responseData.body}');

          // Vider le formulaire
          _designationController.clear();
          _emailController.clear();
          _typeController.clear();
          _selectGameController.clear();
          _sizeController.clear();
          _descController.clear();
          setState(() {
            _selectedImage = null;
          });

          // Afficher une pop-up de succès
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Succès'),
              content: const Text('Le tournoi a été créé avec succès.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        } else {
          // Traitement en cas d'erreur
          var responseData = await http.Response.fromStream(response);
          print('Error: ${responseData.body}');
        }
      } catch (e) {
        // Gestion des erreurs
        print('Exception: $e');
      }
    }
  }
}
