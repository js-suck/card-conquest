import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:front/extension/theme_extension.dart';
import 'package:front/generated/match.pb.dart' as tournament;
import 'package:front/service/match_service.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Summary extends StatefulWidget {
  const Summary({super.key, required this.match});

  final tournament.MatchResponse match;

  @override
  State<Summary> createState() => _SummaryState();
}

class _SummaryState extends State<Summary> {
  late MatchService matchService;

  @override
  void initState() {
    super.initState();
    matchService = MatchService();
    matchService.fetchMatch(widget.match.matchId);
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
                child: Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(MdiIcons.mapMarker, color: Colors.white),
                        Expanded(
                            child: Text('${t.summaryLocation} :',
                                style: const TextStyle(color: Colors.white))),
                        match.location != ''
                            ? Text(match.location,
                                style: const TextStyle(color: Colors.white))
                            : Text(t.summaryNoLocation,
                                style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const Row(
                    children: [],
                  )
                ]),
              )
            ],
          );
        });
  }
}
