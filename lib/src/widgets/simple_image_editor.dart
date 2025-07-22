import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import '../models/overlay_image.dart';
import '../models/editor_config.dart';
import '../services/image_picker_service.dart';
import '../utils/image_utils.dart';
import 'image_picker_bottom_sheet.dart';
import 'overlay_image_widget.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

/// Simple and easy-to-use image editor widget
/// 
/// Usage:
/// ```dart
/// ImageEditor(
///   onSave: (file) => print('Saved: ${file.path}'),
/// )
/// ```
class ImageEditor extends StatefulWidget {
  /// Callback when image is saved
  /// 
  /// Example:
  /// ```dart
  /// onSave: (File savedImage) {
  ///   print('Image saved: ${savedImage.path}');
  ///   // Upload to server, save to gallery, etc.
  /// }
  /// ```
  final Function(File savedImage)? onSave;
  
  /// Callback when an error occurs
  /// 
  /// Example:
  /// ```dart
  /// onError: (String error) {
  ///   print('Error: $error');
  ///   // Show error dialog, snackbar, etc.
  /// }
  /// ```
  final Function(String error)? onError;
  
  /// Optional base image to start with (local file)
  /// 
  /// Example:
  /// ```dart
  /// baseImage: File('/path/to/image.jpg'),
  /// ```
  final File? baseImage;
  
  /// Optional network image URL to use as background
  /// 
  /// Example:
  /// ```dart
  /// baseImageUrl: 'https://example.com/background.jpg',
  /// ```
  final String? baseImageUrl;
  
  /// Optional list of network image URLs to choose from as overlays
  /// 
  /// Example:
  /// ```dart
  /// networkImages: [
  ///   'https://example.com/clipart1.png',
  ///   'https://example.com/clipart2.png',
  ///   'https://example.com/sticker1.png',
  /// ],
  /// ```
  final List<String>? networkImages;
  
  /// Configuration for appearance and behavior
  /// 
  /// Example:
  /// ```dart
  /// config: EditorConfig(
  ///   primaryColor: Colors.blue,
  ///   backgroundColor: Colors.white,
  ///   textColor: Colors.black,
  ///   borderColor: Colors.grey,
  ///   borderRadius: 8.0,
  ///   fontFamily: 'Roboto',
  /// ),
  /// ```
  final EditorConfig? config;

  /// Whether to show gallery button (default: true)
  /// 
  /// Example:
  /// ```dart
  /// showGallery: false, // Hide gallery option
  /// ```
  final bool showGallery;
  
  /// Whether to show camera button (default: true)
  /// 
  /// Example:
  /// ```dart
  /// showCamera: false, // Hide camera option
  /// ```
  final bool showCamera;
  
  /// Whether to show network button (default: true)
  /// 
  /// Example:
  /// ```dart
  /// showNetwork: false, // Hide network option
  /// ```
  final bool showNetwork;

  const ImageEditor({
    super.key,
    this.onSave, // Optional: Callback when image is saved
    this.onError, // Optional: Callback when error occurs
    this.baseImage, // Optional: Local file to start with
    this.baseImageUrl, // Optional: Network URL for background
    this.networkImages, // Optional: List of network image URLs for overlays
    this.config, // Optional: Custom appearance configuration
    this.showGallery = true, // Optional: Show gallery button (default: true)
    this.showCamera = true, // Optional: Show camera button (default: true)
    this.showNetwork = true, // Optional: Show network button (default: true)
  });

  @override
  State<ImageEditor> createState() => _ImageEditorState();
}

class _ImageEditorState extends State<ImageEditor> {
  File? _baseImageFile;
  String? _baseImageUrl;
  List<OverlayImage> overlayImages = [];
  bool _isDragging = false;
  bool _isScaling = false;
  bool _isRotating = false;
  bool _isLoading = false;

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _baseImageFile = widget.baseImage;
    _baseImageUrl = widget.baseImageUrl;
    _pickBaseImageIfNeeded();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure screenshot controller is properly initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _pickBaseImageIfNeeded() async {
    // If we have a base image (local or network), don't pick
    if (_baseImageFile != null || _baseImageUrl != null) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final File? image = await ImagePickerService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _baseImageFile = image;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      widget.onError?.call(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config ?? const EditorConfig();
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: config.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (config.showLoadingIndicators) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                config.loadingText,
                style: TextStyle(
                  fontSize: config.bodyFontSize,
                  fontFamily: config.fontFamily,
                  color: config.textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_baseImageFile == null && _baseImageUrl == null) {
      return Scaffold(
        backgroundColor: config.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (config.showLoadingIndicators) const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                config.loadingText,
                style: TextStyle(
                  fontSize: config.bodyFontSize,
                  fontFamily: config.fontFamily,
                  color: config.textColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: config.backgroundColor,
      appBar: AppBar(
        title: Text(
          'Image Editor',
          style: TextStyle(
            fontSize: config.titleFontSize,
            fontFamily: config.fontFamily,
            color: config.textColor,
          ),
        ),
        backgroundColor: config.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: config.textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveImage,
            child: Text(
              config.saveButtonText,
              style: TextStyle(
                fontSize: config.buttonFontSize,
                fontFamily: config.fontFamily,
                color: config.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildImageEditingArea(),
          _buildOverlaySelectionArea(),
        ],
      ),
    );
  }

  Widget _buildImageEditingArea() {
    final config = widget.config ?? const EditorConfig();
    
    return FutureBuilder<ui.Image>(
      future: ImageUtils.loadImageDimensions(_baseImageFile!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: config.margin,
            height: 200,
            child: Center(
              child: config.showLoadingIndicators 
                ? const CircularProgressIndicator()
                : const SizedBox(),
            ),
          );
        }

        final image = snapshot.data!;
        final screenWidth = MediaQuery.of(context).size.width - 32;
        final fittedDimensions = ImageUtils.calculateFittedDimensions(
          image,
          screenWidth,
          config.maxHeight,
        );

        return Expanded(
          child: Center(
            child: Container(
              margin: config.margin,
              decoration: BoxDecoration(
                border: Border.all(color: config.borderColor),
                borderRadius: BorderRadius.circular(config.borderRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(config.borderRadius),
                child: Stack(
                  children: [
                    // Screenshot capture area (simplified like working code)
                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        width: fittedDimensions.width,
                        height: fittedDimensions.height,
                        child: Stack(
                          children: [
                            // Base image (local or network)
                            if (_baseImageFile != null)
                              Image.file(
                                _baseImageFile!,
                                width: fittedDimensions.width,
                                height: fittedDimensions.height,
                                fit: BoxFit.fill,
                              )
                            else if (_baseImageUrl != null)
                              Image.network(
                                _baseImageUrl!,
                                width: fittedDimensions.width,
                                height: fittedDimensions.height,
                                fit: BoxFit.fill,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    width: fittedDimensions.width,
                                    height: fittedDimensions.height,
                                    color: config.secondaryColor.withOpacity(0.1),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: fittedDimensions.width,
                                    height: fittedDimensions.height,
                                    color: config.secondaryColor.withOpacity(0.1),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.error, color: config.textColor),
                                          SizedBox(height: 8),
                                          Text(
                                            'Failed to load image',
                                            style: TextStyle(color: config.textColor),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            // Overlays for screenshot
                            ...overlayImages.map(
                              (overlay) => Positioned(
                                left: overlay.position.dx,
                                top: overlay.position.dy,
                                child: Transform.rotate(
                                  angle: overlay.rotation,
                                  child: Container(
                                    width: overlay.size.width,
                                    height: overlay.size.height,
                                    child: overlay.isLocal
                                        ? Image.file(
                                            File(overlay.imageUrl),
                                            fit: BoxFit.contain,
                                          )
                                        : Image.network(
                                            overlay.imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Interactive controls (on top, not captured)
                    ...overlayImages.map(
                      (overlay) => OverlayImageWidget(
                        overlay: overlay,
                        isDragging: _isDragging,
                        isScaling: _isScaling,
                        isRotating: _isRotating,
                        onDragStart: () {
                          setState(() {
                            _isDragging = true;
                            _isScaling = false;
                            _isRotating = false;
                          });
                        },
                        onDragUpdate: (details) {
                          _updateOverlayPosition(overlay, details);
                        },
                        onDragEnd: () {
                          setState(() {
                            _isDragging = false;
                          });
                        },
                        onResizeStart: () {
                          setState(() {
                            _isScaling = true;
                            _isDragging = false;
                            _isRotating = false;
                          });
                        },
                        onResizeUpdate: (details) {
                          _updateOverlayResize(overlay, details);
                        },
                        onResizeEnd: () {
                          setState(() {
                            _isScaling = false;
                          });
                        },
                        onRotateStart: () {
                          setState(() {
                            _isRotating = true;
                            _isDragging = false;
                            _isScaling = false;
                          });
                        },
                        onRotateUpdate: (details) {
                          _updateOverlayRotation(overlay, details);
                        },
                        onRotateEnd: () {
                          setState(() {
                            _isRotating = false;
                          });
                        },
                        onRemove: () {
                          setState(() {
                            overlayImages.remove(overlay);
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverlaySelectionArea() {
    final config = widget.config ?? const EditorConfig();
    
    return SafeArea(
      child: Container(
        height: 120,
        padding: config.padding,
        decoration: BoxDecoration(
          color: config.secondaryColor.withOpacity(0.1),
          border: Border(
            top: BorderSide(color: config.borderColor),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              config.addOverlayText,
              style: TextStyle(
                fontSize: config.titleFontSize,
                fontFamily: config.fontFamily,
                color: config.textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Row(
                children: [
                  if (widget.showGallery)
                    _buildAddButton(
                      icon: Icons.photo_library,
                      label: config.galleryButtonText,
                      onTap: _addImageFromGallery,
                      config: config,
                    ),
                  if (widget.showGallery && widget.showCamera)
                    const SizedBox(width: 8),
                  if (widget.showCamera)
                    _buildAddButton(
                      icon: Icons.camera_alt,
                      label: config.cameraButtonText,
                      onTap: _addImageFromCamera,
                      config: config,
                    ),
                  if (widget.showCamera && widget.showNetwork)
                    const SizedBox(width: 8),
                  if (widget.showNetwork && widget.networkImages != null && widget.networkImages!.isNotEmpty)
                    _buildAddButton(
                      icon: Icons.cloud_download,
                      label: config.networkButtonText,
                      onTap: _showNetworkImagePicker,
                      config: config,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required EditorConfig config,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: config.borderColor),
            borderRadius: BorderRadius.circular(config.borderRadius),
            color: config.backgroundColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: config.primaryColor,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: config.fontFamily,
                  color: config.textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImageFromGallery() async {
    try {
      final File? image = await ImagePickerService.pickImageFromGallery();
      if (image != null) {
        _addOverlayImage(image, ImageSource.gallery);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Permission denied') || errorMessage.contains('Gallery access denied')) {
        _showPermissionDialog(
          'Gallery Permission Required',
          'This app needs access to your photo library to pick images. Please grant permission in your device settings.',
        );
      } else {
        _showErrorSnackBar('Failed to pick image from gallery: $e');
      }
    }
  }

  Future<void> _addImageFromCamera() async {
    try {
      final File? image = await ImagePickerService.pickImageFromCamera();
      if (image != null) {
        _addOverlayImage(image, ImageSource.camera);
      }
    } catch (e) {
      String errorMessage = e.toString();
      if (errorMessage.contains('Permission denied') || errorMessage.contains('Camera access denied')) {
        _showPermissionDialog(
          'Camera Permission Required',
          'This app needs access to your camera to take photos. Please grant permission in your device settings.',
        );
      } else {
        _showErrorSnackBar('Failed to pick image from camera: $e');
      }
    }
  }

  void _showNetworkImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImagePickerBottomSheet(
        networkUrls: widget.networkImages!,
        onImageSelected: (imageUrl) {
          _addOverlayImage(imageUrl, ImageSource.network);
        },
      ),
    );
  }

  void _addOverlayImage(dynamic imageSource, ImageSource source) {
    final String imageUrl = imageSource is File ? imageSource.path : imageSource;
    final bool isLocal = imageSource is File;

    setState(() {
      overlayImages.add(
        OverlayImage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          source: source,
          imageUrl: imageUrl,
          position: const Offset(100, 100),
          size: const Size(100, 100),
          isLocal: isLocal,
        ),
      );
    });
  }

  void _updateOverlayPosition(OverlayImage overlay, DragUpdateDetails details) {
    setState(() {
      final index = overlayImages.indexOf(overlay);
      if (index != -1) {
        final newPosition = overlay.position + details.delta;
        overlayImages[index] = overlay.copyWith(position: newPosition);
      }
    });
  }

  void _updateOverlayResize(OverlayImage overlay, DragUpdateDetails details) {
    setState(() {
      final index = overlayImages.indexOf(overlay);
      if (index != -1) {
        final currentSize = overlay.size;
        final newWidth = currentSize.width + details.delta.dx;
        final newHeight = currentSize.height + details.delta.dy;

        final clampedWidth = newWidth.clamp(30.0, 300.0);
        final clampedHeight = newHeight.clamp(30.0, 300.0);

        overlayImages[index] = overlay.copyWith(
          size: Size(clampedWidth, clampedHeight),
        );
      }
    });
  }

  void _updateOverlayRotation(OverlayImage overlay, DragUpdateDetails details) {
    setState(() {
      final index = overlayImages.indexOf(overlay);
      if (index != -1) {
        final currentRotation = overlayImages[index].rotation;
        final rotationFactor = 0.01;
        final dragAngle = details.delta.dx * rotationFactor;
        final newRotation = currentRotation + dragAngle;
        
        overlayImages[index] = overlay.copyWith(
          rotation: newRotation,
        );
      }
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _saveImage() async {
    try {
      if (overlayImages.isEmpty) {
        Navigator.pop(context);
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      print('Starting image capture...');
      
      // Add a small delay to ensure UI is fully rendered
      await Future.delayed(const Duration(milliseconds: 500));
      
      final Uint8List? imageBytes = await screenshotController.capture();
      File? finalImageFile;
      
      if (imageBytes != null && imageBytes.length > 1000) {
        print('✅ Screenshot captured successfully! Size: ${imageBytes.length} bytes');
        
        // Create a temporary file for the callback (users can then upload this)
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = 'edited_image_${DateTime.now().millisecondsSinceEpoch}.png';
        final String filePath = '${tempDir.path}/$fileName';
        final File tempFile = File(filePath);
        
        try {
          await tempFile.writeAsBytes(imageBytes);
          
          print('✅ File created successfully: ${tempFile.path} (${await tempFile.length()} bytes)');
          
          // Verify the file was written correctly
          if (await tempFile.exists() && await tempFile.length() > 0) {
            finalImageFile = tempFile;
          } else {
            throw Exception('File was not written successfully');
          }
        } catch (e) {
          print('❌ Error writing file: $e');
          rethrow;
        }
      } else {
        print('❌ Screenshot capture failed or returned empty data');
        print('Image bytes length: ${imageBytes?.length ?? 0}');
        
        // Fallback: Use the original image if no overlays were added
        print('Using fallback method: using original image');
        finalImageFile = _baseImageFile;
      }
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {
          _isLoading = false;
        });

        if (finalImageFile != null) {
          // Call the onSave callback with the file (users can upload this to their storage)
          widget.onSave?.call(finalImageFile);
          Navigator.pop(context); // Close editor

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image ready for upload! ${overlayImages.length} overlays added.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showErrorSnackBar('Failed to create output file');
          widget.onError?.call('Failed to create output file');
        }
      }
    } catch (e) {
      print('Error during save process: $e');
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        setState(() {
          _isLoading = false;
        });
        
        String errorMessage = 'Error capturing image: $e';
        _showErrorSnackBar(errorMessage);
        widget.onError?.call(errorMessage);
      }
    }
  }

  void _showPermissionDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // You could add logic here to open device settings
              // For now, just show a snackbar with instructions
              _showErrorSnackBar(
                'Please go to Settings > Privacy & Security > Photos/Camera and enable access for this app.',
              );
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
} 