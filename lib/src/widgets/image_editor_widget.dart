import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:screenshot/screenshot.dart';
import '../models/overlay_image.dart';
import '../models/editor_config.dart';
import '../services/image_picker_service.dart';
import '../services/image_processor_service.dart';
import '../utils/image_utils.dart';
import 'image_picker_bottom_sheet.dart';
import 'overlay_image_widget.dart';


class ImageEditorWidget extends StatefulWidget {
  final File? imageFile;
  final EditorConfig? config;
  final Function(File editedImage, List<OverlayImage> overlays)? onImageSaved;
  final Function(String error)? onError;

  const ImageEditorWidget({
    super.key,
    this.imageFile,
    this.config,
    this.onImageSaved,
    this.onError,
  });

  @override
  State<ImageEditorWidget> createState() => _ImageEditorWidgetState();
}

class _ImageEditorWidgetState extends State<ImageEditorWidget> {
  File? _baseImageFile;
  List<OverlayImage> overlayImages = [];
  bool _isDragging = false;
  bool _isScaling = false;
  bool _isRotating = false;

  final ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _baseImageFile = widget.imageFile;
    _pickBaseImageIfNeeded();
  }

  Future<void> _pickBaseImageIfNeeded() async {
    if (_baseImageFile == null) {
      final File? image = await ImagePickerService.pickImageFromGallery();
      if (image != null) {
        setState(() {
          _baseImageFile = image;
        });
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_baseImageFile == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              const Text('Loading image...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: widget.config?.backgroundColor ?? Colors.white,
      appBar: AppBar(
        title: const Text('Image Editor'),
        backgroundColor: widget.config?.appBarColor ?? Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveImage,
            child: Text(
              'Save',
              style: TextStyle(
                color: widget.config?.primaryColor ?? Colors.blue,
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
    return FutureBuilder<ui.Image>(
      future: ImageProcessorService.loadImageDimensions(_baseImageFile!),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            margin: widget.config?.padding ?? EdgeInsets.all(16.w),
            height: 200.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        final image = snapshot.data!;
        final screenWidth = MediaQuery.of(context).size.width -
            ((widget.config?.padding?.horizontal ?? 32.w));
        final fittedDimensions = ImageUtils.calculateFittedDimensions(
          image,
          screenWidth,
          widget.config?.maxHeight ?? MediaQuery.of(context).size.height * 0.6,
        );

        return Expanded(
          child: Center(
            child: Container(
              margin: widget.config?.padding ?? EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: widget.config?.borderColor ?? Colors.grey,
                ),
                borderRadius: widget.config?.borderRadius ?? BorderRadius.circular(8.r),
              ),
              child: ClipRRect(
                borderRadius: widget.config?.borderRadius ?? BorderRadius.circular(8.r),
                child: Stack(
                  children: [
                    Screenshot(
                      controller: screenshotController,
                      child: Container(
                        width: fittedDimensions.width,
                        height: fittedDimensions.height,
                        child: Stack(
                          children: [
                            Image.file(
                              _baseImageFile!,
                              width: fittedDimensions.width,
                              height: fittedDimensions.height,
                              fit: BoxFit.fill,
                            ),
                            ...overlayImages.map(
                                  (overlay) => _buildOverlayForScreenshot(overlay),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                          _removeOverlay(overlay);
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

  Widget _buildOverlayForScreenshot(OverlayImage overlay) {
    return Positioned(
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
    );
  }

  Widget _buildOverlaySelectionArea() {
    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: const Border(
          top: BorderSide(color: Colors.grey),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add Overlay Images',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Row(
              children: [
                // Gallery button
                if (widget.config?.enableGalleryPick ?? true)
                  _buildAddButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: _addImageFromGallery,
                  ),
                SizedBox(width: 8.w),
                // Camera button
                if (widget.config?.enableCameraPick ?? true)
                  _buildAddButton(
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: _addImageFromCamera,
                  ),
                SizedBox(width: 8.w),
                // Network button
                if (widget.config?.enableNetworkPick ?? true)
                  _buildAddButton(
                    icon: Icons.cloud_download,
                    label: 'Network',
                    onTap: _showNetworkImagePicker,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 24.h,
                color: widget.config?.primaryColor ?? Colors.blue,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addImageFromGallery() async {
    final File? image = await ImagePickerService.pickImageFromGallery();
    if (image != null) {
      _addOverlayImage(image, ImageSource.gallery);
    }
  }

  Future<void> _addImageFromCamera() async {
    final File? image = await ImagePickerService.pickImageFromCamera();
    if (image != null) {
      _addOverlayImage(image, ImageSource.camera);
    }
  }

  void _showNetworkImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ImagePickerBottomSheet(
        networkUrls: widget.config?.networkImageUrls ?? [],
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
          position: const Offset(100, 100), // Default position
          size: const Size(100, 100), // Default size
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

        final minSize = widget.config?.minOverlaySize ?? 30.0;
        final maxSize = widget.config?.maxOverlaySize ?? 300.0;

        final clampedWidth = newWidth.clamp(minSize, maxSize);
        final clampedHeight = newHeight.clamp(minSize, maxSize);

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
        final rotationFactor = 0.01;
        final dragAngle = details.delta.dx * rotationFactor;
        final newRotation = overlay.rotation + dragAngle;

        overlayImages[index] = overlay.copyWith(rotation: newRotation);
      }
    });
  }

  void _removeOverlay(OverlayImage overlay) {
    setState(() {
      overlayImages.remove(overlay);
    });
  }

  Future<void> _saveImage() async {
    try {
      if (overlayImages.isEmpty) {
        Navigator.pop(context);
        return;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      final String fileName = 'edited_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final File? editedImage = await ImageProcessorService.captureCompositeImage(
        screenshotController,
        fileName,
      );

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        if (editedImage != null) {
          widget.onImageSaved?.call(editedImage, overlayImages);
          Navigator.pop(context); // Close editor

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image saved successfully! ${overlayImages.length} overlays added.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          widget.onError?.call('Failed to save image');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error saving image'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        widget.onError?.call(e.toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}