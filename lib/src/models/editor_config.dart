import 'package:flutter/material.dart';

class EditorConfig {
  final double? maxHeight;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? appBarColor;
  final Color? primaryColor;
  final bool enableGalleryPick;
  final bool enableCameraPick;
  final bool enableNetworkPick;
  final List<String>? networkImageUrls;
  final double minOverlaySize;
  final double maxOverlaySize;

  const EditorConfig({
    this.maxHeight,
    this.padding,
    this.borderRadius,
    this.borderColor,
    this.backgroundColor,
    this.appBarColor,
    this.primaryColor,
    this.enableGalleryPick = true,
    this.enableCameraPick = true,
    this.enableNetworkPick = true,
    this.networkImageUrls,
    this.minOverlaySize = 30.0,
    this.maxOverlaySize = 300.0,
  });
}