import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';

import 'firebase_options.dart';
import 'Blocs/AuthBloc/auth_bloc.dart';
import 'Blocs/AuthBloc/auth_event.dart';
import 'Blocs/AuthBloc/auth_state.dart';

import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/detecting_from_camera_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';

late final CameraDescription firstCamera;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _safeFirebaseInit();

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
    firstCamera = cameras.first;
  } catch (e) {
    print('Camera initialization failed: $e');
  }

  runApp(
    BlocProvider(create: (_) => AuthBloc()..add(AppStarted()), child: MyApp()),
  );
}

Future<void> _safeFirebaseInit() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      print('Firebase already initialized, skipping re-init.');
    } else {
      rethrow;
    }
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ColorHear',
      home: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthAuthenticated) {
            return SplashScreen(isLoggedIn: true);
          } else if (state is AuthUnauthenticated) {
            return SplashScreen(isLoggedIn: false);
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
      // initialRoute: ,
      routes: {
        '/WelcomeScreen': (context) => WelcomeScreen(),
        '/colorDetect': (context) => ColorDetectionApp(camera: firstCamera),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
      },
    );
  }
}
