import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/family_member.dart';
import '../models/custom_field.dart';
import '../models/document.dart';
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

    // Create indexes for better performance
    await db.execute(
        'CREATE INDEX idx_member_id_custom_fields ON ${AppConstants.tableCustomFields}(member_id)');
    await db.execute(
        'CREATE INDEX idx_member_id_documents ON ${AppConstants.tableDocuments}(member_id)');
  }

  // Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add title column to documents table
      await db.execute('ALTER TABLE ${AppConstants.tableDocuments} ADD COLUMN title TEXT');
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
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query(AppConstants.tableFamilyMembers, orderBy: 'updated_at DESC');
    return List.generate(maps.length, (i) => FamilyMember.fromMap(maps[i]));
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
}

