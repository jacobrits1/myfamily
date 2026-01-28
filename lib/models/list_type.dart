// List type enum for categorizing checklists
enum ListType {
  grocery,
  holiday,
  maintenanceRepairs,
  schoolTasks,
  personal,
  shopping,
  work,
  other,
  custom; // For user-defined custom types

  // Convert enum to string for database storage
  String get value {
    switch (this) {
      case ListType.grocery:
        return 'grocery';
      case ListType.holiday:
        return 'holiday';
      case ListType.maintenanceRepairs:
        return 'maintenance_repairs';
      case ListType.schoolTasks:
        return 'school_tasks';
      case ListType.personal:
        return 'personal';
      case ListType.shopping:
        return 'shopping';
      case ListType.work:
        return 'work';
      case ListType.other:
        return 'other';
      case ListType.custom:
        return 'custom';
    }
  }

  // Create enum from string (database value)
  static ListType fromString(String value) {
    switch (value) {
      case 'grocery':
        return ListType.grocery;
      case 'holiday':
        return ListType.holiday;
      case 'maintenance_repairs':
        return ListType.maintenanceRepairs;
      case 'school_tasks':
        return ListType.schoolTasks;
      case 'personal':
        return ListType.personal;
      case 'shopping':
        return ListType.shopping;
      case 'work':
        return ListType.work;
      case 'other':
        return ListType.other;
      case 'custom':
        return ListType.custom;
      default:
        return ListType.other;
    }
  }

  // Get display name for UI
  String get displayName {
    switch (this) {
      case ListType.grocery:
        return 'Grocery';
      case ListType.holiday:
        return 'Holiday';
      case ListType.maintenanceRepairs:
        return 'Maintenance / Repairs';
      case ListType.schoolTasks:
        return 'School Tasks';
      case ListType.personal:
        return 'Personal';
      case ListType.shopping:
        return 'Shopping';
      case ListType.work:
        return 'Work';
      case ListType.other:
        return 'Other';
      case ListType.custom:
        return 'Custom';
    }
  }

  // Get icon for UI
  String get iconName {
    switch (this) {
      case ListType.grocery:
        return 'shopping_cart';
      case ListType.holiday:
        return 'celebration';
      case ListType.maintenanceRepairs:
        return 'build';
      case ListType.schoolTasks:
        return 'school';
      case ListType.personal:
        return 'person';
      case ListType.shopping:
        return 'store';
      case ListType.work:
        return 'work';
      case ListType.other:
        return 'list';
      case ListType.custom:
        return 'edit';
    }
  }
}
