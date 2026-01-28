import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/family_member.dart';
import '../models/custom_field.dart';
import '../models/document.dart';
import '../models/calendar_event.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../utils/constants.dart';

// Database service for SQLite operations
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  // Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    // Web platform doesn't support SQLite
    if (kIsWeb) {
      throw UnsupportedError('SQLite is not supported on web platform. Please use mobile platform.');
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Family members table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableFamilyMembers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        date_of_birth TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        city TEXT,
        state TEXT,
        zip_code TEXT,
        ssn TEXT,
        student_id TEXT,
        profile_image_path TEXT,
        is_self INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Custom fields table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCustomFields} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER NOT NULL,
        field_name TEXT NOT NULL,
        field_type TEXT NOT NULL,
        field_value TEXT NOT NULL,
        FOREIGN KEY (member_id) REFERENCES ${AppConstants.tableFamilyMembers} (id) ON DELETE CASCADE
      )
    ''');

    // Documents table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableDocuments} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        member_id INTEGER NOT NULL,
        file_name TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT NOT NULL,
        title TEXT,
        parsed_data TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (member_id) REFERENCES ${AppConstants.tableFamilyMembers} (id) ON DELETE CASCADE
      )
    ''');

    // Calendar events table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableCalendarEvents} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        event_date TEXT NOT NULL,
        end_date TEXT,
        category TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Checklists table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableChecklists} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        type TEXT NOT NULL,
        due_date TEXT,
        creator_id INTEGER,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (creator_id) REFERENCES ${AppConstants.tableFamilyMembers} (id) ON DELETE SET NULL
      )
    ''');

    // Shared lists table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSharedLists} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        shared_by_member_id INTEGER NOT NULL,
        shared_with_member_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (list_id) REFERENCES ${AppConstants.tableChecklists} (id) ON DELETE CASCADE,
        FOREIGN KEY (shared_by_member_id) REFERENCES ${AppConstants.tableFamilyMembers} (id) ON DELETE CASCADE,
        FOREIGN KEY (shared_with_member_id) REFERENCES ${AppConstants.tableFamilyMembers} (id) ON DELETE CASCADE,
        UNIQUE(list_id, shared_with_member_id)
      )
    ''');

    // Checklist items table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableChecklistItems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        text TEXT NOT NULL,
        is_checked INTEGER NOT NULL,
        item_order INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (list_id) REFERENCES ${AppConstants.tableChecklists} (id) ON DELETE CASCADE
      )
    ''');

    // Create indexes for better performance
    await db.execute(
        'CREATE INDEX idx_member_id_custom_fields ON ${AppConstants.tableCustomFields}(member_id)');
    await db.execute(
        'CREATE INDEX idx_member_id_documents ON ${AppConstants.tableDocuments}(member_id)');
    await db.execute(
        'CREATE INDEX idx_event_date ON ${AppConstants.tableCalendarEvents}(event_date)');
    await db.execute(
        'CREATE INDEX idx_list_id_items ON ${AppConstants.tableChecklistItems}(list_id)');
    await db.execute(
        'CREATE INDEX idx_checklist_due_date ON ${AppConstants.tableChecklists}(due_date)');
    await db.execute(
        'CREATE INDEX idx_is_self ON ${AppConstants.tableFamilyMembers}(is_self)');
    await db.execute(
        'CREATE INDEX idx_shared_lists_list_id ON ${AppConstants.tableSharedLists}(list_id)');
    await db.execute(
        'CREATE INDEX idx_shared_lists_shared_with ON ${AppConstants.tableSharedLists}(shared_with_member_id)');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add title column to documents table
      await db.execute('ALTER TABLE ${AppConstants.tableDocuments} ADD COLUMN title TEXT');
    }
    if (oldVersion < 3) {
      // Create calendar events table
      await db.execute('''
        CREATE TABLE ${AppConstants.tableCalendarEvents} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          event_date TEXT NOT NULL,
          category TEXT NOT NULL,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      await db.execute(
          'CREATE INDEX idx_event_date ON ${AppConstants.tableCalendarEvents}(event_date)');
    }
    if (oldVersion < 4) {
      // Add end_date column to calendar events table
      await db.execute(
          'ALTER TABLE ${AppConstants.tableCalendarEvents} ADD COLUMN end_date TEXT');
    }
    if (oldVersion < 5) {
      // Create checklists table
      await db.execute('''
        CREATE TABLE ${AppConstants.tableChecklists} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          type TEXT NOT NULL,
          due_date TEXT,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
      // Create checklist items table
      await db.execute('''
        CREATE TABLE ${AppConstants.tableChecklistItems} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          list_id INTEGER NOT NULL,
          text TEXT NOT NULL,
          is_checked INTEGER NOT NULL,
          item_order INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (list_id) REFERENCES ${AppConstants.tableChecklists} (id) ON DELETE CASCADE
        )
      ''');
      // Create indexes
      await db.execute(
          'CREATE INDEX idx_list_id_items ON ${AppConstants.tableChecklistItems}(list_id)');
      await db.execute(
          'CREATE INDEX idx_checklist_due_date ON ${AppConstants.tableChecklists}(due_date)');
    }
    if (oldVersion < 6) {
      // Add is_self column to family_members table
      await db.execute(
          'ALTER TABLE ${AppConstants.tableFamilyMembers} ADD COLUMN is_self INTEGER NOT NULL DEFAULT 0');
      // Create index for faster queries
      await db.execute(
          'CREATE INDEX idx_is_self ON ${AppConstants.tableFamilyMembers}(is_self)');
    }
    if (oldVersion < 7) {
      // Add creator_id column to checklists table
      await db.execute(
          'ALTER TABLE ${AppConstants.tableChecklists} ADD COLUMN creator_id INTEGER');
      // Create shared_lists table
      await db.execute('''
        CREATE TABLE ${AppConstants.tableSharedLists} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          list_id INTEGER NOT NULL,
          shared_by_member_id INTEGER NOT NULL,
          shared_with_member_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (list_id) REFERENCES ${AppConstants.tableChecklists} (id) ON DELETE CASCADE,
          FOREIGN KEY (shared_by_member_id) REFERENCES ${AppConstants.tableFamilyMembers} (id) ON DELETE CASCADE,
          FOREIGN KEY (shared_with_member_id) REFERENCES ${AppConstants.tableFamilyMembers} (id) ON DELETE CASCADE,
          UNIQUE(list_id, shared_with_member_id)
        )
      ''');
      // Create indexes
      await db.execute(
          'CREATE INDEX idx_shared_lists_list_id ON ${AppConstants.tableSharedLists}(list_id)');
      await db.execute(
          'CREATE INDEX idx_shared_lists_shared_with ON ${AppConstants.tableSharedLists}(shared_with_member_id)');
    }
  }

  // Family Member CRUD operations

  // Insert family member
  Future<int> insertFamilyMember(FamilyMember member) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableFamilyMembers,
      member.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all family members
  Future<List<FamilyMember>> getAllFamilyMembers() async {
    // Web platform doesn't support SQLite - return empty list
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query(AppConstants.tableFamilyMembers, orderBy: 'updated_at DESC');
      return List.generate(maps.length, (i) => FamilyMember.fromMap(maps[i]));
    } catch (e) {
      // Return empty list on error (e.g., database not initialized)
      return [];
    }
  }

  // Get family member by ID
  Future<FamilyMember?> getFamilyMemberById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableFamilyMembers,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return FamilyMember.fromMap(maps.first);
    }
    return null;
  }

  // Update family member
  Future<int> updateFamilyMember(FamilyMember member) async {
    final db = await database;
    return await db.update(
      AppConstants.tableFamilyMembers,
      member.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [member.id],
    );
  }

  // Delete family member
  Future<int> deleteFamilyMember(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableFamilyMembers,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Self member management methods

  // Get the member marked as self
  Future<FamilyMember?> getSelfMember() async {
    // Web platform doesn't support SQLite - return null
    if (kIsWeb) {
      return null;
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableFamilyMembers,
        where: 'is_self = ?',
        whereArgs: [1],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return FamilyMember.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Mark a member as self (unmark others)
  Future<void> setSelfMember(int memberId) async {
    final db = await database;
    final batch = db.batch();
    
    // Unmark all members as self
    batch.update(
      AppConstants.tableFamilyMembers,
      {'is_self': 0},
    );
    
    // Mark the specified member as self
    batch.update(
      AppConstants.tableFamilyMembers,
      {'is_self': 1},
      where: 'id = ?',
      whereArgs: [memberId],
    );
    
    await batch.commit(noResult: true);
  }

  // Unmark a member as self
  Future<void> unsetSelfMember(int memberId) async {
    final db = await database;
    await db.update(
      AppConstants.tableFamilyMembers,
      {'is_self': 0},
      where: 'id = ?',
      whereArgs: [memberId],
    );
  }

  // Custom Field CRUD operations

  // Insert custom field
  Future<int> insertCustomField(CustomField field) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableCustomFields,
      field.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get custom fields for a member
  Future<List<CustomField>> getCustomFieldsForMember(int memberId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCustomFields,
      where: 'member_id = ?',
      whereArgs: [memberId],
    );
    return List.generate(maps.length, (i) => CustomField.fromMap(maps[i]));
  }

  // Update custom field
  Future<int> updateCustomField(CustomField field) async {
    final db = await database;
    return await db.update(
      AppConstants.tableCustomFields,
      field.toMap(),
      where: 'id = ?',
      whereArgs: [field.id],
    );
  }

  // Delete custom field
  Future<int> deleteCustomField(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableCustomFields,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Document CRUD operations

  // Insert document
  Future<int> insertDocument(Document document) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableDocuments,
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get documents for a member
  Future<List<Document>> getDocumentsForMember(int memberId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableDocuments,
      where: 'member_id = ?',
      whereArgs: [memberId],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  // Get document by ID
  Future<Document?> getDocumentById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableDocuments,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Document.fromMap(maps.first);
    }
    return null;
  }

  // Update document
  Future<int> updateDocument(Document document) async {
    final db = await database;
    return await db.update(
      AppConstants.tableDocuments,
      document.toMap(),
      where: 'id = ?',
      whereArgs: [document.id],
    );
  }

  // Delete document
  Future<int> deleteDocument(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableDocuments,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Search family members by name
  Future<List<FamilyMember>> searchFamilyMembers(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableFamilyMembers,
      where: 'first_name LIKE ? OR last_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'updated_at DESC',
    );
    return List.generate(maps.length, (i) => FamilyMember.fromMap(maps[i]));
  }

  // Calendar Event CRUD operations

  // Insert calendar event
  Future<int> insertCalendarEvent(CalendarEvent event) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableCalendarEvents,
      event.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all calendar events
  Future<List<CalendarEvent>> getAllCalendarEvents() async {
    // Web platform doesn't support SQLite - return empty list
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableCalendarEvents,
        orderBy: 'event_date ASC, created_at ASC',
      );
      return List.generate(maps.length, (i) => CalendarEvent.fromMap(maps[i]));
    } catch (e) {
      // Return empty list on error (e.g., database not initialized)
      return [];
    }
  }

  // Get calendar events by date
  Future<List<CalendarEvent>> getCalendarEventsByDate(DateTime date) async {
    // Web platform doesn't support SQLite - return empty list
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      // Format date to compare only date part (YYYY-MM-DD)
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableCalendarEvents,
        where: "DATE(event_date) = DATE(?)",
        whereArgs: [dateStr],
        orderBy: 'event_date ASC',
      );
      return List.generate(maps.length, (i) => CalendarEvent.fromMap(maps[i]));
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  // Get calendar event by ID
  Future<CalendarEvent?> getCalendarEventById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableCalendarEvents,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return CalendarEvent.fromMap(maps.first);
    }
    return null;
  }

  // Update calendar event
  Future<int> updateCalendarEvent(CalendarEvent event) async {
    final db = await database;
    return await db.update(
      AppConstants.tableCalendarEvents,
      event.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  // Delete calendar event
  Future<int> deleteCalendarEvent(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableCalendarEvents,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Checklist CRUD operations

  // Insert checklist
  Future<int> insertChecklist(Checklist checklist) async {
    final db = await database;
    // If creator_id is not set, try to get it from self member
    if (checklist.creatorId == null) {
      final selfMember = await getSelfMember();
      if (selfMember?.id != null) {
        final checklistWithCreator = checklist.copyWith(creatorId: selfMember!.id);
        return await db.insert(
          AppConstants.tableChecklists,
          checklistWithCreator.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
    return await db.insert(
      AppConstants.tableChecklists,
      checklist.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all checklists
  Future<List<Checklist>> getAllChecklists() async {
    // Web platform doesn't support SQLite - return empty list
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableChecklists,
        orderBy: 'updated_at DESC',
      );
      return List.generate(maps.length, (i) => Checklist.fromMap(maps[i]));
    } catch (e) {
      // Return empty list on error (e.g., database not initialized)
      return [];
    }
  }

  // Get checklist by ID
  Future<Checklist?> getChecklistById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableChecklists,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Checklist.fromMap(maps.first);
    }
    return null;
  }

  // Update checklist
  Future<int> updateChecklist(Checklist checklist) async {
    final db = await database;
    return await db.update(
      AppConstants.tableChecklists,
      checklist.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [checklist.id],
    );
  }

  // Delete checklist
  Future<int> deleteChecklist(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableChecklists,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get checklists by due date
  Future<List<Checklist>> getChecklistsByDueDate(DateTime date) async {
    // Web platform doesn't support SQLite - return empty list
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      // Format date to compare only date part (YYYY-MM-DD)
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableChecklists,
        where: "DATE(due_date) = DATE(?)",
        whereArgs: [dateStr],
        orderBy: 'due_date ASC',
      );
      return List.generate(maps.length, (i) => Checklist.fromMap(maps[i]));
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  // Checklist Item CRUD operations

  // Insert checklist item
  Future<int> insertChecklistItem(ChecklistItem item) async {
    final db = await database;
    return await db.insert(
      AppConstants.tableChecklistItems,
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get checklist items by list ID
  Future<List<ChecklistItem>> getChecklistItemsByListId(int listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableChecklistItems,
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'item_order ASC',
    );
    return List.generate(maps.length, (i) => ChecklistItem.fromMap(maps[i]));
  }

  // Update checklist item
  Future<int> updateChecklistItem(ChecklistItem item) async {
    final db = await database;
    return await db.update(
      AppConstants.tableChecklistItems,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Delete checklist item
  Future<int> deleteChecklistItem(int id) async {
    final db = await database;
    return await db.delete(
      AppConstants.tableChecklistItems,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Update checklist item order (for drag-and-drop reordering)
  Future<void> updateChecklistItemOrder(int listId, List<int> itemIds) async {
    final db = await database;
    final batch = db.batch();
    for (int i = 0; i < itemIds.length; i++) {
      batch.update(
        AppConstants.tableChecklistItems,
        {'item_order': i},
        where: 'id = ? AND list_id = ?',
        whereArgs: [itemIds[i], listId],
      );
    }
    await batch.commit(noResult: true);
  }

  // Get checklist completion percentage
  Future<double> getChecklistCompletionPercentage(int listId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableChecklistItems,
      where: 'list_id = ?',
      whereArgs: [listId],
    );
    if (maps.isEmpty) return 0.0;
    final totalItems = maps.length;
    final checkedItems = maps.where((map) => (map['is_checked'] as int) == 1).length;
    return (checkedItems / totalItems) * 100;
  }

  // Backup/Restore methods

  // Get all custom fields (for backup)
  Future<List<CustomField>> getAllCustomFields() async {
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query(AppConstants.tableCustomFields);
      return List.generate(maps.length, (i) => CustomField.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  // Get all documents (for backup)
  Future<List<Document>> getAllDocuments() async {
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query(AppConstants.tableDocuments, orderBy: 'created_at DESC');
      return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  // Get all checklist items (for backup)
  Future<List<ChecklistItem>> getAllChecklistItems() async {
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps =
          await db.query(AppConstants.tableChecklistItems, orderBy: 'item_order ASC');
      return List.generate(maps.length, (i) => ChecklistItem.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  // Restore methods - clear and restore data

  // Clear all data (for restore - use with caution)
  Future<void> clearAllData() async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final batch = db.batch();
    
    // Delete in order to respect foreign keys
    batch.delete(AppConstants.tableChecklistItems);
    batch.delete(AppConstants.tableChecklists);
    batch.delete(AppConstants.tableCustomFields);
    batch.delete(AppConstants.tableDocuments);
    batch.delete(AppConstants.tableCalendarEvents);
    batch.delete(AppConstants.tableFamilyMembers);
    
    await batch.commit(noResult: true);
  }

  // Restore family members (for restore)
  Future<void> restoreFamilyMembers(List<FamilyMember> members) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final batch = db.batch();
    
    for (final member in members) {
      batch.insert(
        AppConstants.tableFamilyMembers,
        member.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Restore custom fields (for restore)
  Future<void> restoreCustomFields(List<CustomField> fields) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final batch = db.batch();
    
    for (final field in fields) {
      batch.insert(
        AppConstants.tableCustomFields,
        field.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Restore documents (for restore)
  Future<void> restoreDocuments(List<Document> documents) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final batch = db.batch();
    
    for (final document in documents) {
      batch.insert(
        AppConstants.tableDocuments,
        document.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Restore calendar events (for restore)
  Future<void> restoreCalendarEvents(List<CalendarEvent> events) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final batch = db.batch();
    
    for (final event in events) {
      batch.insert(
        AppConstants.tableCalendarEvents,
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Restore checklists (for restore)
  Future<void> restoreChecklists(List<Checklist> checklists) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final batch = db.batch();
    
    for (final checklist in checklists) {
      batch.insert(
        AppConstants.tableChecklists,
        checklist.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Restore checklist items (for restore)
  Future<void> restoreChecklistItems(List<ChecklistItem> items) async {
    if (kIsWeb) {
      return;
    }

    final db = await database;
    final batch = db.batch();
    
    for (final item in items) {
      batch.insert(
        AppConstants.tableChecklistItems,
        item.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    await batch.commit(noResult: true);
  }

  // Shared Lists operations

  // Share a list with a member
  Future<int> shareListWithMember(int listId, int sharedByMemberId, int sharedWithMemberId) async {
    if (kIsWeb) {
      return 0;
    }

    try {
      final db = await database;
      // Check if already shared
      final existing = await db.query(
        AppConstants.tableSharedLists,
        where: 'list_id = ? AND shared_with_member_id = ?',
        whereArgs: [listId, sharedWithMemberId],
      );
      if (existing.isNotEmpty) {
        return existing.first['id'] as int;
      }

      return await db.insert(
        AppConstants.tableSharedLists,
        {
          'list_id': listId,
          'shared_by_member_id': sharedByMemberId,
          'shared_with_member_id': sharedWithMemberId,
          'created_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      return 0;
    }
  }

  // Unshare a list with a member
  Future<int> unshareListWithMember(int listId, int sharedWithMemberId) async {
    if (kIsWeb) {
      return 0;
    }

    try {
      final db = await database;
      return await db.delete(
        AppConstants.tableSharedLists,
        where: 'list_id = ? AND shared_with_member_id = ?',
        whereArgs: [listId, sharedWithMemberId],
      );
    } catch (e) {
      return 0;
    }
  }

  // Get all members a list is shared with
  Future<List<FamilyMember>> getSharedMembersForList(int listId) async {
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT fm.* FROM ${AppConstants.tableFamilyMembers} fm
        INNER JOIN ${AppConstants.tableSharedLists} sl ON fm.id = sl.shared_with_member_id
        WHERE sl.list_id = ?
      ''', [listId]);
      return List.generate(maps.length, (i) => FamilyMember.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  // Check if list is already shared with a member
  Future<bool> isListSharedWithMember(int listId, int memberId) async {
    if (kIsWeb) {
      return false;
    }

    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.tableSharedLists,
        where: 'list_id = ? AND shared_with_member_id = ?',
        whereArgs: [listId, memberId],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Get lists shared with me (returns Checklist with creator and sharer info)
  Future<List<Map<String, dynamic>>> getListsSharedWithMe(int memberId) async {
    if (kIsWeb) {
      return [];
    }

    try {
      final db = await database;
      // Join to get checklist, creator info, and sharer info
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          c.*,
          creator.id as creator_member_id,
          creator.first_name as creator_first_name,
          creator.last_name as creator_last_name,
          sharer.id as sharer_member_id,
          sharer.first_name as sharer_first_name,
          sharer.last_name as sharer_last_name
        FROM ${AppConstants.tableChecklists} c
        INNER JOIN ${AppConstants.tableSharedLists} sl ON c.id = sl.list_id
        LEFT JOIN ${AppConstants.tableFamilyMembers} creator ON c.creator_id = creator.id
        LEFT JOIN ${AppConstants.tableFamilyMembers} sharer ON sl.shared_by_member_id = sharer.id
        WHERE sl.shared_with_member_id = ?
        ORDER BY c.updated_at DESC
      ''', [memberId]);
      return maps;
    } catch (e) {
      return [];
    }
  }

  // Delete all sharing relationships for a checklist (when checklist is deleted)
  Future<int> deleteSharedListsForChecklist(int listId) async {
    if (kIsWeb) {
      return 0;
    }

    try {
      final db = await database;
      return await db.delete(
        AppConstants.tableSharedLists,
        where: 'list_id = ?',
        whereArgs: [listId],
      );
    } catch (e) {
      return 0;
    }
  }
}

