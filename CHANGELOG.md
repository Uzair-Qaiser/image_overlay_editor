# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-07-22

### 🎉 Initial Release

**Simple Image Editor for Cloud Upload with Comprehensive Theming**

### ✨ Features

- **🎯 Drag & Drop**: Intuitive positioning of overlay images
- **📏 Resize**: Visual handles to resize overlays  
- **🔄 Rotate**: Smooth rotation controls
- **📱 Multiple Sources**: Gallery, camera, and network images
- **☁️ Cloud Ready**: Returns edited image for upload to your storage
- **🎨 Comprehensive Theming**: Custom colors, fonts, and UI elements
- **📱 Responsive**: Works on all screen sizes

### 🚀 Simple API

The package is designed to be extremely easy to use:

```dart
// Basic usage - just 3 lines!
ImageEditor(
  onSave: (file) => uploadToCloud(file), // Upload to your storage
)
```

### 🎨 Theming Examples

**Basic Theme:**
```dart
ImageEditor(
  onSave: (file) => uploadToFirebase(file),
)
```

**Custom Colors:**
```dart
ImageEditor(
  config: EditorConfig(
    primaryColor: Colors.green,
    secondaryColor: Colors.orange,
    backgroundColor: Colors.white,
    textColor: Colors.black87,
  ),
  onSave: (file) => uploadToServer(file),
)
```

**Dark Theme:**
```dart
ImageEditor(
  config: EditorConfig.darkTheme(),
  onSave: (file) => saveToDatabase(file),
)
```

**Brand Theme:**
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

**Custom Text and Fonts:**
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

### 🎛️ API Reference

**ImageEditor Properties:**
- `onSave` - Callback with edited image file (ready for upload)
- `onError` - Callback when an error occurs
- `networkImages` - Optional list of network image URLs
- `config` - Optional EditorConfig for theming

**EditorConfig Properties:**
- `primaryColor` - Primary UI color (default: Colors.blue)
- `secondaryColor` - Secondary UI color (default: Colors.grey)
- `backgroundColor` - Background color (default: Colors.white)
- `textColor` - Text color (default: Colors.black87)
- `borderColor` - Border color (default: Colors.grey)
- `maxHeight` - Maximum editor height (default: 600.0)
- `fontFamily` - Custom font family (default: null)
- `titleFontSize` - Title font size (default: 18.0)
- `bodyFontSize` - Body text font size (default: 14.0)
- `buttonFontSize` - Button font size (default: 16.0)
- `borderRadius` - Border radius (default: 8.0)
- `padding` - UI padding (default: EdgeInsets.all(16.0))
- `margin` - UI margin (default: EdgeInsets.all(8.0))
- `showLoadingIndicators` - Show loading indicators (default: true)
- `loadingText` - Loading text (default: 'Loading...')
- `saveButtonText` - Save button text (default: 'Save')
- `addOverlayText` - Add overlay text (default: 'Add Overlay Images')
- `galleryButtonText` - Gallery button text (default: 'Gallery')
- `cameraButtonText` - Camera button text (default: 'Camera')
- `networkButtonText` - Network button text (default: 'Network')

### 🎯 How It Works

1. **Pick Base Image**: User selects a base image from gallery
2. **Add Overlays**: User adds overlay images from gallery, camera, or network
3. **Edit**: User drags, resizes, and rotates overlays
4. **Save**: **You get the edited image file to upload to your storage**

### ☁️ Upload Examples

**Firebase Storage:**
```dart
void uploadToFirebase(File imageFile) async {
  final storageRef = FirebaseStorage.instance.ref();
  final imageRef = storageRef.child('edited_images/${DateTime.now().millisecondsSinceEpoch}.png');
  await imageRef.putFile(imageFile);
  final downloadUrl = await imageRef.getDownloadURL();
}
```

**HTTP Upload:**
```dart
void uploadToServer(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  final response = await http.post(
    Uri.parse('https://your-server.com/upload'),
    body: bytes,
    headers: {'Content-Type': 'image/png'},
  );
}
```

**Database Save:**
```dart
void saveToDatabase(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  await database.insert('images', {
    'data': bytes,
    'timestamp': DateTime.now().millisecondsSinceEpoch,
  });
}
```

### 🛡️ Error Handling

- **Permission Denied**: When camera or gallery permissions are not granted
- **Invalid Images**: When selected images are corrupted or unsupported
- **Network Errors**: When network images fail to load
- **Capture Errors**: When screenshot capture fails

### 🚀 Performance

- **Image Caching**: Network images are cached for better performance
- **Memory Management**: Large images are automatically optimized
- **File Validation**: Images are validated before processing
- **Async Operations**: All heavy operations are performed asynchronously

### 📚 Documentation

- Complete API documentation
- Usage examples for cloud upload
- Comprehensive theming guide
- Error handling guide
- Performance considerations

### 🧪 Testing

- Comprehensive test coverage
- Widget tests
- Unit tests for all components
- Theming tests

### 🔄 Migration Guide

- N/A (initial release)

### 📝 Breaking Changes

- None (initial release)
