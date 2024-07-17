import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/utils/custom_future_builder.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';

import '../generated/chat.pb.dart';
import '../providers/user_provider.dart';
import '../service/notification_service.dart';
import '../service/user_service.dart';
import 'notification/notification_overlay.dart';

import "../models/user.dart" as userModel;

class TopAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TopAppBar({
    super.key,
    required this.title,
    this.isAvatar = true,
    this.isPage = true,
    this.isSettings = false,
    this.actions = const <Widget>[],
  });

  final String title;
  final bool isAvatar;
  final bool isPage;
  final bool isSettings;
  final List<Widget> actions;

  @override
  _TopAppBarState createState() => _TopAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _TopAppBarState extends State<TopAppBar> {
  int userId = 0;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late UserService userService;

  @override
  initState() {
    super.initState();
    userService = UserService();
    _loadUser();
  }

Future<void> _loadUser() async {
  String? token = await _storage.read(key: 'jwt_token');
  if (token == null || JwtDecoder.isExpired(token)) return;

  Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
  userModel.User user = (await userService.fetchUser(decodedToken['user_id']));
  Provider.of<UserProvider>(context, listen: false).setUser(user);

  setState(() {
    userId = decodedToken['user_id'];
  });
}

  void _showNotificationsOverlay(
      BuildContext context, List<RemoteMessage> notifications) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => NotificationsOverlay(notifications: notifications),
    );
  }

Future<void> _onNotificationButtonPressed(BuildContext context) async {
  List<RemoteMessage> notifications =
      await NotificationService().getNotifications();
  _showNotificationsOverlay(context, notifications);
  await NotificationService().resetCount();
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
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
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
            if (!widget.isPage && !kIsWeb) {
              return Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 45,
                  height: 45,
                  decoration: const BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    color: Colors.white,
                  ),
                  child: FutureBuilder<int>(
                    future: NotificationService()
                        .getNotifications()
                        .then((notifications) => notifications.length),
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text(
                            'Erreur: ${snapshot.error}');
                      } else {
                        return Badge.count(
                          count: snapshot.data ?? 0,
                          child: IconButton(
                            icon: const Icon(Icons.notifications),
                            color: Colors.black,
                            onPressed: () {
                              _onNotificationButtonPressed(context);
                            },
                          ),
                        );
                      }
                    },
                  ));
            } else if (widget.actions.isNotEmpty) {
              return widget.actions[0];
            } else if (!widget.isSettings) {
              return IconButton(
                icon: const Icon(Icons.settings),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).pushNamed('/settings');
                },
              );
            } else {
              return const SizedBox();
            }
          })
        ],
        leadingWidth: widget.isPage ? 64 : 1000,
        leading: Builder(builder: (context) {
          if (widget.isAvatar) {
            return CustomFutureBuilder(
                future: userService.fetchUser(userId, forceRefresh: true),
                onLoaded: (user) {
                  return Row(
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 4, top: 4, bottom: 4),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/profile');
                          },
                          child: CircleAvatar(
                            radius: 27,
                            child: ClipOval(
                              child: SizedBox(
                                width: 54,
                                height: 54,
                                child: user.media?.fileName != null
                                    ? CachedNetworkImage(
                                        imageUrl:
                                            '${dotenv.env['MEDIA_URL']}${user.media!.fileName}',
                                        placeholder: (context, url) =>
                                            const CircularProgressIndicator(),
                                        fit: BoxFit.cover,
                                      )
                                    : Image.asset(
                                        'assets/images/avatar.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
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
                              Text(user.username,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text(user.role ?? '',
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
                });
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
