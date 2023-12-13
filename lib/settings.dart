import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class MySettings extends StatefulWidget {
  const MySettings({Key? key}) : super(key: key);

  @override
  _MySettingsState createState() => _MySettingsState();
}

class _MySettingsState extends State<MySettings> {
  Future<void> clearCache() async {
    final cacheDir = await path_provider.getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg-signbuddy.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppBar(
                  title: Text(
                    'Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                  backgroundColor: const Color(0xFF5A96E3).withOpacity(0.8),
                  shape: ContinuousRectangleBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(50),
                      bottomRight: Radius.circular(50),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16),
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FiraSans',
                      color: Color.fromARGB(255, 71, 63, 63),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                FaIcon(
                                  FontAwesomeIcons.key,
                                  color: Colors.deepPurpleAccent,
                                ),
                                SizedBox(width: 15),
                                TextButton(
                                  onPressed: () {
                                    clearCache();
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Cache cleared successfully'),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Clear Cache',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 71, 63, 63),
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        _buildDivider(),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 8,
      color: Colors.deepPurpleAccent,
    );
  }
}
