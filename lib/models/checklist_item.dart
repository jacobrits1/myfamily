// Checklist item model for storing individual checklist items
class ChecklistItem {
  final int? id;
  final int listId;
  final String text;
  final bool isChecked;
  final int itemOrder;
  final DateTime createdAt;

  ChecklistItem({
    this.id,
    required this.listId,
    required this.text,
    required this.isChecked,
    required this.itemOrder,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'list_id': listId,
      'text': text,
      'is_checked': isChecked ? 1 : 0,
      'item_order': itemOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map (database result)
  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] as int?,
      listId: map['list_id'] as int,
      text: map['text'] as String,
      isChecked: (map['is_checked'] as int) == 1,
      itemOrder: map['item_order'] as int,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  ChecklistItem copyWith({
    int? id,
    int? listId,
    String? text,
    bool? isChecked,
    int? itemOrder,
    DateTime? createdAt,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      listId: listId ?? this.listId,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
      itemOrder: itemOrder ?? this.itemOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
