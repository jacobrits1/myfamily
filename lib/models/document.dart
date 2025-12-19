// Document model for storing document metadata
class Document {
  final int? id;
  final int memberId;
  final String fileName;
  final String filePath;
  final String fileType; // pdf, image, email
  final String? title; // User-defined title for the document
  final String? parsedData; // JSON string of extracted data
  final DateTime createdAt;

  Document({
    this.id,
    required this.memberId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    this.title,
    this.parsedData,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'title': title,
      'parsed_data': parsedData,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Create from Map (database result)
  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'] as int?,
      memberId: map['member_id'] as int,
      fileName: map['file_name'] as String,
      filePath: map['file_path'] as String,
      fileType: map['file_type'] as String,
      title: map['title'] as String?,
      parsedData: map['parsed_data'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  Document copyWith({
    int? id,
    int? memberId,
    String? fileName,
    String? filePath,
    String? fileType,
    String? title,
    String? parsedData,
    DateTime? createdAt,
  }) {
    return Document(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      title: title ?? this.title,
      parsedData: parsedData ?? this.parsedData,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

