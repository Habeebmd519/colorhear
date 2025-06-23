import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:colorhear/screens/detecting_from_media_screen.dart';
import 'package:colorhear/services/authentication_service.dart';

import 'package:colorhear/services/colorN.dart';
import 'package:colorhear/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;
import 'package:image_picker/image_picker.dart';

class ColorDetectionApp extends StatefulWidget {
  final CameraDescription camera;

  const ColorDetectionApp({Key? key, required this.camera}) : super(key: key);

  @override
  State<ColorDetectionApp> createState() => _ColorDetectionAppState();
}

class _ColorDetectionAppState extends State<ColorDetectionApp> {
  bool isLoading = false;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  String detectedColorName = "Unknown";
  int red = 0, green = 0, blue = 0;

  final ColorN colorHelper = ColorN();

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.camera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  Color getDarkerColor(Color mainColor) {
    const double darkenFactor = 0.3;

    int red = (mainColor.red * (3 - darkenFactor)).round().clamp(0, 255);
    int green = (mainColor.green * (3 - darkenFactor)).round().clamp(0, 255);
    int blue = (mainColor.blue * (3 - darkenFactor)).round().clamp(0, 255);

    return Color.fromARGB(mainColor.alpha, red, green, blue);
  }

  Future<void> uploadFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        isLoading = true;
      });
      final file = File(picked.path);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (ctx) => PixelDetecterScreen(image: file)),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  double getColorPosition(int r, int g, int b) {
    final hsv = HSVColor.fromColor(Color.fromARGB(255, r, g, b));
    final hue = hsv.hue; // 0 to 360
    final barWidth =
        MediaQuery.of(context).size.width - 40; // padding 20 on both sides
    return (hue / 360.0) * barWidth;
  }

  Future<void> captureAndDetectColor() async {
    try {
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final bytes = await File(image.path).readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        setState(() {
          detectedColorName = "Error decoding image";
        });
        return;
      }

      int centerX = decodedImage.width ~/ 2;
      int centerY = decodedImage.height ~/ 2;
      var pixel = decodedImage.getPixel(centerX, centerY);

      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();

      String colorName = colorHelper.getClosestColorName(r, g, b);

      setState(() {
        red = r;
        green = g;
        blue = b;
        detectedColorName = colorName;
      });

      //  await flutterTts.speak(colorName);
      await TTSService.speak(colorName);
      // change place
    } catch (e) {
      print("Error: $e");
      setState(() {
        detectedColorName = "Error: $e";
      });
    }
  }

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'logout':
        _logout(context);
        break;
    }
  }

  void _logout(BuildContext context) async {
    setState(() => isLoading = true);
    try {
      await AuthenticationService.logout();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('LogOut Failed: $e')));
      print(e);
    }
    setState(() => isLoading = false);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Logged out')));
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/WelcomeScreen',
        (Route<dynamic> route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    Color mainColor = Color.fromARGB(255, red, green, blue);
    Color complementaryColor = getDarkerColor(mainColor);
    return Scaffold(
      appBar: AppBar(
        actions: [
          SizedBox(width: 2),
          CircleAvatar(
            radius: 20,
            backgroundColor: const Color.fromARGB(49, 0, 0, 0),
            child: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuSelection(value, context),
              icon: Icon(Icons.more_vert, color: Colors.white),
              itemBuilder:
                  (BuildContext context) => [
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Text('Logout'),
                    ),
                  ],
            ),
          ),
          SizedBox(width: 2),
        ],
        leading: Icon(null),
        centerTitle: true,
        title: const Text("Colourhear", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, red, green, blue),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [mainColor, complementaryColor],
          ),
        ),
        child: Column(
          children: [
            if (isLoading)
              CircularProgressIndicator()
            else ...[
              Expanded(
                flex: 4,
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          CameraPreview(_controller),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 2,
                                height: 2,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  width: double.infinity,
                  color: const Color.fromARGB(75, 0, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Text(
                          detectedColorName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // const SizedBox(width: 15),
                          Text(
                            "R: $red  ",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "G: $green  ",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "B: $blue",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),

                      Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          Container(
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: const LinearGradient(
                                colors: [
                                  Colors.red,
                                  Colors.yellow,
                                  Colors.green,
                                  Colors.cyan,
                                  Colors.blue,
                                  Colors.purple,
                                  Colors.red,
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: getColorPosition(red, green, blue),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                color: Color.fromARGB(255, red, green, blue),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 12,
                  bottom: 12,
                  left: 22,
                  right: 22,
                ),
                child: ElevatedButton.icon(
                  onPressed: captureAndDetectColor,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text(
                    "Capture & Detect Color",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: Color.fromARGB(255, red, green, blue),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      // color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: Transform.translate(
        offset: Offset(0, 30),
        child: FloatingActionButton(
          backgroundColor: Color.fromARGB(255, red, green, blue),
          onPressed: () {
            uploadFromGallery();
          },
          child: Icon(Icons.upload_file, color: Colors.white),
        ),
      ),
    );
  }
}
