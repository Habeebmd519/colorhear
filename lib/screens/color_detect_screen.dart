import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:image_picker/image_picker.dart';
import 'package:colorhear/servises/color_detection_service.dart';
import 'package:colorhear/servises/tts_service.dart';

class ColorDetectScreen extends StatefulWidget {
  @override
  _ColorDetectScreenState createState() => _ColorDetectScreenState();
}

class _ColorDetectScreenState extends State<ColorDetectScreen> {
  File? _imageFile;
  String detectedColor = "No color detected yet";
  String colorDescription = "";
  bool isLoading = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        isLoading = true;
        _imageFile = File(picked.path);
      });

      final result =
          await ColorDetectionService.detectColorFromImage(_imageFile!);

      setState(() {
        detectedColor = result['color']!;
        colorDescription = result['description']!;
        isLoading = false;
      });
    }
  }

  void _pickFromCamera() => _pickImage(ImageSource.camera);
  void _pickFromGallery() => _pickImage(ImageSource.gallery);

  void _speakColor() {
    if (detectedColor != "No color detected yet") {
      TTSService.speak("$detectedColor. $colorDescription");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Text('Detect Color'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Lottie.asset(
              'assets/animations/color_detect.json',
              height: 180,
            ),
            if (isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: CircularProgressIndicator(),
              ),
            ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text("Use Camera"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _pickFromCamera,
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.photo_library),
              label: Text("Upload from Gallery"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _pickFromGallery,
            ),
            SizedBox(height: 30),
            Text(
              detectedColor,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple[800],
              ),
            ),
            SizedBox(height: 10),
            Text(
              colorDescription,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.volume_up),
              label: Text("Hear Color"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[400],
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 24),
              ),
              onPressed: _speakColor,
            ),
          ],
        ),
      ),
    );
  }
}
