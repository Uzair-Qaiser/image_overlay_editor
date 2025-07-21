import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.camera,
    ].request();

    return statuses[Permission.photos]!.isGranted ||
        statuses[Permission.camera]!.isGranted;
  }

  static Future<File?> pickImageFromGallery() async {
    try {
      if (!await _requestPermissions()) {
        throw Exception('Permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      if (!await _requestPermissions()) {
        throw Exception('Permission denied');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      return image != null ? File(image.path) : null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  static Future<List<File>> pickMultipleImages() async {
    try {
      if (!await _requestPermissions()) {
        throw Exception('Permission denied');
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      print('Error picking multiple images: $e');
      return [];
    }
  }
}