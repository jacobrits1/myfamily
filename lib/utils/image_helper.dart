import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// Platform-aware image helper for cross-platform image loading
class ImageHelper {
  // Get image provider that works on both web and mobile
  static ImageProvider getImageProvider(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      throw ArgumentError('Image path cannot be null or empty');
    }

    // On web, use NetworkImage for blob URLs or file paths
    if (kIsWeb) {
      // Check if it's a blob URL
      if (imagePath.startsWith('blob:') || imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return NetworkImage(imagePath);
      }
      // For web file paths, try as network image
      return NetworkImage(imagePath);
    }

    // On mobile, use FileImage
    return FileImage(File(imagePath));
  }

  // Get image widget that works on both web and mobile
  static Widget getImageWidget(String? imagePath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
  }) {
    if (imagePath == null || imagePath.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: Colors.grey[300],
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }

    // On web, use Image.network for blob URLs
    if (kIsWeb) {
      if (imagePath.startsWith('blob:') || imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        return Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            );
          },
        );
      }
      // Try as network image for web file paths
      return Image.network(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey[300],
            child: const Icon(Icons.broken_image, color: Colors.grey),
          );
        },
      );
    }

    // On mobile, use Image.file
    return Image.file(
      File(imagePath),
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      },
    );
  }

  // Convert XFile to bytes for web compatibility
  static Future<Uint8List?> getImageBytes(XFile? file) async {
    if (file == null) return null;
    try {
      return await file.readAsBytes();
    } catch (e) {
      return null;
    }
  }

  // Get image path from XFile (handles web blob URLs)
  static String getImagePath(XFile file) {
    return file.path;
  }

  // Check if path is a blob URL (web)
  static bool isBlobUrl(String path) {
    return path.startsWith('blob:');
  }

  // Convert XFile to blob URL on web (for web compatibility)
  static Future<String?> convertToBlobUrl(XFile file) async {
    if (!kIsWeb) return file.path;
    
    try {
      // If already a blob URL, return it
      if (file.path.startsWith('blob:')) {
        return file.path;
      }
      
      // Read bytes and create blob URL
      final bytes = await file.readAsBytes();
      return _createBlobUrl(bytes);
    } catch (e) {
      return null;
    }
  }

  // Create blob URL from bytes (web only)
  static String? _createBlobUrl(Uint8List bytes) {
    if (!kIsWeb) return null;
    
    // On web, create a blob URL from bytes
    // Note: This requires using dart:html or a package that handles blob URLs
    // For now, we'll use a data URL as fallback
    final base64 = base64Encode(bytes);
    return 'data:image/jpeg;base64,$base64';
  }
}

