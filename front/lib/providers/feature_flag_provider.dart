import 'package:flutter/foundation.dart';

import '../feature_config_service.dart';

class FeatureNotifier extends ChangeNotifier {
  final FeatureService _featureService;
   Map<String, bool> _features = {};


  FeatureNotifier(this._featureService, Map<String, bool> allFeatures)
      : _features = allFeatures;

  init() async {
    for (final feature in _features.keys) {
      await loadFeature(feature);
    }
  }

  bool isFeatureEnabled(String feature) {
    print("Checking feature: $feature");

    print("Feature: $feature is enabled: ${_features[feature]}");
    return _features[feature] ?? false;
  }

  Future<void> loadFeature(String feature) async {
    print("Loading feature: $feature");
    final isEnabled = await _featureService.isFeatureEnabled(feature);
    print("Feature $feature is enabled: $isEnabled");
    _features[feature] = isEnabled;
    notifyListeners();
  }

  Future<void> toggleFeature(String feature) async {
    final currentStatus = _features[feature] ?? false;
    await _featureService.setFeatureEnabled(feature, !currentStatus);
    _features[feature] = !currentStatus;
    notifyListeners();
  }

  Map<String, bool> getAllFeatures() {
    return _features;
  }

  void setAllFeatures(Map<String, bool> features) {
    _features.addAll(features);
    notifyListeners();
  }
}
