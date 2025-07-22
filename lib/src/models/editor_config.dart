import 'package:flutter/material.dart';

/// Configuration for the image editor appearance and behavior
class EditorConfig {
  /// Primary color for the UI elements
  final Color primaryColor;
  
  /// Secondary color for UI elements
  final Color secondaryColor;
  
  /// Background color of the editor
  final Color backgroundColor;
  
  /// Text color for labels and buttons
  final Color textColor;
  
  /// Border color for the image container
  final Color borderColor;
  
  /// Maximum height of the editor
  final double maxHeight;
  
  /// Custom font family for text elements
  final String? fontFamily;
  
  /// Custom font size for titles
  final double titleFontSize;
  
  /// Custom font size for body text
  final double bodyFontSize;
  
  /// Custom font size for buttons
  final double buttonFontSize;
  
  /// Border radius for containers
  final double borderRadius;
  
  /// Padding for UI elements
  final EdgeInsets padding;
  
  /// Margin for UI elements
  final EdgeInsets margin;
  
  /// Whether to show loading indicators
  final bool showLoadingIndicators;
  
  /// Custom loading text
  final String loadingText;
  
  /// Custom save button text
  final String saveButtonText;
  
  /// Custom add overlay text
  final String addOverlayText;
  
  /// Custom gallery button text
  final String galleryButtonText;
  
  /// Custom camera button text
  final String cameraButtonText;
  
  /// Custom network button text
  final String networkButtonText;

  const EditorConfig({
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black87,
    this.borderColor = Colors.grey,
    this.maxHeight = 600.0,
    this.fontFamily,
    this.titleFontSize = 18.0,
    this.bodyFontSize = 14.0,
    this.buttonFontSize = 16.0,
    this.borderRadius = 8.0,
    this.padding = const EdgeInsets.all(16.0),
    this.margin = const EdgeInsets.all(8.0),
    this.showLoadingIndicators = true,
    this.loadingText = 'Loading...',
    this.saveButtonText = 'Save',
    this.addOverlayText = 'Add Overlay Images',
    this.galleryButtonText = 'Gallery',
    this.cameraButtonText = 'Camera',
    this.networkButtonText = 'Network',
  });

  /// Create a copy of this config with the given fields replaced
  EditorConfig copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    double? maxHeight,
    String? fontFamily,
    double? titleFontSize,
    double? bodyFontSize,
    double? buttonFontSize,
    double? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
    bool? showLoadingIndicators,
    String? loadingText,
    String? saveButtonText,
    String? addOverlayText,
    String? galleryButtonText,
    String? cameraButtonText,
    String? networkButtonText,
  }) {
    return EditorConfig(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      borderColor: borderColor ?? this.borderColor,
      maxHeight: maxHeight ?? this.maxHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      bodyFontSize: bodyFontSize ?? this.bodyFontSize,
      buttonFontSize: buttonFontSize ?? this.buttonFontSize,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      showLoadingIndicators: showLoadingIndicators ?? this.showLoadingIndicators,
      loadingText: loadingText ?? this.loadingText,
      saveButtonText: saveButtonText ?? this.saveButtonText,
      addOverlayText: addOverlayText ?? this.addOverlayText,
      galleryButtonText: galleryButtonText ?? this.galleryButtonText,
      cameraButtonText: cameraButtonText ?? this.cameraButtonText,
      networkButtonText: networkButtonText ?? this.networkButtonText,
    );
  }

  /// Create a dark theme configuration
  static EditorConfig darkTheme() {
    return const EditorConfig(
      primaryColor: Colors.blue,
      secondaryColor: Colors.grey,
      backgroundColor: Color(0xFF121212),
      textColor: Colors.white,
      borderColor: Colors.grey,
      fontFamily: 'Roboto',
    );
  }

  /// Create a light theme configuration
  static EditorConfig lightTheme() {
    return const EditorConfig(
      primaryColor: Colors.blue,
      secondaryColor: Colors.grey,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      borderColor: Colors.grey,
      fontFamily: 'Roboto',
    );
  }

  /// Create a custom theme with brand colors
  static EditorConfig brandTheme({
    required Color primaryColor,
    required Color secondaryColor,
    String? fontFamily,
  }) {
    return EditorConfig(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      backgroundColor: Colors.white,
      textColor: Colors.black87,
      borderColor: secondaryColor,
      fontFamily: fontFamily,
    );
  }
}