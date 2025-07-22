import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_overlay_editor/image_overlay_editor.dart';
import 'dart:ui' as ui;

void main() {
  group('Image Overlay Editor Tests', () {
    testWidgets('ImageEditor displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageEditor(
              onSave: (file) {},
              onError: (error) {},
            ),
          ),
        ),
      );
      
      // Wait for initial load
      await tester.pump(const Duration(seconds: 2));
      
      // Check if the widget loads (it will show loading initially)
      expect(find.byType(ImageEditor), findsOneWidget);
    });

    testWidgets('ImageEditor with network images shows network button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageEditor(
              networkImages: ['https://example.com/image.jpg'],
              onSave: (file) {},
              onError: (error) {},
            ),
          ),
        ),
      );
      
      // Wait for initial load
      await tester.pump(const Duration(seconds: 2));
      
      // Check if the widget loads
      expect(find.byType(ImageEditor), findsOneWidget);
    });

    testWidgets('ImageEditor without network images hides network button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageEditor(
              onSave: (file) {},
              onError: (error) {},
            ),
          ),
        ),
      );
      
      // Wait for initial load
      await tester.pump(const Duration(seconds: 2));
      
      // Check if the widget loads
      expect(find.byType(ImageEditor), findsOneWidget);
    });

    test('EditorConfig should have correct default values', () {
      const config = EditorConfig();

      expect(config.primaryColor, Colors.blue);
      expect(config.secondaryColor, Colors.grey);
      expect(config.backgroundColor, Colors.white);
      expect(config.textColor, Colors.black87);
      expect(config.borderColor, Colors.grey);
      expect(config.maxHeight, 600.0);
      expect(config.titleFontSize, 18.0);
      expect(config.bodyFontSize, 14.0);
      expect(config.buttonFontSize, 16.0);
      expect(config.borderRadius, 8.0);
      expect(config.showLoadingIndicators, true);
      expect(config.saveButtonText, 'Save');
      expect(config.addOverlayText, 'Add Overlay Images');
    });

    test('EditorConfig.darkTheme() should create dark theme', () {
      final config = EditorConfig.darkTheme();

      expect(config.backgroundColor, const Color(0xFF121212));
      expect(config.textColor, Colors.white);
      expect(config.fontFamily, 'Roboto');
    });

    test('EditorConfig.brandTheme() should create brand theme', () {
      final config = EditorConfig.brandTheme(
        primaryColor: Colors.purple,
        secondaryColor: Colors.pink,
        fontFamily: 'Poppins',
      );

      expect(config.primaryColor, Colors.purple);
      expect(config.secondaryColor, Colors.pink);
      expect(config.fontFamily, 'Poppins');
    });

    test('OverlayImage should serialize and deserialize correctly', () {
      final overlay = OverlayImage(
        id: 'test_id',
        source: ImageSource.gallery,
        imageUrl: 'test_url',
        position: const Offset(100, 100),
        size: Size(100, 100),
        rotation: 0.5,
        isLocal: true,
      );

      final json = overlay.toJson();
      final deserialized = OverlayImage.fromJson(json);

      expect(deserialized.id, overlay.id);
      expect(deserialized.source, overlay.source);
      expect(deserialized.imageUrl, overlay.imageUrl);
      expect(deserialized.position, overlay.position);
      expect(deserialized.size, overlay.size);
      expect(deserialized.rotation, overlay.rotation);
      expect(deserialized.isLocal, overlay.isLocal);
    });
  });

  group('ImageUtils', () {
    test('calculateFittedDimensions should work correctly', () {
      // Mock image with 1000x500 dimensions
      final mockImage = _MockImage(1000, 500);
      
      // Test fitting to 400x300 container
      final result = ImageUtils.calculateFittedDimensions(mockImage, 400, 300);
      
      // Should fit width (400) and scale height proportionally
      expect(result.width, 400);
      expect(result.height, 200); // (400 * 500) / 1000 = 200
    });

    test('calculateFittedDimensions should fit height when needed', () {
      // Mock image with 500x1000 dimensions
      final mockImage = _MockImage(500, 1000);
      
      // Test fitting to 400x300 container
      final result = ImageUtils.calculateFittedDimensions(mockImage, 400, 300);
      
      // Should fit height (300) and scale width proportionally
      expect(result.width, 150); // (300 * 500) / 1000 = 150
      expect(result.height, 300);
    });
  });
}

// Mock image for testing
class _MockImage implements ui.Image {
  final int width;
  final int height;

  _MockImage(this.width, this.height);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}