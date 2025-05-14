import 'dart:io';
import 'package:flutter/material.dart';
// import 'package:color_palette_generator/color_palette_generator.dart'; 
import 'package:palette_generator/palette_generator.dart'; 


class ColorDetectionService {
  // Main function: returns base color + description
  static Future<Map<String, String>> detectColorFromImage(
    File imageFile,
  ) async {
    final image = Image.file(imageFile);
    final palette = await PaletteGenerator.fromImageProvider(
      image.image,
      size: Size(200, 200),
      maximumColorCount: 10,
    );

    final Color? dominantColor = palette.dominantColor?.color;

    if (dominantColor == null) {
      return {
        'color': 'Unknown',
        'description': 'Color could not be detected.',
      };
    }

    final String baseColor = _mapToBaseColor(dominantColor);
    final String description = _describeColor(baseColor);

    return {'color': baseColor, 'description': description};
  }

  // Maps RGB to basic named color
  static String _mapToBaseColor(Color color) {
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    if (r > 200 && g < 100 && b < 100) return 'Red';
    if (r < 100 && g > 200 && b < 100) return 'Green';
    if (r < 100 && g < 100 && b > 200) return 'Blue';
    if (r > 200 && g > 200 && b < 100) return 'Yellow';
    if (r > 200 && g < 100 && b > 200) return 'Magenta';
    if (r < 100 && g > 200 && b > 200) return 'Cyan';
    if (r > 240 && g > 240 && b > 240) return 'White';
    if (r < 40 && g < 40 && b < 40) return 'Black';
    if (r > 180 && g > 100 && b < 100) return 'Orange';
    if (r > 150 && g > 100 && b > 150) return 'Pink';

    return 'Unknown';
  }

  // Color descriptions
  static String _describeColor(String baseColor) {
    switch (baseColor) {
      case 'Red':
        return 'Red is the color of passion, energy, and alertness.';
      case 'Green':
        return 'Green represents nature, balance, and calmness.';
      case 'Blue':
        return 'Blue is the color of trust, depth, and peace.';
      case 'Yellow':
        return 'Yellow symbolizes brightness, warmth, and optimism.';
      case 'Magenta':
        return 'Magenta combines red and blue, vibrant and bold.';
      case 'Cyan':
        return 'Cyan is a bright, clean blue-green color.';
      case 'Black':
        return 'Black represents power, mystery, and simplicity.';
      case 'White':
        return 'White stands for purity, light, and clarity.';
      case 'Orange':
        return 'Orange is warm, exciting, and attention-grabbing.';
      case 'Pink':
        return 'Pink is soft, friendly, and loving.';
      default:
        return 'This color is not clearly recognized.';
    }
  }
}
