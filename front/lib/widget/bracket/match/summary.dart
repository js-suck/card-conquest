import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/match.pb.dart' as tournament;
import 'package:front/service/match_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jwt_decoder/jwt_decoder.dart';

class Summary extends StatefulWidget {
  const Summary({super.key, required this.match});

  final tournament.MatchResponse match;

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  late MatchService matchService;
  bool isEditing = false;
  bool isOrganizer = false;
  TextEditingController locationController = TextEditingController();
  final storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    matchService = MatchService();
    locationController.text = widget.match.location;
    matchService.fetchMatch(widget.match.matchId);

    storage.read(key: 'jwt_token').then((token) {
      setState(() {
        isOrganizer = matchService.isAdmin(token);
      });
    });
  }

  Future<void> _editMatchInfo() async {
    if (isEditing) {
      final location = locationController.text;
      await matchService.updateMatchInfo(
          context, widget.match.matchId, location);
    }
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return CustomFutureBuilder(
      future: matchService.fetchMatch(widget.match.matchId),
      onLoaded: (match) {
        return ListView(
          children: [
            const SizedBox(height: 2),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                t.summaryInfo,
              ),
            ),
            Container(
              color: context.themeColors.backgroundAccentColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(MdiIcons.mapMarker, color: Colors.white),
                        Expanded(
                          child: Text(
                            '${t.summaryLocation} :',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        isEditing
                            ? Expanded(
                                child: TextField(
                                  controller: locationController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: t.enterLocation,
                                    hintStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                              )
                            : isOrganizer
                                ? GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isEditing =
                                            true; // Activer le mode édition
                                      });
                                    },
                                    child: Text(
                                      match.location.isNotEmpty
                                          ? match.location
                                          : t.summaryNoLocation,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )
                                : Text(
                                    match.location.isNotEmpty
                                        ? match.location
                                        : t.summaryNoLocation,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                        if (isEditing)
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.white),
                            onPressed: _editMatchInfo,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
