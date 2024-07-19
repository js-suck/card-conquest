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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.guildName,
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: t.guildName,
                    hintStyle: TextStyle(color: const Color(0xFF888888).withOpacity(0.5)),
                    fillColor: Colors.grey[100],
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.guildNameRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text(
                  t.guildDescription,
                  style: const TextStyle(fontSize: 18.0),
                ),
                const SizedBox(height: 8.0),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: t.guildDescription,
                    hintStyle: TextStyle(color: const Color(0xFF888888).withOpacity(0.5)),
                    fillColor: Colors.grey[100],
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return t.guildDescriptionRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
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
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFFFF933D),
                    minimumSize: const Size(double.infinity, 45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    t.update,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
