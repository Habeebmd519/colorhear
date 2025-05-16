import 'package:colorhear/servises/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:colorhear/screens/welcome_screen.dart';
import 'package:colorhear/screens/color_detect_screen.dart';
import 'package:colorhear/screens/settings_screen.dart';
import 'package:colorhear/screens/how_to_use_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';



final ValueNotifier<bool> isDarkModeNotifier = ValueNotifier(false);
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  isDarkModeNotifier.value = prefs.getBool('isDarkMode') ?? false; 
  await TTSService.initTTS();
  runApp(ColorHearApp());
}

class ColorHearApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkModeNotifier,
      builder: (_, darkMode, __) {
        return MaterialApp(
          theme: darkMode ? ThemeData.dark() : ThemeData(
            primarySwatch: Colors.deepPurple,
            fontFamily: 'Roboto',
          ),
          
            initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _animatedRoute(WelcomeScreen());
          case '/colorDetect':
            return _animatedRoute(ColorDetectScreen());
          case '/settings':
            return _animatedRoute(SettingsScreen());
          case '/howToUse':
            return _animatedRoute(HowToUseScreen());
          default:
            return MaterialPageRoute(builder: (_) => WelcomeScreen());
        }
      },
        );
      },
    );
  }
}
    
  //   MaterialApp(
  //     title: 'ColorHear',
  //     debugShowCheckedModeBanner: false,
  //     theme: ThemeData(
  //       primarySwatch: Colors.deepPurple,
  //       visualDensity: VisualDensity.adaptivePlatformDensity,
  //       fontFamily: 'Roboto',
  //     ),
  //     initialRoute: '/',
  //     onGenerateRoute: (settings) {
  //       switch (settings.name) {
  //         case '/':
  //           return _animatedRoute(WelcomeScreen());
  //         case '/colorDetect':
  //           return _animatedRoute(ColorDetectScreen());
  //         case '/settings':
  //           return _animatedRoute(SettingsScreen());
  //         case '/howToUse':
  //           return _animatedRoute(HowToUseScreen());
  //         default:
  //           return MaterialPageRoute(builder: (_) => WelcomeScreen());
  //       }
  //     },
  //   );
    

  PageRouteBuilder _animatedRoute(Widget screen) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, anim, __, child) {
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: Offset(1, 0), end: Offset.zero
            ).animate(anim),
            child: child,
          ),
        );
      },
    );
  }

