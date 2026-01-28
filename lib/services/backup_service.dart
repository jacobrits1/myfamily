import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/backup_data.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'storage_service.dart';

// Backup service for Supabase operations
class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final DatabaseService _dbService = DatabaseService();
  final SupabaseClient _supabase = Supabase.instance.client;
  final _uuid = const Uuid();

  // Collect all data from local database
  Future<BackupData> collectAllData() async {
    // Get all data from database
    final familyMembers = await _dbService.getAllFamilyMembers();
    final customFields = await _dbService.getAllCustomFields();
    final documents = await _dbService.getAllDocuments();
    final calendarEvents = await _dbService.getAllCalendarEvents();
    final checklists = await _dbService.getAllChecklists();
    final checklistItems = await _dbService.getAllChecklistItems();

    // Create backup data object
    return BackupData(
      version: AppConstants.backupVersion,
      backupTimestamp: DateTime.now(),
      familyMembers: familyMembers,
      customFields: customFields,
      documents: documents,
      calendarEvents: calendarEvents,
      checklists: checklists,
      checklistItems: checklistItems,
      settings: {}, // Settings can be added later
    );
  }

  // Upload files to Supabase Storage
  Future<Map<String, String>> uploadFiles(
    String userEmail,
    String backupId,
    BackupData backupData,
    Function(String)? onProgress,
  ) async {
    final fileMap = <String, String>{}; // Maps original path to Supabase path

    // Upload documents
    onProgress?.call('Uploading documents...');
    for (final document in backupData.documents) {
      if (document.filePath.isNotEmpty) {
        try {
          final file = File(document.filePath);
          if (await file.exists()) {
            final fileName = document.fileName;
            final storagePath =
                '${_sanitizeEmail(userEmail)}/$backupId/documents/$fileName';

            // Upload to Supabase Storage
            await _supabase.storage
                .from(AppConstants.storageBucketBackups)
                .upload(
                  storagePath,
                  file,
                  fileOptions: const FileOptions(upsert: true),
                );

            fileMap[document.filePath] = storagePath;
          }
        } catch (e) {
          // Continue with other files even if one fails
          print('Error uploading document ${document.fileName}: $e');
        }
      }
    }

    // Upload profile images
    onProgress?.call('Uploading profile images...');
    for (final member in backupData.familyMembers) {
      if (member.profileImagePath != null &&
          member.profileImagePath!.isNotEmpty) {
        try {
          final file = File(member.profileImagePath!);
          if (await file.exists()) {
            final fileName = file.path.split('/').last;
            final storagePath =
                '${_sanitizeEmail(userEmail)}/$backupId/images/$fileName';

            // Upload to Supabase Storage
            await _supabase.storage
                .from(AppConstants.storageBucketProfileImages)
                .upload(
                  storagePath,
                  file,
                  fileOptions: const FileOptions(upsert: true),
                );

            fileMap[member.profileImagePath!] = storagePath;
          }
        } catch (e) {
          // Continue with other files even if one fails
          print('Error uploading profile image for ${member.fullName}: $e');
        }
      }
    }

    return fileMap;
  }

  // Create backup in Supabase
  Future<String> createBackup(
    String userEmail,
    BackupData backupData,
    Map<String, String> fileMap,
    Function(String)? onProgress,
  ) async {
    try {
      // Validate email
      if (userEmail.isEmpty || !userEmail.contains('@')) {
        throw Exception('Invalid email address');
      }

      final backupId = _uuid.v4();
      final backupTimestamp = DateTime.now();

      onProgress?.call('Creating backup record...');

      // Update file paths in backup data to reference Supabase paths
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

      // Create updated backup data with Supabase file paths
      final updatedBackupData = BackupData(
        version: backupData.version,
        backupTimestamp: backupData.backupTimestamp,
        familyMembers: updatedMembers,
        customFields: backupData.customFields,
        documents: updatedDocuments,
        calendarEvents: backupData.calendarEvents,
        checklists: backupData.checklists,
        checklistItems: backupData.checklistItems,
        settings: backupData.settings,
      );

      // Insert backup record into Supabase
      final response = await _supabase.from('user_backups').insert({
        'id': backupId,
        'user_email': userEmail,
        'backup_timestamp': backupTimestamp.toIso8601String(),
        'backup_version': AppConstants.backupVersion,
        'data_snapshot': updatedBackupData.toMap(),
        'created_at': DateTime.now().toIso8601String(),
      }).select();

      if (response.isEmpty) {
        throw Exception('Failed to create backup record');
      }

      return backupId;
    } catch (e) {
      throw Exception('Error creating backup: $e');
    }
  }

  // Get all backups for a user
  Future<List<BackupRecord>> getBackups(String userEmail) async {
    try {
      if (userEmail.isEmpty || !userEmail.contains('@')) {
        throw Exception('Invalid email address');
      }

      final response = await _supabase
          .from('user_backups')
          .select()
          .eq('user_email', userEmail)
          .order('backup_timestamp', ascending: false);

      return List<Map<String, dynamic>>.from(response)
          .map((map) => BackupRecord.fromMap(map))
          .toList();
    } catch (e) {
      throw Exception('Error fetching backups: $e');
    }
  }

  // Get backup data by ID
  Future<BackupData> getBackupData(String backupId, String userEmail) async {
    try {
      final response = await _supabase
          .from('user_backups')
          .select()
          .eq('id', backupId)
          .eq('user_email', userEmail)
          .single();

      final data = response as Map<String, dynamic>;
      final dataSnapshot = data['data_snapshot'] as Map<String, dynamic>;
      return BackupData.fromMap(dataSnapshot);
    } catch (e) {
      throw Exception('Error fetching backup data: $e');
    }
  }

  // Delete backup
  Future<void> deleteBackup(String backupId, String userEmail) async {
    try {
      // Get backup to find file paths
      final backupData = await getBackupData(backupId, userEmail);

      // Delete files from storage
      try {
        // Delete documents
        for (final doc in backupData.documents) {
          if (doc.filePath.isNotEmpty &&
              doc.filePath.startsWith('${_sanitizeEmail(userEmail)}/')) {
            await _supabase.storage
                .from(AppConstants.storageBucketBackups)
                .remove([doc.filePath]);
          }
        }

        // Delete profile images
        for (final member in backupData.familyMembers) {
          if (member.profileImagePath != null &&
              member.profileImagePath!.isNotEmpty &&
              member.profileImagePath!.startsWith(
                  '${_sanitizeEmail(userEmail)}/')) {
            await _supabase.storage
                .from(AppConstants.storageBucketProfileImages)
                .remove([member.profileImagePath!]);
          }
        }
      } catch (e) {
        // Continue even if file deletion fails
        print('Error deleting files: $e');
      }

      // Delete backup record
      await _supabase
          .from('user_backups')
          .delete()
          .eq('id', backupId)
          .eq('user_email', userEmail);
    } catch (e) {
      throw Exception('Error deleting backup: $e');
    }
  }

  // Perform complete backup
  Future<String> performBackup(
    String userEmail,
    Function(String)? onProgress,
  ) async {
    try {
      // Collect all data
      onProgress?.call('Collecting data...');
      final backupData = await collectAllData();

      // Generate backup ID
      final backupId = _uuid.v4();

      // Upload files
      final fileMap = await uploadFiles(userEmail, backupId, backupData, onProgress);

      // Create backup record
      final createdBackupId =
          await createBackup(userEmail, backupData, fileMap, onProgress);

      return createdBackupId;
    } catch (e) {
      throw Exception('Backup failed: $e');
    }
  }

  // Sanitize email for use in file paths
  String _sanitizeEmail(String email) {
    return email.replaceAll('@', '_at_').replaceAll('.', '_');
  }
}
