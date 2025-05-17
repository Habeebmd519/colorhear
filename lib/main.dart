import 'package:colorhear/servises/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:colorhear/screens/welcome_screen.dart';
import 'package:colorhear/screens/color_detect_screen.dart';
import 'package:colorhear/screens/settings_screen.dart';
import 'package:colorhear/screens/how_to_use_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colorhear/utils/theme_notifier.dart';

final themeNotifier = ThemeNotifier();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TTSService.initTTS();
  runApp(ColorHearApp());
}

class ColorHearApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Roboto',
            primaryColor: Colors.deepPurple,
            scaffoldBackgroundColor: Colors.deepPurple[50],
            appBarTheme: AppBarTheme(color: Colors.deepPurple),
            brightness:
                Brightness.light, // Optional, to make it explicitly light theme
          ),

          darkTheme: ThemeData.dark(),
          themeMode: themeMode,

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
            begin: Offset(1, 0),
            end: Offset.zero,
          ).animate(anim),
          child: child,
        ),
      );
    },
  );
}
