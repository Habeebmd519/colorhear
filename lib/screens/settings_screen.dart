import 'package:colorhear/servises/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:colorhear/main.dart';
import 'package:colorhear/utils/theme_notifier.dart';

// final themeNotifier = ThemeNotifier();

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool ttsEnabled = true;
  bool isDarkMode = false;
  double speechRate = 0.5;

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
      speechRate = prefs.getDouble('speechRate') ?? 0.5;

    });
  }

  Future<void> _updateBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
    // await prefs.setDouble('speechRate', value); // For sliders


  }
  Future<void> _updateDoubleSetting(String key, double value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setDouble(key, value);
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
              _updateBoolSetting('ttsEnabled', val);
            },
          ),
          Text("Speech Speed"),
Slider(
  min: 0.1,
  max: 1.0,
  divisions: 9,
  value: speechRate,
  label: speechRate.toStringAsFixed(1),
  onChanged: (val) {
    setState(() => speechRate = val);
    _updateDoubleSetting('speechRate', val);
    TTSService.setSpeechRate(val);
  },
),

          SwitchListTile(
            title: Text("Dark Mode"),
            value: isDarkMode,
            onChanged: (val) {
              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
              setState(() => isDarkMode = val);

              _updateBoolSetting('isDarkMode', val);

              // isDarkModeNotifier.value = val;
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
