import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:front/models/media.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MediaService {
  final FlutterSecureStorage storage;

  MediaService({required this.storage});

  Future<Media> uploadImage(File imageFile) async {
    String? token = await storage.read(key: 'jwt_token');

    var request = http.MultipartRequest('POST', Uri.parse('${dotenv.env['API_URL']}images'));
    request.headers.addAll({
      HttpHeaders.authorizationHeader: '$token',
      HttpHeaders.contentTypeHeader: 'multipart/form-data',
    });
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    var response = await request.send();

    if (response.statusCode == 201) {
      var responseData = await response.stream.bytesToString();
      var responseBody = jsonDecode(responseData);
      return Media.fromJson(responseBody['media']);
    } else {
      throw Exception('Failed to upload image');
    }
  }
}