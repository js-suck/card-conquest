import 'package:flutter/cupertino.dart';
import 'package:front/models/guild.dart';
import 'package:front/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void updateUserGuilds(List<Guild> userGuilds) {
    _user!.guilds = userGuilds;
    notifyListeners();
  }


}