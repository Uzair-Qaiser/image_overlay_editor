# Image Overlay Editor

A super simple Flutter package for editing images with overlays. Perfect for apps that need to upload edited images to cloud storage or databases.

## ✨ Features

- **🎯 Drag & Drop**: Intuitive positioning of overlay images
- **📏 Resize**: Visual handles to resize overlays  
- **🔄 Rotate**: Smooth rotation controls
- **📱 Multiple Sources**: Gallery, camera, and network images
- **☁️ Cloud Ready**: Returns edited image for upload to your storage
- **🎨 Customizable**: Custom colors, fonts, and theming
- **📱 Responsive**: Works on all screen sizes

## 🚀 Quick Start

### Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  image_overlay_editor: ^1.0.0
```

### Basic Usage (3 lines!)

```dart
import 'package:image_overlay_editor/image_overlay_editor.dart';

// Just 3 lines to get a full image editor!
ImageEditor(
  onSave: (file) => uploadToCloud(file), // Upload to your storage
)
```

### Complete Example with Cloud Upload

```dart
import 'package:flutter/material.dart';
import 'package:image_overlay_editor/image_overlay_editor.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('My App')),
        body: Center(
          child: ElevatedButton(
            onPressed: () => _openEditor(context),
            child: Text('Edit Image'),
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
          onSave: (File editedImage) {
            // Upload to your cloud storage
            uploadToFirebase(editedImage);
            // OR upload to your server
            uploadToServer(editedImage);
            // OR save to your database
            saveToDatabase(editedImage);
          },
          onError: (String error) {
            print('Error: $error');
          },
        ),
      ),
    );
  }

  // Example: Upload to Firebase Storage
  void uploadToFirebase(File imageFile) async {
    // Your Firebase upload logic here
    print('Uploading to Firebase: ${imageFile.path}');
  }

  // Example: Upload to your server
  void uploadToServer(File imageFile) async {
    // Your server upload logic here
    print('Uploading to server: ${imageFile.path}');
  }

  // Example: Save to database
  void saveToDatabase(File imageFile) async {
    // Your database save logic here
    print('Saving to database: ${imageFile.path}');
  }
}
```

That's it! Your app now has a full image editor that returns the edited image for you to upload wherever you need.

## 📖 More Examples

### With Network Images
```dart
ImageEditor(
  networkImages: [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
  ],
  onSave: (file) => uploadToCloud(file),
)
```

### Custom Colors
```dart
ImageEditor(
  config: EditorConfig(
    primaryColor: Colors.green,
    secondaryColor: Colors.orange,
    backgroundColor: Colors.white,
    textColor: Colors.black87,
  ),
  onSave: (file) => uploadToCloud(file),
)
```

### Dark Theme
```dart
ImageEditor(
  config: EditorConfig.darkTheme(),
  onSave: (file) => uploadToCloud(file),
)
```

### Brand Theme
```dart
ImageEditor(
  config: EditorConfig.brandTheme(
    primaryColor: Colors.purple,
    secondaryColor: Colors.pink,
    fontFamily: 'Poppins',
  ),
  onSave: (file) => uploadToCloud(file),
)
```

### Custom Text and Fonts
```dart
ImageEditor(
  config: EditorConfig(
    primaryColor: Colors.blue,
    fontFamily: 'Roboto',
    titleFontSize: 20.0,
    bodyFontSize: 16.0,
    buttonFontSize: 18.0,
    saveButtonText: 'Save Image',
    addOverlayText: 'Add Stickers',
    galleryButtonText: 'Photos',
    cameraButtonText: 'Camera',
    networkButtonText: 'Online',
  ),
  onSave: (file) => uploadToCloud(file),
)
```

### Custom UI Elements
```dart
ImageEditor(
  config: EditorConfig(
    primaryColor: Colors.red,
    borderRadius: 12.0,
    padding: EdgeInsets.all(20.0),
    margin: EdgeInsets.all(10.0),
    showLoadingIndicators: false,
    loadingText: 'Processing...',
  ),
  onSave: (file) => uploadToCloud(file),
)
```

### Control Button Visibility
```dart
// Gallery only
ImageEditor(
  showGallery: true,
  showCamera: false,
  showNetwork: false,
  onSave: (file) => uploadToCloud(file),
)

// Camera only
ImageEditor(
  showGallery: false,
  showCamera: true,
  showNetwork: false,
  onSave: (file) => uploadToCloud(file),
)

// Gallery and Camera only (no network)
ImageEditor(
  showGallery: true,
  showCamera: true,
  showNetwork: false,
  onSave: (file) => uploadToCloud(file),
)

// All options enabled (default)
ImageEditor(
  showGallery: true,
  showCamera: true,
  showNetwork: true,
  onSave: (file) => uploadToCloud(file),
)
```

## 🎛️ API Reference

### ImageEditor Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `onSave` | `Function(File)` | ✅ | Called with edited image file (ready for upload) |
| `onError` | `Function(String)` | ❌ | Called when error occurs |
| `networkImages` | `List<String>` | ❌ | Network images to choose from |
| `config` | `EditorConfig` | ❌ | Custom theming and behavior |
| `showGallery` | `bool` | ❌ | Whether to show gallery button (default: true) |
| `showCamera` | `bool` | ❌ | Whether to show camera button (default: true) |
| `showNetwork` | `bool` | ❌ | Whether to show network button (default: true) |

### EditorConfig Properties

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `primaryColor` | `Color` | `Colors.blue` | Primary UI color |
| `secondaryColor` | `Color` | `Colors.grey` | Secondary UI color |
| `backgroundColor` | `Color` | `Colors.white` | Background color |
| `textColor` | `Color` | `Colors.black87` | Text color |
| `borderColor` | `Color` | `Colors.grey` | Border color |
| `maxHeight` | `double` | `600.0` | Maximum editor height |
| `fontFamily` | `String?` | `null` | Custom font family |
| `titleFontSize` | `double` | `18.0` | Title font size |
| `bodyFontSize` | `double` | `14.0` | Body text font size |
| `buttonFontSize` | `double` | `16.0` | Button font size |
| `borderRadius` | `double` | `8.0` | Border radius |
| `padding` | `EdgeInsets` | `EdgeInsets.all(16.0)` | UI padding |
| `margin` | `EdgeInsets` | `EdgeInsets.all(8.0)` | UI margin |
| `showLoadingIndicators` | `bool` | `true` | Show loading indicators |
| `loadingText` | `String` | `'Loading...'` | Loading text |
| `saveButtonText` | `String` | `'Save'` | Save button text |
| `addOverlayText` | `String` | `'Add Overlay Images'` | Add overlay text |
| `galleryButtonText` | `String` | `'Gallery'` | Gallery button text |
| `cameraButtonText` | `String` | `'Camera'` | Camera button text |
| `networkButtonText` | `String` | `'Network'` | Network button text |

## 🎯 How It Works

1. User taps "Edit Image" button
2. User picks a base image from gallery
3. User adds overlay images (gallery/camera/network)
4. User drags, resizes, and rotates overlays
5. User taps "Save" → **You get the edited image file to upload**

## ☁️ Upload Examples

### Firebase Storage
```dart
import 'package:firebase_storage/firebase_storage.dart';

void uploadToFirebase(File imageFile) async {
  final storageRef = FirebaseStorage.instance.ref();
  final imageRef = storageRef.child('edited_images/${DateTime.now().millisecondsSinceEpoch}.png');
  
  await imageRef.putFile(imageFile);
  final downloadUrl = await imageRef.getDownloadURL();
  print('Uploaded to Firebase: $downloadUrl');
}
```

### HTTP Upload
```dart
import 'package:http/http.dart' as http;

void uploadToServer(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final response = await http.post(
    Uri.parse('https://your-server.com/upload'),
    body: bytes,
    headers: {'Content-Type': 'image/png'},
  );
  print('Uploaded to server: ${response.statusCode}');
}
```

### Local Database
```dart
import 'package:sqflite/sqflite.dart';

void saveToDatabase(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  // Save bytes to your database
  await database.insert('images', {
    'data': bytes,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
  print('Saved to database');
}
```

## 🔧 Permissions

Add these to your app:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs access to photo library to pick images</string>
<key>NSCameraUsageDescription</key>
<string>This app needs access to camera to take photos</string>
```

## 🚀 Advanced Usage

For advanced users, the package also exports additional components:

```dart
import 'package:image_overlay_editor/image_overlay_editor.dart';

// Advanced components
import 'package:image_overlay_editor/src/models/overlay_image.dart';
import 'package:image_overlay_editor/src/models/editor_config.dart';
import 'package:image_overlay_editor/src/services/image_picker_service.dart';
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

If you encounter any issues or have questions:

1. Check the [example](example) folder for usage examples
2. Review the [API documentation](#api-reference)
3. Open an issue on GitHub

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for a list of changes and version history.
