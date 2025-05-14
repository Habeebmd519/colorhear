import 'package:flutter/material.dart';

class HowToUseScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[50],
      appBar: AppBar(
        title: Text('How to Use'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/how_to_use_1.png',
              height: 220,
            ),
            SizedBox(height: 24),
            Text(
              '1. Open the app and tap "Start Detecting"\n\n'
              '2. Use the camera to take a photo, or upload one from your gallery\n\n'
              '3. The app will tell you the basic color name (like "Red")\n\n'
              '4. Tap the speaker button to hear it read aloud\n\n'
              '5. Explore settings to adjust voice speed or theme',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
