import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:front/models/flag.dart';
import 'package:front/services/api_service.dart';
import 'package:front/feature_config_service.dart';

class CrudFlagScreen extends StatefulWidget {
  const CrudFlagScreen({Key? key}) : super(key: key);

  @override
  _CrudFlagScreenState createState() => _CrudFlagScreenState();
}

class _CrudFlagScreenState extends State<CrudFlagScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  late ApiService apiService;
  late FeatureService featureService;
  late bool isEnabled;
  late String flagName;
  List<Flag> flags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
    featureService = FeatureService();
  }

  Future<void> _initialize() async {
    String? token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      apiService = ApiService('${dotenv.env['API_URL']}', token);
      await _fetchFlag();
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchFlag() async {
    try {
      final data = await apiService.get('feature');
      setState(() {
        flags = data.map<Flag>((json) => Flag.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Feature'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: flags.length,
              itemBuilder: (context, index) {
                final flag = flags[index];
                return ListTile(
                  title: Text(flag.name),
                  trailing: SizedBox(
                    width: 100,
                    child: Switch(
                      value: flag.enabled,
                      onChanged: (bool value) {
                        setState(() {
                          flag.enabled = value;
                        });
                        featureService.setFeatureEnabled(
                            flagName = flag.name, isEnabled = flag.enabled);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
