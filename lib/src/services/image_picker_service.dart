import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  static Future<bool> _requestPermissions() async {
    try {
      // Request both permissions
      Map<Permission, PermissionStatus> statuses = await [
        Permission.photos,
        Permission.camera,
      ].request();

      // Check if at least one permission is granted
      bool hasPermission = statuses[Permission.photos]!.isGranted ||
          statuses[Permission.camera]!.isGranted;

      if (!hasPermission) {
        // If permissions are denied, show a message to the user
        throw Exception(
          'Permission denied. Please grant camera and photo library permissions in your device settings.',
        );
      }

      return hasPermission;
    } catch (e) {
      throw Exception('Failed to request permissions: $e');
    }
  }

  static Future<File?> pickImageFromGallery() async {
    try {
      // Check if we have permission
      if (!await _requestPermissions()) {
        throw Exception('Permission denied for gallery access');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return null;
      }

      return File(image.path);
    } catch (e) {
      // Provide a more helpful error message
      if (e.toString().contains('Permission denied')) {
        throw Exception(
          'Gallery access denied. Please grant photo library permission in your device settings.',
        );
      }
      throw Exception('Error picking image from gallery: $e');
    }
  }

  static Future<File?> pickImageFromCamera() async {
    try {
      // Check if we have permission
      if (!await _requestPermissions()) {
        throw Exception('Permission denied for camera access');
      }

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image == null) {
        return null;
      }

      return File(image.path);
    } catch (e) {
      // Provide a more helpful error message
      if (e.toString().contains('Permission denied')) {
        throw Exception(
          'Camera access denied. Please grant camera permission in your device settings.',
        );
      }
      throw Exception('Error picking image from camera: $e');
    }
  }

  static Future<List<File>> pickMultipleImages() async {
    try {
      // Check if we have permission
      if (!await _requestPermissions()) {
        throw Exception('Permission denied for gallery access');
      }

      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 80,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      // Provide a more helpful error message
      if (e.toString().contains('Permission denied')) {
        throw Exception(
          'Gallery access denied. Please grant photo library permission in your device settings.',
        );
      }
      throw Exception('Error picking multiple images: $e');
    }
  }
}