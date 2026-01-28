// Checklist model for storing checklist data
class Checklist {
  final int? id;
  final String title;
  final String type; // Can be ListType.value or custom type string
  final DateTime? dueDate;
  final int? creatorId; // ID of the member who created this list
  final DateTime createdAt;
  final DateTime updatedAt;

  Checklist({
    this.id,
    required this.title,
    required this.type,
    this.dueDate,
    this.creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'due_date': dueDate?.toIso8601String(),
      'creator_id': creatorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database result)
  factory Checklist.fromMap(Map<String, dynamic> map) {
    return Checklist(
      id: map['id'] as int?,
      title: map['title'] as String,
      type: map['type'] as String,
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'] as String)
          : null,
      creatorId: map['creator_id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  Checklist copyWith({
    int? id,
    String? title,
    String? type,
    DateTime? dueDate,
    int? creatorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Checklist(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      dueDate: dueDate ?? this.dueDate,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Check if due date is today or in the past
  bool get isOverdue {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.isBefore(today);
  }

  // Check if due date is today
  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }
}
