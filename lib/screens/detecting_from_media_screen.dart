import 'dart:io';
import 'package:colorhear/services/authentication_service.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

import 'package:colorhear/services/colorN.dart';
import 'package:colorhear/services/tts_service.dart';

class PixelDetecterScreen extends StatefulWidget {
  final File image;

  const PixelDetecterScreen({Key? key, required this.image}) : super(key: key);

  @override
  _PixelDetecterScreenState createState() => _PixelDetecterScreenState();
}

class _PixelDetecterScreenState extends State<PixelDetecterScreen> {
  bool isLoading = true;

  int red = 0;
  int green = 0;
  int blue = 0;
  String detectedColorName = 'None';
  late img.Image decodedImage;
  final ColorN colorHelper = ColorN();

  Offset? imageTapPosition;

  final GlobalKey imageKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    try {
      final bytes = await widget.image.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        setState(() {
          detectedColorName = "Error decoding image";
          isLoading = false;
        });
        return;
      }

      decodedImage = image;
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error decoding image: $e");
      setState(() {
        detectedColorName = "Error: $e";
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

  // Color getComplementaryColor(Color color) {
  //   return Color.fromARGB(
  //     color.alpha,
  //     255 - color.red,
  //     255 - color.green,
  //     255 - color.blue,
  //   );
  // }
  Color getDarkerColor(Color mainColor) {
    const double darkenFactor = 0.3;

    int red = (mainColor.red * (3 - darkenFactor)).round().clamp(0, 255);
    int green = (mainColor.green * (3 - darkenFactor)).round().clamp(0, 255);
    int blue = (mainColor.blue * (3 - darkenFactor)).round().clamp(0, 255);

    return Color.fromARGB(mainColor.alpha, red, green, blue);
  }

  void _onTapDown(TapDownDetails details) async {
    if (decodedImage == null) return;

    final box = imageKey.currentContext!.findRenderObject() as RenderBox;
    final localPosition = details.localPosition;

    final widgetWidth = box.size.width;
    final widgetHeight = box.size.height;

    final imageWidth = decodedImage.width;
    final imageHeight = decodedImage.height;

    // Calculate aspect ratio fit
    final widgetAspect = widgetWidth / widgetHeight;
    final imageAspect = imageWidth / imageHeight;

    double displayedWidth, displayedHeight, offsetX, offsetY;

    if (imageAspect > widgetAspect) {
      displayedWidth = widgetWidth;
      displayedHeight = widgetWidth / imageAspect;
      offsetX = 0;
      offsetY = (widgetHeight - displayedHeight) / 2;
    } else {
      displayedHeight = widgetHeight;
      displayedWidth = widgetHeight * imageAspect;
      offsetX = (widgetWidth - displayedWidth) / 2;
      offsetY = 0;
    }

    // Check if click is inside actual image
    if (localPosition.dx < offsetX ||
        localPosition.dx > offsetX + displayedWidth ||
        localPosition.dy < offsetY ||
        localPosition.dy > offsetY + displayedHeight) {
      return;
    }

    final relativeX = (localPosition.dx - offsetX) / displayedWidth;
    final relativeY = (localPosition.dy - offsetY) / displayedHeight;

    final pixelX = (relativeX * imageWidth).toInt().clamp(0, imageWidth - 1);
    final pixelY = (relativeY * imageHeight).toInt().clamp(0, imageHeight - 1);

    final pixel = decodedImage.getPixel(pixelX, pixelY);

    int r = pixel.r.toInt();
    int g = pixel.g.toInt();
    int b = pixel.b.toInt();

    String colorName = colorHelper.getClosestColorName(r, g, b);

    setState(() {
      red = r;
      green = g;
      blue = b;
      detectedColorName = colorName;
      imageTapPosition = localPosition;
    });

    await TTSService.speak(colorName);
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
    Future.delayed(const Duration(seconds: 1), () {
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
      // backgroundColor: Color.fromARGB(255, red, green, blue),
      appBar: AppBar(
        actions: [
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
        ],
        leading: Row(
          children: [
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromARGB(49, 0, 0, 0),
                child: Icon(Icons.arrow_back, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
        title:  Text("Colourhear", style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, red, green, blue),
        centerTitle: true,
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
              const Center(child: CircularProgressIndicator())
            else ...[
              Expanded(
                flex: 5,
                child: Center(
                  child: GestureDetector(
                    onTapDown: _onTapDown,
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              widget.image,
                              fit: BoxFit.contain,
                              key: imageKey,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                        if (imageTapPosition != null)
                          Positioned(
                            left: imageTapPosition!.dx - 12,
                            top: imageTapPosition!.dy - 12,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                shape: BoxShape.circle,
                                color: Colors.transparent,
                              ),
                              child: Center(
                                child: Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
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
              SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}
