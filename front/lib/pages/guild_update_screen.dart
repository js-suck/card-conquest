import 'package:flutter/material.dart';
import 'package:front/pages/guild_screen.dart';
import 'package:provider/provider.dart';

import '../service/guild_service.dart';
import '../models/guild.dart' as guildModel;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GuildUpdateScreen extends StatefulWidget {
  final guildModel.Guild guild;

  GuildUpdateScreen({required this.guild});

  @override
  _GuildUpdateScreenState createState() => _GuildUpdateScreenState();
}

class _GuildUpdateScreenState extends State<GuildUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.guild.name);
    _descriptionController = TextEditingController(text: widget.guild.description);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.guildUpdate),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: t.guildName),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.guildNameRequired;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: t.guildDescription),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.guildDescriptionRequired;
                  }
                  return null;
                },
              ),
              Spacer( flex: 1 ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Update guild
                    GuildService().updateGuild(widget.guild.id, _nameController.text, _descriptionController.text);

                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GuildView()),
                    );
                  }
                },
                child: Text(t.update),
              ),
            ],
          ),
        ),
      ),
    );
  }
}