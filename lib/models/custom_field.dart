// Custom field model for dynamic field definitions
class CustomField {
  final int? id;
  final int memberId;
  final String fieldName;
  final String fieldType; // text, number, date, email, phone, etc.
  final String fieldValue;

  CustomField({
    this.id,
    required this.memberId,
    required this.fieldName,
    required this.fieldType,
    required this.fieldValue,
  });

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'field_name': fieldName,
      'field_type': fieldType,
      'field_value': fieldValue,
    };
  }

  // Create from Map (database result)
  factory CustomField.fromMap(Map<String, dynamic> map) {
    return CustomField(
      id: map['id'] as int?,
      memberId: map['member_id'] as int,
      fieldName: map['field_name'] as String,
      fieldType: map['field_type'] as String,
      fieldValue: map['field_value'] as String,
    );
  }

  // Copy with method for updates
  CustomField copyWith({
    int? id,
    int? memberId,
    String? fieldName,
    String? fieldType,
    String? fieldValue,
  }) {
    return CustomField(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      fieldName: fieldName ?? this.fieldName,
      fieldType: fieldType ?? this.fieldType,
      fieldValue: fieldValue ?? this.fieldValue,
    );
  }
}

