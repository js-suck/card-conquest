import 'dart:core';

import 'package:flutter/material.dart';
import 'package:front/generated/match.pb.dart';
import 'package:front/utils/custom_future_builder.dart';

import '../../../service/match_service.dart';
import 'match_tiles.dart';

class Head2Head extends StatefulWidget {
  const Head2Head(
      {super.key,
      required this.playerOne,
      required this.playerTwo,
      required this.matchId});

  final PlayerMatch playerOne;
  final PlayerMatch playerTwo;
  final int matchId;

  @override
  State<Head2Head> createState() => _Head2HeadState();
}

class _Head2HeadState extends State<Head2Head> {
  late MatchService matchService;

  @override
  void initState() {
    super.initState();
    matchService = MatchService();
    matchService.fetchMatchesPlayerOne(widget.playerOne);
    matchService.fetchMatchesPlayerTwo(widget.playerTwo);
    matchService.fetchMatchesHead2Head(widget.playerOne, widget.playerTwo);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          CustomFutureBuilder(
              future: matchService.fetchMatchesPlayerOne(widget.playerOne),
              onLoaded: (matches) {
                return MatchTiles(
                  key: UniqueKey(),
                  matches: matches,
                  isLastMatches: true,
                  player: widget.playerOne,
                  matchId: widget.matchId,
                );
              }),
          CustomFutureBuilder(
              future: matchService.fetchMatchesPlayerTwo(widget.playerTwo),
              onLoaded: (matches) {
                return MatchTiles(
                  key: UniqueKey(),
                  matches: matches,
                  isLastMatches: true,
                  isSecond: true,
                  player: widget.playerTwo,
                  matchId: widget.matchId,
                );
              }),
          CustomFutureBuilder(
              future: matchService.fetchMatchesHead2Head(
                  widget.playerOne, widget.playerTwo),
              onLoaded: (matches) {
                return MatchTiles(
                  key: UniqueKey(),
                  matches: matches,
                  isLastMatches: false,
                  isH2H: true,
                );
              }),
        ],
      ),
    );
  }
}
