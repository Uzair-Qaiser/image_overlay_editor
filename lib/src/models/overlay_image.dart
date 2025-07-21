import 'package:flutter/material.dart';

enum ImageSource { gallery, network, camera }

class OverlayImage {
  final String id;
  final ImageSource source;
  final String imageUrl;
  final Offset position;
  final Size size;
  final double rotation;
  final bool isLocal;

  const OverlayImage({
    required this.id,
    required this.source,
    required this.imageUrl,
    required this.position,
    required this.size,
    this.rotation = 0.0,
    this.isLocal = false,
  });

  OverlayImage copyWith({
    String? id,
    ImageSource? source,
    String? imageUrl,
    Offset? position,
    Size? size,
    double? rotation,
    bool? isLocal,
  }) {
    return OverlayImage(
      id: id ?? this.id,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      position: position ?? this.position,
      size: size ?? this.size,
      rotation: rotation ?? this.rotation,
      isLocal: isLocal ?? this.isLocal,
    );
  }

  factory OverlayImage.fromJson(Map<String, dynamic> json) {
    return OverlayImage(
      id: json['id'] as String,
      source: ImageSource.values.firstWhere(
            (e) => e.toString() == json['source'],
      ),
      imageUrl: json['imageUrl'] as String,
      position: Offset(
        json['position']['dx'] as double,
        json['position']['dy'] as double,
      ),
      size: Size(
        json['size']['width'] as double,
        json['size']['height'] as double,
      ),
      rotation: json['rotation'] as double? ?? 0.0,
      isLocal: json['isLocal'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'source': source.toString(),
      'imageUrl': imageUrl,
      'position': {
        'dx': position.dx,
        'dy': position.dy,
      },
      'size': {
        'width': size.width,
        'height': size.height,
      },
      'rotation': rotation,
      'isLocal': isLocal,
    };
  }
}