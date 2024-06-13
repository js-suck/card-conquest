import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:front/services/user_service.dart';

class TopAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TopAppBar({
    super.key,
    required this.title,
    this.isAvatar = true,
    this.isPage = true,
    this.isSettings = false,
  });

  final String title;
  final bool isAvatar;
  final bool isPage;
  final bool isSettings;

  @override
  _TopAppBarState createState() => _TopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _TopAppBarState extends State<TopAppBar> {
  String userName = '';
  String userRole = '';
  String? userImage;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    // Récupérer le token depuis le stockage sécurisé
    String? token = await _storage.read(key: 'jwt_token');

    if (token == null || JwtDecoder.isExpired(token)) {
      // Gérer le cas où le token est manquant ou expiré
      return;
    }

    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    int userId = decodedToken['user_id'];
    String name = decodedToken['name'];
    String role = decodedToken['role'];

    // Récupérer les détails de l'utilisateur à partir de l'API
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final user = await userService.getUser(userId);
      final image = await userService.getUserImage(userId);
      setState(() {
        userName = user['name'] ?? name;
        userRole = user['role'] ?? role;
        userImage = image;
      });
    } catch (e) {
      setState(() {
        userName = name;
        userRole = role;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(30),
        bottomRight: Radius.circular(30),
      ),
      child: AppBar(
        toolbarHeight: kToolbarHeight + 20,
        title: Builder(builder: (context) {
          if (widget.isPage) {
            return Text(
              widget.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            );
          } else {
            return const Text('');
          }
        }),
        centerTitle: true,
        actions: [
          Builder(builder: (context) {
            if (!widget.isPage) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  color: Colors.white,
                ),
                child: Badge.count(
                  count: 0,
                  child: IconButton(
                    icon: const Icon(Icons.notifications),
                    color: Colors.black,
                    onPressed: () {},
                  ),
                ),
              );
            } else if (!widget.isSettings) {
              return IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              );
            } else {
              return const Text('');
            }
          })
        ],
        leadingWidth: widget.isPage ? 64 : 1000,
        leading: Builder(builder: (context) {
          if (widget.isAvatar) {
            return Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/profile');
                    },
                    child: CircleAvatar(
                      radius: 30,
                      backgroundImage: userImage != null
                          ? NetworkImage(userImage!)
                          : const AssetImage('assets/images/avatar.png') as ImageProvider,
                    ),
                  ),
                ),
                if (!widget.isPage)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            )),
                        Text(userRole,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            )),
                      ],
                    ),
                  ),
              ],
            );
          } else {
            return IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            );
          }
        }),
      ),
    );
  }
}
