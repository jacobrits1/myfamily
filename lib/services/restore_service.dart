import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/backup_data.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'storage_service.dart';
import 'backup_service.dart';

// Restore service for downloading and restoring backups
class RestoreService {
  static final RestoreService _instance = RestoreService._internal();
  factory RestoreService() => _instance;
  RestoreService._internal();

  final DatabaseService _dbService = DatabaseService();
  final StorageService _storageService = StorageService();
  final BackupService _backupService = BackupService();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Download backup data from Supabase
  Future<BackupData> downloadBackup(
    String backupId,
    String userEmail,
  ) async {
    try {
      return await _backupService.getBackupData(backupId, userEmail);
    } catch (e) {
      throw Exception('Error downloading backup: $e');
    }
  }

  // Download files from Supabase Storage
  Future<Map<String, String>> downloadFiles(
    String userEmail,
    String backupId,
    BackupData backupData,
    Function(String)? onProgress,
  ) async {
    final fileMap = <String, String>{}; // Maps Supabase path to local path

    // Download documents
    onProgress?.call('Downloading documents...');
    for (final document in backupData.documents) {
      if (document.filePath.isNotEmpty &&
          document.filePath.startsWith('${_sanitizeEmail(userEmail)}/')) {
        try {
          // Download from Supabase Storage
          final fileBytes = await _supabase.storage
              .from(AppConstants.storageBucketBackups)
              .download(document.filePath);

          // Save to local storage
          final documentsDir = await _storageService.getDocumentsDirectory();
          final fileName = document.fileName;
          final localPath = '${documentsDir.path}/$fileName';

          final file = File(localPath);
          await file.writeAsBytes(fileBytes);

          fileMap[document.filePath] = localPath;
        } catch (e) {
          // Continue with other files even if one fails
          print('Error downloading document ${document.fileName}: $e');
        }
      }
    }

    // Download profile images
    onProgress?.call('Downloading profile images...');
    for (final member in backupData.familyMembers) {
      if (member.profileImagePath != null &&
          member.profileImagePath!.isNotEmpty &&
          member.profileImagePath!.startsWith(
              '${_sanitizeEmail(userEmail)}/')) {
        try {
          // Download from Supabase Storage
          final fileBytes = await _supabase.storage
              .from(AppConstants.storageBucketProfileImages)
              .download(member.profileImagePath!);

          // Save to local storage
          final imagesDir = await _storageService.getImagesDirectory();
          final fileName = member.profileImagePath!.split('/').last;
          final localPath = '${imagesDir.path}/$fileName';

          final file = File(localPath);
          await file.writeAsBytes(fileBytes);

          fileMap[member.profileImagePath!] = localPath;
        } catch (e) {
          // Continue with other files even if one fails
          print('Error downloading profile image for ${member.fullName}: $e');
        }
      }
    }

    return fileMap;
  }

  // Validate backup data before restore
  Future<bool> validateBackup(BackupData backupData) async {
    try {
      // Check version compatibility
      if (backupData.version != AppConstants.backupVersion) {
        // Allow restore but warn about version mismatch
        print('Warning: Backup version ${backupData.version} differs from current version ${AppConstants.backupVersion}');
      }

      // Validate data structure
      if (backupData.familyMembers.isEmpty &&
          backupData.documents.isEmpty &&
          backupData.calendarEvents.isEmpty &&
          backupData.checklists.isEmpty) {
        throw Exception('Backup appears to be empty');
      }

      // Validate relationships
      // Check that all custom fields reference valid members
      final memberIds = backupData.familyMembers
          .where((m) => m.id != null)
          .map((m) => m.id!)
          .toSet();
      for (final field in backupData.customFields) {
        if (!memberIds.contains(field.memberId)) {
          throw Exception(
              'Custom field references non-existent member: ${field.memberId}');
        }
      }

      // Check that all documents reference valid members
      for (final doc in backupData.documents) {
        if (!memberIds.contains(doc.memberId)) {
          throw Exception(
              'Document references non-existent member: ${doc.memberId}');
        }
      }

      // Check that all checklist items reference valid checklists
      final checklistIds = backupData.checklists
          .where((c) => c.id != null)
          .map((c) => c.id!)
          .toSet();
      for (final item in backupData.checklistItems) {
        if (!checklistIds.contains(item.listId)) {
          throw Exception(
              'Checklist item references non-existent checklist: ${item.listId}');
        }
      }

      return true;
    } catch (e) {
      throw Exception('Backup validation failed: $e');
    }
  }

  // Restore data to local SQLite database
  Future<void> restoreData(
    BackupData backupData,
    Map<String, String> fileMap, {
    bool clearExisting = true,
    Function(String)? onProgress,
  }) async {
    try {
      // Validate backup first
      onProgress?.call('Validating backup...');
      await validateBackup(backupData);

      // Clear existing data if requested
      if (clearExisting) {
        onProgress?.call('Clearing existing data...');
        await _dbService.clearAllData();
      }

      // Update file paths in backup data to reference local paths
      final updatedDocuments = backupData.documents.map((doc) {
        if (fileMap.containsKey(doc.filePath)) {
          return doc.copyWith(filePath: fileMap[doc.filePath]!);
        }
        return doc;
      }).toList();

      final updatedMembers = backupData.familyMembers.map((member) {
        if (member.profileImagePath != null &&
            fileMap.containsKey(member.profileImagePath)) {
          return member.copyWith(
              profileImagePath: fileMap[member.profileImagePath]);
        }
        return member;
      }).toList();

      // Restore data in correct order (respecting foreign keys)
      onProgress?.call('Restoring family members...');
      await _dbService.restoreFamilyMembers(updatedMembers);

      onProgress?.call('Restoring custom fields...');
      await _dbService.restoreCustomFields(backupData.customFields);

      onProgress?.call('Restoring documents...');
      await _dbService.restoreDocuments(updatedDocuments);

      onProgress?.call('Restoring calendar events...');
      await _dbService.restoreCalendarEvents(backupData.calendarEvents);

      onProgress?.call('Restoring checklists...');
      await _dbService.restoreChecklists(backupData.checklists);

      onProgress?.call('Restoring checklist items...');
      await _dbService.restoreChecklistItems(backupData.checklistItems);

      onProgress?.call('Restore complete!');
    } catch (e) {
      throw Exception('Error restoring data: $e');
    }
  }

  // Perform complete restore
  Future<void> performRestore(
    String backupId,
    String userEmail, {
    bool clearExisting = true,
    Function(String)? onProgress,
  }) async {
    try {
      // Download backup data
      onProgress?.call('Downloading backup data...');
      final backupData = await downloadBackup(backupId, userEmail);

      // Download files
      final fileMap = await downloadFiles(userEmail, backupId, backupData, onProgress);

      // Restore data
      await restoreData(backupData, fileMap,
          clearExisting: clearExisting, onProgress: onProgress);
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }

  // Sanitize email for use in file paths
  String _sanitizeEmail(String email) {
    return email.replaceAll('@', '_at_').replaceAll('.', '_');
  }
}
