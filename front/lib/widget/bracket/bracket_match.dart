import 'package:flutter/material.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/tournament.pb.dart' as tournament;
import 'package:front/widget/expandable_fab.dart';
import 'package:front/service/match_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BracketMatch extends StatefulWidget {
  const BracketMatch({super.key, required this.match});

  final tournament.Match match;

  @override
  _BracketMatchState createState() => _BracketMatchState();
}

class _BracketMatchState extends State<BracketMatch> {
  late MatchService matchService;
  bool isEditing = false;
  late TextEditingController _timeController;
  final storage = const FlutterSecureStorage();
  Map<String, dynamic>? decodedToken;

  @override
  void initState() {
    super.initState();
    _timeController = TextEditingController();
    _timeController.text = _formatTime(widget.match.startTime);
    matchService = MatchService();
    _loadToken();
  }

  String _formatTime(String? startTime) {
    if (startTime == null || startTime.isEmpty) {
      return '00:00';
    }
    try {
      final dateTime = DateTime.parse(startTime);
      final formattedTime = DateFormat('HH:mm').format(dateTime);
      return formattedTime;
    } catch (e) {
      print('Error parsing startTime: $e');
      return '00:00';
    }
  }

  String formatTimeInput(String input) {
    String formattedInput = input.replaceAll(RegExp(r'\D'), '');

    if (formattedInput.length > 4) {
      formattedInput = formattedInput.substring(0, 4);
    }

    if (formattedInput.length >= 3) {
      formattedInput =
          '${formattedInput.substring(0, 2)}:${formattedInput.substring(2, formattedInput.length)}';
    }

    return formattedInput;
  }

  bool validateTime(String input) {
    if (input.length != 5 || input[2] != ':') {
      return false;
    }

    int hours = int.parse(input.substring(0, 2));
    int minutes = int.parse(input.substring(3, 5));

    return hours >= 0 && hours <= 23 && minutes >= 0 && minutes <= 59;
  }

  Future<void> _loadToken() async {
    String? token = await storage.read(key: 'jwt_token');
    if (token != null) {
      try {
        decodedToken = JwtDecoder.decode(token!);
      } catch (e) {
        print('Invalid token: $e');
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _timeController.dispose();
    super.dispose();
  }

  bool isAdmin(Map<String, dynamic> decodedToken) {
    return decodedToken['role'] == 'organizer';
  }

  Future<void> _editHourBracketMatch(int matchId) async {
    final t = AppLocalizations.of(context)!;
    if (isEditing) {
      final newTimeMatch = _timeController.text;

      if (newTimeMatch.isNotEmpty) {
        if (validateTime(newTimeMatch)) {
          await matchService.updateTimeMatch(context, widget.match.matchId,
              widget.match.startTime, newTimeMatch);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.errorHourFormat),
            ),
          );
          return;
        }
      }
    }

    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    String playerOneUsername = widget.match.playerOne.username;
    String playerTwoUsername = widget.match.playerTwo.username;
    String playerOneScore = widget.match.playerOne.score.toString();
    String playerTwoScore = widget.match.playerTwo.score.toString();
    Color playerOneColor = context.themeColors.invertedBackgroundColor;
    Color playerTwoColor = context.themeColors.invertedBackgroundColor;
    Color matchBorderColor = context.themeColors.backgroundColor;
    Color playerOneScoreColor = context.themeColors.fontColor;
    Color playerTwoScoreColor = context.themeColors.fontColor;
    FontWeight playerOneFontWeight = FontWeight.normal;
    FontWeight playerTwoFontWeight = FontWeight.normal;
    if (widget.match.status != '') {
      if (widget.match.status == 'started') {
        playerOneColor = Colors.redAccent;
        playerTwoColor = Colors.redAccent;
        matchBorderColor = Colors.redAccent;
      }
      if (widget.match.status == 'finished') {
        if (widget.match.winnerId.toString() == widget.match.playerOne.userId) {
          playerOneFontWeight = FontWeight.bold;
          playerOneScoreColor = Colors.green;
          playerTwoScoreColor = Colors.red;
        } else {
          playerTwoFontWeight = FontWeight.bold;
          playerTwoScoreColor = Colors.green;
          playerOneScoreColor = Colors.red;
        }
      }
      if (widget.match.playerOne.username == '') {
        playerOneUsername = 'Bye';
        playerOneColor = Colors.grey;
        playerOneScore = '';
        playerTwoScore = '';
      }
      if (widget.match.playerTwo.username == '') {
        playerTwoUsername = 'Bye';
        playerTwoColor = Colors.grey;
        playerTwoScore = '';
        playerOneScore = '';
      }
    }
    return GestureDetector(
      onTap: () {
        if (widget.match.status != '' &&
            widget.match.playerOne.username != '' &&
            widget.match.playerTwo.username != '') {
          Navigator.pushNamed(context, '/match',
              arguments: widget.match.matchId);
        } else {
          final t = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                t.noMatch,
              ),
            ),
          );
        }
      },
      child: Column(
        children: [
          Container(
            width: 225,
            decoration: BoxDecoration(
              color: context.themeColors.secondaryBackgroundAccentColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
              border: Border.fromBorderSide(
                BorderSide(
                  color: matchBorderColor,
                  width: 1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerOneUsername,
                        style: TextStyle(
                          fontWeight: playerOneFontWeight,
                          color: playerOneColor,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        playerTwoUsername,
                        style: TextStyle(
                          fontWeight: playerTwoFontWeight,
                          color: playerTwoColor,
                        ),
                      ),
                    ],
                  ),
                  Builder(
                    builder: (context) {
                      if (widget.match.status == 'finished') {
                        return Column(
                          children: [
                            Text(
                              playerOneScore,
                              style: TextStyle(color: playerOneScoreColor),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              playerTwoScore,
                              style: TextStyle(color: playerTwoScoreColor),
                            ),
                          ],
                        );
                      } else if (widget.match.status == 'started') {
                        return Column(
                          children: [
                            Text(
                              playerOneScore,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(playerTwoScore,
                                style:
                                    const TextStyle(color: Colors.redAccent)),
                          ],
                        );
                      } else {
                        return isEditing
                            ? Container(
                                width: 50,
                                child: TextField(
                                  controller: _timeController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    String formatted = formatTimeInput(value);
                                    _timeController.value =
                                        _timeController.value.copyWith(
                                      text: formatted,
                                      selection: TextSelection.collapsed(
                                          offset: formatted.length),
                                    );
                                  },
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : widget.match.status == 'created'
                                ? Text(
                                    _timeController.text,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: context
                                          .themeColors.invertedBackgroundColor,
                                    ),
                                  )
                                : Container();
                      }
                    },
                  ),
                  _buildAdminButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminButton() {
    if (decodedToken != null &&
        isAdmin(decodedToken!) &&
        widget.match.status == 'created') {
      int matchId = widget.match.matchId;
      return IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _editHourBracketMatch(matchId),
        tooltip: "Mode d'édition",
      );
    } else {
      return Container();
    }
  }
}
