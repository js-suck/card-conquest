//import 'dart:html';

import 'dart:io';

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
  final TextEditingController _controller = TextEditingController();
  static const colorBGInput = Color(0xfafafafa);
  File? _selectedImage;

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
                    controller: _controller,
                    keyboardType: TextInputType.number,
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
                    controller: _controller,
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
                const DropdownMenu(
                  inputDecorationTheme: InputDecorationTheme(
                      outlineBorder: BorderSide(color: colorBGInput),
                      fillColor: colorBGInput),
                  menuStyle: MenuStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(colorBGInput),
                  ),
                  label: Text(
                    'Sélectionnez un jeu',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  width: 300,
                  dropdownMenuEntries: [
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
                const DropdownMenu(
                  inputDecorationTheme: InputDecorationTheme(
                      outlineBorder: BorderSide(color: colorBGInput),
                      fillColor: colorBGInput),
                  menuStyle: MenuStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(colorBGInput),
                  ),
                  label: Text(
                    'Sélectionnez un type',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  width: 300,
                  dropdownMenuEntries: [
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
                const DropdownMenu(
                  inputDecorationTheme: InputDecorationTheme(
                      outlineBorder: BorderSide(color: colorBGInput),
                      fillColor: colorBGInput),
                  menuStyle: MenuStyle(
                    backgroundColor:
                        MaterialStatePropertyAll<Color>(colorBGInput),
                  ),
                  label: Text(
                    'Nombre max de places',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  width: 300,
                  dropdownMenuEntries: [
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
                    controller: _controller,
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
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
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
}
