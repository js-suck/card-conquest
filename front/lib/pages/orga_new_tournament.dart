import 'dart:math';
import 'dart:convert';
import 'dart:io';
import 'package:front/extension/theme_extension.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:front/widget/app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrgaPage extends StatelessWidget {
  const OrgaPage({super.key});
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: TopAppBar(
        title: t.organizerNewTournament,
        isAvatar: false,
        isPage: true,
        isSettings: false,
      ),
      body: const Scaffold(
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
  int? _selectedGameId;
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
    return '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(date)}Z';
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
    _loadGames();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Column(
        children: [
          Text(
            t.organizerNewTournamentTitle,
            style: const TextStyle(fontSize: 24.0),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 8.0),
                Text(
                  t.organizerNewTournamentName,
                  style: const TextStyle(fontSize: 18.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: context.themeColors
                        .backgroundColor, // Couleur du rectangle gris
                    borderRadius: BorderRadius.circular(8.0), // Bords arrondis
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: TextField(
                    controller: _designationController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                      border: InputBorder.none,
                      labelText: 'ex: Pokemon',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  t.organizerNewTournamentAddress,
                  style: const TextStyle(fontSize: 18.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: context.themeColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: TextField(
                    controller: _locationController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10.0),
                      border: InputBorder.none,
                      labelText: t.organizerNewTournamentAddressHint,
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
                          language: t.organizerNewTournamentAddressLanguage,
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
                Text(
                  t.organizerNewTournamentStartDate,
                  style: const TextStyle(fontSize: 18.0),
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
                Text(
                  t.organizerNewTournamentEndDate,
                  style: const TextStyle(fontSize: 18.0),
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
                Text(
                  t.organizerNewTournamentGame,
                  style: const TextStyle(fontSize: 18.0),
                ),
                DropdownMenu(
                  controller: _selectGameController,
                  inputDecorationTheme: const InputDecorationTheme(
                      outlineBorder: BorderSide(color: colorBGInput),
                      fillColor: colorBGInput),
                  menuStyle: MenuStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(
                        context.themeColors.backgroundColor),
                  ),
                  label: Text(
                    t.organizerNewTournamentGameSelect,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  width: 300,
                  dropdownMenuEntries: games.map<DropdownMenuEntry>((game) {
                    return DropdownMenuEntry(
                      labelWidget: Text(
                        game['name'],
                        style: TextStyle(color: context.themeColors.fontColor),
                      ),
                      value: game['id'],
                      label: game['name'],
                    );
                  }).toList(),
                  onSelected: (dynamic value) {
                    setState(() {
                      _selectedGameId = value;
                      _selectGameController.text = games
                          .firstWhere((game) => game['id'] == value)['name'];
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  t.organizerNewTournamentImage,
                  style: const TextStyle(fontSize: 18.0),
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
                Text(
                  t.organizerNewTournamentSize,
                  style: const TextStyle(fontSize: 18.0),
                ),
                DropdownMenu(
                  controller: _sizeController,
                  inputDecorationTheme: const InputDecorationTheme(
                      outlineBorder: BorderSide(color: colorBGInput),
                      fillColor: colorBGInput),
                  menuStyle: MenuStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(
                        context.themeColors.backgroundColor),
                  ),
                  label: Text(
                    t.organizerNewTournamentMaxSize,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                  width: 300,
                  dropdownMenuEntries: [
                    DropdownMenuEntry(
                        labelWidget: Text(t.organizerNewTournament16players,
                            style: TextStyle(
                                color: context.themeColors.fontColor)),
                        value: 16,
                        label: t.organizerNewTournament16players),
                    DropdownMenuEntry(
                        labelWidget: Text(t.organizerNewTournament32players,
                            style: TextStyle(
                                color: context.themeColors.fontColor)),
                        value: 32,
                        label: t.organizerNewTournament32players),
                    DropdownMenuEntry(
                        labelWidget: Text(t.organizerNewTournament64players,
                            style: TextStyle(
                                color: context.themeColors.fontColor)),
                        value: 64,
                        label: t.organizerNewTournament64players),
                    DropdownMenuEntry(
                        labelWidget: Text(t.organizerNewTournament128players,
                            style: TextStyle(
                                color: context.themeColors.fontColor)),
                        value: 128,
                        label: t.organizerNewTournament128players),
                  ],
                  onSelected: (int? value) {
                    setState(() {
                      _selectedValue = value;
                      _sizeController.text = value != null
                          ? '$value ${t.organizerNewTournamentPlace}'
                          : '';
                    });
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  t.organizerNewTournamentDescription,
                  style: const TextStyle(fontSize: 18.0),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: context.themeColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0), // Bords arrondis
                    border: Border.all(
                      color: Colors.grey,
                    ),
                  ),
                  child: TextField(
                    controller: _descController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 8, //or null
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10.0),
                      border: InputBorder.none,
                      labelText: t.organizerNewTournamentDescriptionHint,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () {
                      _submitForm();
                    },
                    child: Text(
                      t.organizerNewTournamentCreate,
                      style: const TextStyle(fontSize: 16.0),
                    )),
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

  void _showLoader() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(t.organizerNewTournamentCreateLoading),
            ],
          ),
        );
      },
    );
  }

  void _hideLoader() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  Future<void> _submitForm() async {
    final t = AppLocalizations.of(context)!;
    if (_designationController.text.isEmpty ||
        _locationController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectGameController.text.isEmpty ||
        _sizeController.text.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _selectedImage == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.error),
          content: Text(t.organizerNewTournamentCreateError),
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
      _showLoader();
      // All required fields are filled, proceed to submit the form
      try {
        var uri = Uri.parse('${dotenv.env['API_URL']}tournaments');
        String? token = await storage.read(key: 'jwt_token');
        String? userID = await storage.read(key: 'user_id');

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
        request.fields['organizer_id'] = '$userID';
        request.fields['game_id'] = _selectedGameId.toString();
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
              title: Text(t.organizerNewTournamentCreateSuccessTitle),
              content: Text(t.organizerNewTournamentCreateSuccess),
              actions: [
                TextButton(
                  onPressed: () {
                    _hideLoader();
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
