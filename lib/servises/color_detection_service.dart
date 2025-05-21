import 'dart:io';
import 'package:tflite/tflite.dart';

class ColorDetectionService {
  // Call this once during app start to load the model
  static Future<String?> loadModel() async {
    return await Tflite.loadModel(
      model: "assets/color_model.tflite",
      // labels: "assets/labels.txt", // if you have label file
    );
  }

  // Run TFLite model on the image file and return predicted color + description
  static Future<Map<String, String>> detectColorFromImage(File imageFile) async {
    var recognitions = await Tflite.runModelOnImage(
      path: imageFile.path,
      imageMean: 0,
      imageStd: 255.0,
      numResults: 1,
      threshold: 0.5,
    );

    if (recognitions == null || recognitions.isEmpty) {
      return {
        'color': 'Unknown',
        'description': 'Color could not be detected.',
      };
    }

    final String predictedColor = recognitions[0]['label'];

    final String description = _describeColor(predictedColor);

    return {
      'color': predictedColor,
      'description': description,
    };
  }

  // Optional: You can keep your old description method or customize it
  static String _describeColor(String baseColor) {
    switch (baseColor.toLowerCase()) {
      case 'red':
        return 'Red is the color of passion, energy, and alertness.';
      case 'green':
        return 'Green represents nature, balance, and calmness.';
      case 'blue':
        return 'Blue is the color of trust, depth, and peace.';
      case 'yellow':
        return 'Yellow symbolizes brightness, warmth, and optimism.';
      case 'magenta':
        return 'Magenta combines red and blue, vibrant and bold.';
      case 'cyan':
        return 'Cyan is a bright, clean blue-green color.';
      case 'black':
        return 'Black represents power, mystery, and simplicity.';
      case 'white':
        return 'White stands for purity, light, and clarity.';
      case 'orange':
        return 'Orange is warm, exciting, and attention-grabbing.';
      case 'pink':
        return 'Pink is soft, friendly, and loving.';
      default:
        return 'This color is not clearly recognized.';
    }
  }

  // Call this to release TFLite resources when done
  static Future<void> close() async {
    await Tflite.close();
  }
}
