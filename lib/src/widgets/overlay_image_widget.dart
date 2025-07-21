
import 'package:flutter/material.dart';
import 'dart:io';
import '../models/overlay_image.dart';

class OverlayImageWidget extends StatelessWidget {
  final OverlayImage overlay;
  final bool isDragging;
  final bool isScaling;
  final bool isRotating;
  final VoidCallback onDragStart;
  final Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragEnd;
  final VoidCallback onResizeStart;
  final Function(DragUpdateDetails) onResizeUpdate;
  final VoidCallback onResizeEnd;
  final VoidCallback onRotateStart;
  final Function(DragUpdateDetails) onRotateUpdate;
  final VoidCallback onRotateEnd;
  final VoidCallback onRemove;

  const OverlayImageWidget({
    super.key,
    required this.overlay,
    required this.isDragging,
    required this.isScaling,
    required this.isRotating,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
    required this.onRotateStart,
    required this.onRotateUpdate,
    required this.onRotateEnd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: overlay.position.dx,
      top: overlay.position.dy,
      child: GestureDetector(
        onPanStart: (details) => onDragStart(),
        onPanUpdate: onDragUpdate,
        onPanEnd: (details) => onDragEnd(),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: overlay.size.width,
              height: overlay.size.height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _getBorderColor(),
                  width: _getBorderWidth(),
                ),
              ),
              child: Transform.rotate(
                angle: overlay.rotation,
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
            // Remove button
            Positioned(
              top: -8,
              right: -8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
            // Resize handle
            Positioned(
              bottom: -8,
              right: -8,
              child: GestureDetector(
                onPanStart: (details) => onResizeStart(),
                onPanUpdate: onResizeUpdate,
                onPanEnd: (details) => onResizeEnd(),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isScaling ? Colors.red : Colors.orange,
                    shape: BoxShape.circle,
                    border: isScaling ? Border.all(color: Colors.white, width: 2) : null,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.drag_handle,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
            // Rotate handle
            Positioned(
              top: -8,
              left: -8,
              child: GestureDetector(
                onPanStart: (details) => onRotateStart(),
                onPanUpdate: onRotateUpdate,
                onPanEnd: (details) => onRotateEnd(),
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isRotating ? Colors.purple : Colors.blue,
                    shape: BoxShape.circle,
                    border: isRotating ? Border.all(color: Colors.white, width: 2) : null,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.rotate_90_degrees_ccw,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (isDragging) return Colors.red;
    if (isScaling) return Colors.orange;
    if (isRotating) return Colors.purple;
    return Colors.blue;
  }

  double _getBorderWidth() {
    return (isDragging || isScaling || isRotating) ? 3 : 2;
  }
}