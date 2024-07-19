import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class FeatureService {
  final Map<String, bool> _cache = {};

  FeatureService();

  Future<bool> isFeatureEnabled(String feature) async {
    if (_cache.containsKey(feature)) {
      return _cache[feature]!;
    }

    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}feature/$feature'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final isEnabled = data[feature] as bool;
        _cache[feature] = isEnabled;
        return isEnabled;
      } else if (response.statusCode == 404) {
        _cache[feature] = false;
        return false;
      } else {
        throw Exception('Failed to load feature status');
      }
    } catch (e) {
      print('Error fetching feature status: $e');
      return false;
    }
  }

  Future<void> setFeatureEnabled(String feature, bool enabled) async {
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}feature/$feature'),
        headers: {'Content-Type': 'application/json'},
        body: enabled.toString(),
      );

      if (response.statusCode == 204) {
        _cache[feature] = enabled;
      } else {
        throw Exception('Failed to set feature status');
      }
    } catch (e) {
      print('Error setting feature status: $e');
    }
  }

  Future<Map<String, bool>> getAllFeatures() async {
    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}feature'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        final features = data.fold<Map<String, bool>>({}, (acc, feature) {
          acc[feature['name']] = feature['enabled'];
          return acc;
        });
        _cache.addAll(features);
        return features;
      } else {
        throw Exception('Failed to load features');
      }
    } catch (e) {
      print('Error fetching features: $e');
      return {}; // Return an empty map if an error occurs
    }
  }
}
