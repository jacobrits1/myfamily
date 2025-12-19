import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

// Storage service for file operations
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // Get documents directory
  Future<Directory> getDocumentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final documentsDir = Directory(path.join(appDir.path, 'documents'));
    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }
    return documentsDir;
  }

  // Get images directory
  Future<Directory> getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(path.join(appDir.path, 'images'));
    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }
    return imagesDir;
  }

  // Save file to documents directory
  Future<String> saveFile(File file, String fileName) async {
    final documentsDir = await getDocumentsDirectory();
    final savedFile = await file.copy(path.join(documentsDir.path, fileName));
    return savedFile.path;
  }

  // Get file by path
  File getFile(String filePath) {
    return File(filePath);
  }

  // Delete file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Check if file exists
  Future<bool> fileExists(String filePath) async {
    final file = File(filePath);
    return await file.exists();
  }

  // Save image file
  Future<String> saveImage(File imageFile, String fileName) async {
    final imagesDir = await getImagesDirectory();
    final savedFile = await imageFile.copy(path.join(imagesDir.path, fileName));
    return savedFile.path;
  }
}

