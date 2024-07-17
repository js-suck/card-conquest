//import 'dart:html';
import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

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
  final storage = const FlutterSecureStorage();
  final TextEditingController _designationController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _selectGameController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  static const colorBGInput = Color(0xfafafafa);
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  File? _selectedImage;
  int? _selectedValue;
  List<dynamic> games = [];

  double? latitude;
  double? longitude;

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        _startDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
        _endDateController.text = _formatDateForDisplay(picked);
      });
    }
  }

  String _formatDateForDisplay(DateTime date) {
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatDateForBackend(DateTime date) {
    return '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(date.toUtc())}Z';
  }

  Future<void> _loadGames() async {
    try {
      String? token = await storage.read(key: 'jwt_token');

      var response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}games'),
        headers: {
          'Authorization': '$token',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          games = json.decode(response.body);
        });
      } else {
        print('Failed to load games: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception while loading games: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _typeController.text = 'TKO';
    _sizeController.text = '32';
    _loadGames();
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
                  'Adresse:',
                  style: TextStyle(fontSize: 18.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xfafafafa),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: TextField(
                    controller: _locationController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      border: InputBorder.none,
                      labelText: 'ex: 10 rue des ananas',
                    ),
                    onTap: () async {
                      print("Tapped on address input");
                      try {
                        String? apiKey = dotenv.env['GOOGLE_API_KEY'];
                        if (apiKey == null) {
                          throw Exception(
                              "API Key is not set in the environment variables");
                        }

                        Prediction? p = await PlacesAutocomplete.show(
                          context: context,
                          apiKey: apiKey,
                          types: ["geocode"],
                          mode: Mode.overlay,
                          language: "fr",
                          components: [Component(Component.country, "fr")],
                          strictbounds: false,
                        );

                        print("Prediction received: $p");
                        if (p != null) {
                          GoogleMapsPlaces _places =
                              GoogleMapsPlaces(apiKey: apiKey);
                          PlacesDetailsResponse detail =
                              await _places.getDetailsByPlaceId(p.placeId!);

                          setState(() {
                            _locationController.text = p.description!;
                            latitude = detail.result.geometry!.location.lat;
                            longitude = detail.result.geometry!.location.lng;
                          });
                        }
                      } catch (e) {
                        print("Error occurred: $e");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('An error occurred: $e'),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Date de début du tournoi:',
                  style: TextStyle(fontSize: 18.0),
                ),
                InkWell(
                  onTap: () => _selectStartDate(context),
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: _startDateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Date de fin du tournoi:',
                  style: TextStyle(fontSize: 18.0),
                ),
                InkWell(
                  onTap: () => _selectEndDate(context),
                  child: IgnorePointer(
                    child: TextFormField(
                      controller: _endDateController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
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
                  dropdownMenuEntries: games.map<DropdownMenuEntry>((game) {
                    return DropdownMenuEntry(
                      value: game['id'],
                      label: game['name'],
                    );
                  }).toList(),
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
                    DropdownMenuEntry(value: 16, label: '16 places'),
                    DropdownMenuEntry(value: 32, label: '32 places'),
                    DropdownMenuEntry(value: 64, label: '64 places'),
                    DropdownMenuEntry(value: 128, label: '128 places'),
                  ],
                  onSelected: (int? value) {
                    setState(() {
                      _selectedValue = value;
                      _sizeController.text =
                          value != null ? '$value places' : '';
                    });
                  },
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
    _locationController.dispose();
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
    print("iciez1");

    if (_designationController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please fill in all required fields.'),
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
      // All required fields are filled, proceed to submit the form
      try {
        var uri = Uri.parse('${dotenv.env['API_URL']}tournaments');
        String? token = await storage.read(key: 'jwt_token');

        var request = http.MultipartRequest('POST', uri)
          ..headers['Authorization'] = '$token';

        // Ajoutez les champs de formulaire
        request.fields['name'] = _designationController.text;
        request.fields['description'] = _descController.text;
        request.fields['start_date'] = _formatDateForBackend(_startDate!);
        request.fields['end_date'] = _formatDateForBackend(_endDate!);
        request.fields['location'] = _locationController.text;
        request.fields['latitude'] = latitude.toString();
        request.fields['longitude'] = longitude.toString();
        request.fields['organizer_id'] = '1';
        request.fields['game_id'] = '1';
        num selectedValue = num.parse(_selectedValue.toString());
        int rounds = (log(selectedValue) / log(2)).ceil();
        request.fields['rounds'] = rounds.toString();
        request.fields['max_players'] = _selectedValue.toString();
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
          // Vider le formulaire
          _designationController.clear();
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
                    Navigator.pushNamed(context, '/orga/home');
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
