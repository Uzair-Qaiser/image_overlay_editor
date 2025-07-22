import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_overlay_editor/image_overlay_editor.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Image Editor Demo',
          theme: ThemeData(primarySwatch: Colors.blue),
          home: HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Image Editor Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Image Overlay Editor',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'Tap the button below to try the image editor',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () => _openEditor(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text('Open Image Editor'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageEditor(
          networkImages: [
            "https://picsum.photos/200/200?random=1", // Optional: Sample network images
            "https://picsum.photos/200/200?random=2", // Optional: Users can choose from these
            "https://picsum.photos/200/200?random=3", // Optional: Or add their own URLs
          ], // Optional: List of network image URLs for overlays
          onSave: (File editedImage) { // Optional: Callback when image is saved
            print('✅ Image ready for upload: ${editedImage.path}');
            print('📏 File size: ${(editedImage.lengthSync() / 1024).toStringAsFixed(2)} KB');
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image ready for upload!'),
                backgroundColor: Colors.green,
                action: SnackBarAction(
                  label: 'Upload',
                  onPressed: () => uploadToCloudStorage(editedImage),
                ),
              ),
            );
          },
          onError: (error) { // Optional: Callback when error occurs
            print('❌ Error: $error');
            _showErrorSnackBar(context, error);
          },
        ),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String error) {
    String errorMessage = error;
    if (error.contains('Permission denied') || error.contains('access denied')) {
      errorMessage = 'Permission denied. Please grant camera and photo library permissions in your device settings.';
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Settings',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please go to Settings > Privacy & Security > Photos/Camera and enable access for this app.'),
                duration: Duration(seconds: 3),
              ),
            );
          },
        ),
      ),
    );
  }

  // Example: Upload to cloud storage
  void uploadToCloudStorage(File imageFile) {
    print('🚀 Uploading to cloud storage...');
    print('📁 File path: ${imageFile.path}');
    print('📏 File size: ${(imageFile.lengthSync() / 1024).toStringAsFixed(2)} KB');
    
    // Simulate upload
    Future.delayed(Duration(seconds: 2), () {
      print('✅ Upload completed!');
    });
  }
}