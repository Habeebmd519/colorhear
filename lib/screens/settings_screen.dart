import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:colorhear/main.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool ttsEnabled = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      ttsEnabled = prefs.getBool('ttsEnabled') ?? true;
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _updateSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.deepPurple[50],
      appBar: AppBar(
        title: Text("Settings"),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: EdgeInsets.all(24),
        children: [
          Center(
            child: Lottie.asset(
              'assets/animations/settings.json',
              height: 150,
            ),
          ),
          SwitchListTile(
            title: Text("Enable Text-to-Speech"),
            value: ttsEnabled,
            onChanged: (val) {
              setState(() => ttsEnabled = val);
              _updateSetting('ttsEnabled', val);
            },
          ),
          SwitchListTile(
            title: Text("Dark Mode"),
            value: isDarkMode,
            onChanged: (val) {
              setState(() => isDarkMode = val);
              _updateSetting('isDarkMode', val);
              isDarkModeNotifier.value = val;
              // Optional: apply dark mode app-wide
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text("About App"),
            subtitle: Text("Color detection app for color-blind users."),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text("Credits"),
            subtitle: Text("Developed by [Your Name]."),
          ),
        ],
      ),
    );
  }
}
