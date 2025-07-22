import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ImageProcessorService {
  static Future<ui.Image> loadImageDimensions(File imageFile) async {
    try {
      final Uint8List bytes = await imageFile.readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frameInfo = await codec.getNextFrame();
      return frameInfo.image;
    } catch (e) {
      throw Exception('Failed to load image dimensions: $e');
    }
  }

  static Future<File?> captureCompositeImage(
    ScreenshotController controller,
    String fileName,
  ) async {
    try {
      // Wait for UI to settle
      await Future.delayed(const Duration(milliseconds: 1000));

      // Capture the screenshot
      final Uint8List? imageBytes = await controller.capture();

      if (imageBytes == null) {
        throw Exception('Screenshot capture returned null');
      }

      if (imageBytes.isEmpty) {
        throw Exception('Screenshot capture returned empty data');
      }

      if (imageBytes.length < 1024) {
        throw Exception('Screenshot data too small: ${imageBytes.length} bytes');
      }

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/$fileName';
      final File compositeImageFile = File(filePath);

      // Write the image bytes
      await compositeImageFile.writeAsBytes(imageBytes);

      // Verify the file was created
      if (await compositeImageFile.exists()) {
        final fileSize = await compositeImageFile.length();
        if (fileSize > 0) {
          print('Image saved successfully: ${compositeImageFile.path} (${fileSize} bytes)');
          return compositeImageFile;
        } else {
          throw Exception('Created file is empty');
        }
      } else {
        throw Exception('Failed to create output file');
      }
    } catch (e) {
      print('Error capturing composite image: $e');
      throw Exception('Failed to capture and save image: $e');
    }
  }
}