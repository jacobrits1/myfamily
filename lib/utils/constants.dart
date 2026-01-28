// App constants
class AppConstants {
  // Database
  static const String databaseName = 'myfamily.db';
  static const int databaseVersion = 7;

  // Table names
  static const String tableFamilyMembers = 'family_members';
  static const String tableCustomFields = 'custom_fields';
  static const String tableDocuments = 'documents';
  static const String tableCalendarEvents = 'calendar_events';
  static const String tableChecklists = 'checklists';
  static const String tableChecklistItems = 'checklist_items';
  static const String tableSharedLists = 'shared_lists';

  // Colors (based on UI reference)
  static const int primaryColor = 0xFF0891B2; // Cyan
  static const int secondaryColor = 0xFFF97316; // Orange
  static const int successColor = 0xFF10B981; // Green
  static const int backgroundColor = 0xFFFFFFFF; // White
  static const int cardBackgroundColor = 0xFFFFFFFF; // White
  static const int textColor = 0xFF1F2937; // Dark gray
  static const int calendarColor = 0xFF8B5CF6; // Purple
  static const int checklistColor = 0xFFFFA500; // Orange

  // Event category colors
  static const int eventColorBirthday = 0xFFFF6B6B; // Red
  static const int eventColorAnniversary = 0xFFFFD93D; // Yellow
  static const int eventColorPersonalReminder = 0xFF6BCF7F; // Green
  static const int eventColorMedicalAppointment = 0xFF4ECDC4; // Teal
  static const int eventColorFitnessGymSession = 0xFF45B7D1; // Blue
  static const int eventColorHolidayVacation = 0xFF96CEB4; // Mint
  static const int eventColorFamilyEvent = 0xFFFFA07A; // Light Salmon
  static const int eventColorBillPaymentReminder = 0xFFFF8C94; // Pink

  // UI
  static const double cardBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  static const double defaultPadding = 16.0;

  // Supabase Configuration
  static const String supabaseUrl = 'https://wcldlmpvphqqqcyvewuf.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_yb0NYVOnUBODJS9rYLOR1Q_whs5uUJg';
  
  // Backup Configuration
  static const String backupVersion = '1.0.0';
  static const String storageBucketBackups = 'backups';
  static const String storageBucketProfileImages = 'profile-images';
}

