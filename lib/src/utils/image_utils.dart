// lib/src/utils/image_utils.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class ImageUtils {
  static Future<ui.Image> loadImageDimensions(File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static Size calculateFittedDimensions(
      ui.Image image,
      double maxWidth,
      double maxHeight,
      ) {
    final imageWidth = image.width.toDouble();
    final imageHeight = image.height.toDouble();

    double fittedWidth = maxWidth;
    double fittedHeight = (maxWidth * imageHeight) / imageWidth;

    if (fittedHeight > maxHeight) {
      fittedHeight = maxHeight;
      fittedWidth = (maxHeight * imageWidth) / imageHeight;
    }

    return Size(fittedWidth, fittedHeight);
  }
}