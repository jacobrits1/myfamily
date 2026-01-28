import 'family_member.dart';
import 'custom_field.dart';
import 'document.dart';
import 'calendar_event.dart';
import 'checklist.dart';
import 'checklist_item.dart';

// Backup data model - represents complete app data snapshot
class BackupData {
  final String version;
  final DateTime backupTimestamp;
  final List<FamilyMember> familyMembers;
  final List<CustomField> customFields;
  final List<Document> documents;
  final List<CalendarEvent> calendarEvents;
  final List<Checklist> checklists;
  final List<ChecklistItem> checklistItems;
  final Map<String, dynamic>? settings;

  BackupData({
    required this.version,
    required this.backupTimestamp,
    required this.familyMembers,
    required this.customFields,
    required this.documents,
    required this.calendarEvents,
    required this.checklists,
    required this.checklistItems,
    this.settings,
  });

  // Convert to Map for JSON serialization
  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'backup_timestamp': backupTimestamp.toIso8601String(),
      'family_members': familyMembers.map((m) => m.toMap()).toList(),
      'custom_fields': customFields.map((f) => f.toMap()).toList(),
      'documents': documents.map((d) => d.toMap()).toList(),
      'calendar_events': calendarEvents.map((e) => e.toMap()).toList(),
      'checklists': checklists.map((c) => c.toMap()).toList(),
      'checklist_items': checklistItems.map((i) => i.toMap()).toList(),
      'settings': settings ?? {},
    };
  }

  // Create from Map (JSON deserialization)
  factory BackupData.fromMap(Map<String, dynamic> map) {
    return BackupData(
      version: map['version'] as String? ?? '1.0.0',
      backupTimestamp: map['backup_timestamp'] != null
          ? DateTime.parse(map['backup_timestamp'] as String)
          : DateTime.now(),
      familyMembers: (map['family_members'] as List<dynamic>?)
              ?.map((m) => FamilyMember.fromMap(m as Map<String, dynamic>))
              .toList() ??
          [],
      customFields: (map['custom_fields'] as List<dynamic>?)
              ?.map((f) => CustomField.fromMap(f as Map<String, dynamic>))
              .toList() ??
          [],
      documents: (map['documents'] as List<dynamic>?)
              ?.map((d) => Document.fromMap(d as Map<String, dynamic>))
              .toList() ??
          [],
      calendarEvents: (map['calendar_events'] as List<dynamic>?)
              ?.map((e) => CalendarEvent.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      checklists: (map['checklists'] as List<dynamic>?)
              ?.map((c) => Checklist.fromMap(c as Map<String, dynamic>))
              .toList() ??
          [],
      checklistItems: (map['checklist_items'] as List<dynamic>?)
              ?.map((i) => ChecklistItem.fromMap(i as Map<String, dynamic>))
              .toList() ??
          [],
      settings: map['settings'] as Map<String, dynamic>?,
    );
  }

  // Note: For JSON serialization, use toMap() and fromMap() with jsonEncode/jsonDecode
}

// Backup record model for Supabase
class BackupRecord {
  final String id;
  final String userEmail;
  final DateTime backupTimestamp;
  final String backupVersion;
  final DateTime createdAt;

  BackupRecord({
    required this.id,
    required this.userEmail,
    required this.backupTimestamp,
    required this.backupVersion,
    required this.createdAt,
  });

  // Convert to Map for Supabase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_email': userEmail,
      'backup_timestamp': backupTimestamp.toIso8601String(),
      'backup_version': backupVersion,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map (Supabase result)
  factory BackupRecord.fromMap(Map<String, dynamic> map) {
    return BackupRecord(
      id: map['id'] as String,
      userEmail: map['user_email'] as String,
      backupTimestamp: map['backup_timestamp'] != null
          ? DateTime.parse(map['backup_timestamp'] as String)
          : DateTime.now(),
      backupVersion: map['backup_version'] as String? ?? '1.0.0',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }
}
