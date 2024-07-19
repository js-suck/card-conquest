import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:front/main.dart';
import 'package:front/widget/app_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:front/widget/expandable_fab.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl/intl.dart';
import 'package:front/pages/bracket_screen.dart';
import 'package:front/service/tournament_service.dart';
import 'package:front/models/match/tournament.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrganizerManagePage extends StatefulWidget {
  final int tournamentId;

  OrganizerManagePage({required this.tournamentId});

  @override
  _OrganizerManagePageState createState() => _OrganizerManagePageState();
}

class _OrganizerManagePageState extends State<OrganizerManagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late TournamentService tournamentService;
  final storage = const FlutterSecureStorage();

  bool _loading = true;
  Tournament? _tournament;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();

  double? latitude;
  double? longitude;
  File? _selectedImage;
  DateTime? _startDate;
  DateTime? _endDate;

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

  String _formatDateForDisplay(DateTime? date) {
    if (date == null) {
      return '';
    }
    return DateFormat('dd-MM-yyyy').format(date);
  }

  String _formatDateForBackend(DateTime? date) {
    if (date == null) {
      return '';
    }
    return '${DateFormat('yyyy-MM-ddTHH:mm:ss').format(date.toUtc())}Z';
  }

  @override
  void initState() {
    super.initState();
    tournamentService = TournamentService();
    tournamentService.fetchTournament(widget.tournamentId);
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final tournament =
          await tournamentService.fetchTournament(widget.tournamentId);
      setState(() {
        _nameController.text = tournament.name;
        _locationController.text = tournament.location ?? '';
        _descriptionController.text = tournament.description ?? '';
        _startDateController.text = tournament.startDate != null
            ? _formatDateForDisplay(tournament.startDate)
            : '';
        _endDateController.text = tournament.endDate != null
            ? _formatDateForDisplay(tournament.endDate)
            : '';
        latitude = tournament.latitude;
        longitude = tournament.longitude;
        _tournament = tournament;
        _loading = false;
      });
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

  Future<void> updateTournament(Tournament tournament) async {
    final t = AppLocalizations.of(context)!;
    _showLoader();
    String? token = await storage.read(key: 'jwt_token');

    var uri = Uri.parse('${dotenv.env['API_URL']}tournaments/${tournament.id}');
    var request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = '$token';

    request.fields['name'] = _nameController.text;
    request.fields['description'] = _descriptionController.text;
    request.fields['location'] = _locationController.text;
    request.fields['latitude'] = latitude.toString();
    request.fields['longitude'] = longitude.toString();

    if (_startDate != null) {
      request.fields['start_date'] = _formatDateForBackend(_startDate!);
    }

    if (_endDate != null) {
      request.fields['end_date'] = _formatDateForBackend(_endDate!);
    }

    if (_selectedImage != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'image', // le nom du champ de formulaire pour l'image
        _selectedImage!.path,
      ));
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      _hideLoader();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.organizerManageTournamentUpdateSuccess)),
      );
    } else {
      _hideLoader();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${t.organizerManageTournamentUpdateError} ${response.reasonPhrase}')),
      );
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _startTournament() async {
    final t = AppLocalizations.of(context)!;
    String? token = await storage.read(key: 'jwt_token');
    int tournamentId = widget.tournamentId;

    final response = await http.post(
      Uri.parse('${dotenv.env['API_URL']}tournaments/$tournamentId/start'),
      headers: {
        'Authorization': '$token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.organizerManageTournamentStarted)),
      );
      setState(() {
        _tournament?.status = 'started';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${t.organizerManageTournamentStartedError} ${response.body}')),
      );
    }
  }

  Future<void> _finishTournament(int tournamentID) async {
    final t = AppLocalizations.of(context)!;
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.put(
      Uri.parse('${dotenv.env['API_URL']}tournaments/$tournamentID'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': '$token',
      },
      body: jsonEncode({
        'status': 'finished',
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.organizerManageTournamentFinished)),
      );
      setState(() {
        _tournament?.status = 'finished';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${t.organizerManageTournamentFinishedError} ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    String? status = _tournament?.status;

    return Scaffold(
      appBar: TopAppBar(
        title: t.organizerManageTournament,
        roundedCorners: false,
      ),
      body: Builder(
        builder: (context) {
          if (_loading) {
            return const Center(child: CircularProgressIndicator());
            // } else if (snapshot.hasError) {
            //   return Center(child: Text('Erreur: ${snapshot.error}'));
          } else {
            return Column(
              children: [
                Container(
                  color: Theme.of(context).primaryColor,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Theme.of(context).tabBarTheme.labelColor,
                    unselectedLabelColor:
                        Theme.of(context).tabBarTheme.unselectedLabelColor,
                    indicatorColor:
                        Theme.of(context).tabBarTheme.indicatorColor,
                    tabs: const [
                      Tab(icon: Icon(Icons.account_tree)),
                      Tab(icon: Icon(Icons.edit)),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      (_tournament == null ||
                              _tournament?.players.isEmpty == true)
                          ? Center(
                              child: Text(t.organizerManageNoPlayers),
                            )
                          : ListView.builder(
                              itemCount: _tournament!.players.length,
                              itemBuilder: (context, index) {
                                final player = _tournament!.players[index];
                                print(player.media?.fileName);
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(player
                                                .media?.fileName ==
                                            ''
                                        ? 'https://avatar.iran.liara.run/public/${player.id}'
                                        : '${dotenv.env['MEDIA_URL']}${player.media?.fileName}'),
                                  ),
                                  title: Text(player.username),
                                  subtitle: Text(player.email ?? ''),
                                );
                              },
                            ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          children: [
                            Text(
                              t.organizerNewTournamentName,
                              style: TextStyle(fontSize: 18.0),
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
                                controller: _nameController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  border: InputBorder.none,
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
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    border: InputBorder.none,
                                    labelText:
                                        t.organizerNewTournamentAddressHint,
                                  ),
                                  onTap: () async {
                                    try {
                                      String? apiKey =
                                          dotenv.env['GOOGLE_API_KEY'];
                                      if (apiKey == null) {
                                        throw Exception(
                                            "API Key is not set in the environment variables");
                                      }

                                      Prediction? p =
                                          await PlacesAutocomplete.show(
                                        context: context,
                                        apiKey: apiKey,
                                        types: ["geocode"],
                                        mode: Mode.overlay,
                                        language: "fr",
                                        components: [
                                          Component(Component.country, "fr")
                                        ],
                                        strictbounds: false,
                                      );

                                      if (p != null) {
                                        GoogleMapsPlaces _places =
                                            GoogleMapsPlaces(apiKey: apiKey);
                                        PlacesDetailsResponse detail =
                                            await _places.getDetailsByPlaceId(
                                                p.placeId!);

                                        setState(() {
                                          _locationController.text =
                                              p.description!;
                                          latitude = detail
                                              .result.geometry!.location.lat;
                                          longitude = detail
                                              .result.geometry!.location.lng;
                                          print(
                                              'Inside setState: $_locationController.text');
                                        });
                                        print(_locationController.text);
                                        // Perte de focus pour forcer la mise à jour visuelle
                                      }
                                    } catch (e) {
                                      print("Error occurred: $e");
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text('${t.error} $e'),
                                        ),
                                      );
                                    }
                                  },
                                )),
                            const SizedBox(height: 20),
                            Text(
                              t.organizerNewTournamentDescription,
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
                                controller: _descriptionController,
                                keyboardType: TextInputType.text,
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  border: InputBorder.none,
                                ),
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
                                child: TextField(
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
                                child: TextField(
                                  controller: _endDateController,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: _pickImageFromGallery,
                              child: DottedBorder(
                                color: Colors.grey,
                                strokeWidth: 1,
                                dashPattern: const [5, 5],
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  color: context.themeColors.backgroundColor,
                                  child: _selectedImage != null
                                      ? Image.file(
                                          _selectedImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : const Center(
                                          child: Icon(
                                            Icons.image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () {
                                if (_tournament != null) {
                                  updateTournament(_tournament!);
                                }
                              },
                              child: Text(t.organizerManageUpdate),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          // } else {
          //   return const Center(child: Text('Aucun tournoi trouvé'));
          // }
        },
      ),
      floatingActionButton: _tournament?.players.isEmpty == false
          ? ExpandableFab(
              distance: 112.0,
              children: [
                if (status == 'opened') ...[
                  FloatingActionButton(
                    backgroundColor: context.themeColors.accentColor,
                    heroTag: "startTournament${widget.tournamentId}",
                    onPressed: _startTournament,
                    tooltip: t.organizerManageStart,
                    child: const Icon(Icons.play_arrow),
                  ),
                ] else if (status == 'started') ...[
                  FloatingActionButton(
                    backgroundColor: context.themeColors.accentColor,
                    heroTag: "finishTournament${widget.tournamentId}",
                    onPressed: () => _finishTournament(widget.tournamentId),
                    tooltip: t.organizerManageFinish,
                    child: const Icon(Icons.stop),
                  ),
                  FloatingActionButton(
                    backgroundColor: context.themeColors.accentColor,
                    heroTag: "bracket${widget.tournamentId}",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BracketPage(tournamentID: widget.tournamentId),
                        ),
                      );
                    },
                    tooltip: t.organizerManageShowBracket,
                    child: const Icon(Icons.format_list_numbered),
                  ),
                ] else if (status == 'finished') ...[
                  FloatingActionButton(
                    backgroundColor: context.themeColors.accentColor,
                    heroTag: "startTournament${widget.tournamentId}",
                    onPressed: _startTournament,
                    tooltip: t.organizerManageRestart,
                    child: const Icon(Icons.play_arrow),
                  ),
                  FloatingActionButton(
                    backgroundColor: context.themeColors.accentColor,
                    heroTag: "bracket${widget.tournamentId}",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              BracketPage(tournamentID: widget.tournamentId),
                        ),
                      );
                    },
                    tooltip: t.organizerManageShowBracket,
                    child: const Icon(Icons.format_list_numbered),
                  ),
                ],
              ],
            )
          : null,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }
}
