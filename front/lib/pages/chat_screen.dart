import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:grpc/grpc.dart';
import '../generated/chat.pb.dart';
import './../generated/chat.pbgrpc.dart' as chat_grpc;
import 'package:flutter/widgets.dart' as flutter_widgets;
import 'package:http/http.dart' as http;

class ChatClient {
  late ClientChannel channel;
  late chat_grpc.ChatServiceClient stub;

  ChatClient() {
    channel = ClientChannel(
      '${dotenv.env['API_IP']}',
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );
    stub = chat_grpc.ChatServiceClient(channel);
  }

  ResponseStream<chat_grpc.ChatHistoryMessage> subscribeChatUpdates(int guild) {
    var request = chat_grpc.JoinRequest(guildId: guild);
    return stub.join(request);
  }

  Future<chat_grpc.HistoryResponse> getChatHistory(int guild) async {
    var request = chat_grpc.HistoryRequest(guildId: guild);
    return await stub.getChatHistory(request);
  }

  void sendMessage(String message, int guild, String username, int userId) {
    var chatMessage = chat_grpc.ChatMessage(
        guildId: guild, content: message, username: username, userId: userId);
    stub.sendMessage(chatMessage);
  }

  void shutdown() async {
    await channel.shutdown();
  }
}

class ChatClientScreen extends StatefulWidget {
  final int guildId;
  final String username;
  final int userId;
  final String mediaUrl;

  const ChatClientScreen({
    super.key,
    required this.guildId,
    required this.username,
    required this.userId,
    required this.mediaUrl,
  });

  @override
  _ChatClientScreenState createState() => _ChatClientScreenState();
}

class _ChatClientScreenState extends State<ChatClientScreen> {
  late ChatClient chatClient;
  List<chat_grpc.ChatHistoryMessage> chatMessages = [];
  late TextEditingController _messageController;
  String guildName = '';

  @override
  void initState() {
    super.initState();
    chatClient = ChatClient();
    _messageController = TextEditingController();
    _initializeChat();
  }

  void _initializeChat() async {
    final history = await chatClient.getChatHistory(widget.guildId);
    final guildData = await fetchGuildData(widget.guildId.toString());
    setState(() {
      chatMessages = history.messages;
      guildName = guildData['name'];
    });
    _listenForUpdates();
  }

  void _listenForUpdates() {
    chatClient.subscribeChatUpdates(widget.guildId).listen((message) {
      setState(() {
        chatMessages.add(message);
      });
    });
  }

  Future<Map<String, dynamic>> fetchGuildData(String guildId) async {
    const storage = FlutterSecureStorage();
    String? token = await storage.read(key: 'jwt_token');
    final response = await http.get(
      Uri.parse('${dotenv.env['API_URL']}guilds/$guildId'),
      headers: {
        HttpHeaders.authorizationHeader: '$token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load guild data');
    }
  }

  @override
  void dispose() {
    chatClient.shutdown();
    _messageController.dispose();
    super.dispose();
  }

  Widget buildAvatar(String mediaUrl) {
    return Stack(
      children: <Widget>[
        CircleAvatar(
          backgroundImage: NetworkImage(mediaUrl),
        ),
        const Positioned(
          right: 0,
          bottom: 0,
          child: Icon(Icons.brightness_1, size: 12.0, color: Colors.green),
        ),
      ],
    );
  }

  Widget buildMessage(chat_grpc.ChatHistoryMessage message, bool isCurrentUser) {
    print("message user mediaUrl: ${message.user}");
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCurrentUser) buildAvatar("${dotenv.env['API_URL']}images/"+message.user.mediaUrl),
            Container(
              padding: const EdgeInsets.all(10.0),
              width: MediaQuery.of(context).size.width * 0.5,
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
              decoration: BoxDecoration(
                color: isCurrentUser ? Colors.deepOrange : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.user.username,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    message.content,
                    style: TextStyle(
                      color: isCurrentUser ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            if (isCurrentUser) buildAvatar("${dotenv.env['API_URL']}images/"+message.user.mediaUrl),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(guildName),
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: chatMessages.length,
                  itemBuilder: (context, index) {
                    var chatMessage = chatMessages[index];
                    bool isCurrentUser = widget.userId == chatMessage.user.id;
                    return buildMessage(chatMessage, isCurrentUser);
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final message = _messageController.text;
                      if (message.isNotEmpty) {
                        chatClient.sendMessage(
                          message,
                          widget.guildId,
                          widget.username,
                          widget.userId,
                        );
                        _messageController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
