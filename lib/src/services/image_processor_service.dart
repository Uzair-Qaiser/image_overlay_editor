import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class ImageProcessorService {
  static Future<ui.Image> loadImageDimensions(File imageFile) async {
    final Uint8List bytes = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(bytes);
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static Future<File?> captureCompositeImage(
      ScreenshotController controller,
      String fileName,
      ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final Uint8List? imageBytes = await controller.capture();

      if (imageBytes != null && imageBytes.length > 1000) {
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath = '${tempDir.path}/$fileName';
        final File compositeImageFile = File(filePath);

        await compositeImageFile.writeAsBytes(imageBytes);

        if (await compositeImageFile.exists()) {
          return compositeImageFile;
        }
      }
    } catch (e) {
      print('Error capturing composite image: $e');
    }

    return null;
  }
}