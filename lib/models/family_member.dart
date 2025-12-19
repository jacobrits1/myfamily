// Family member model
class FamilyMember {
  final int? id;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? ssn;
  final String? studentId;
  final String? profileImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  FamilyMember({
    this.id,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.ssn,
    this.studentId,
    this.profileImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'date_of_birth': dateOfBirth,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'ssn': ssn,
      'student_id': studentId,
      'profile_image_path': profileImagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database result)
  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      id: map['id'] as int?,
      firstName: map['first_name'] as String,
      lastName: map['last_name'] as String,
      dateOfBirth: map['date_of_birth'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      city: map['city'] as String?,
      state: map['state'] as String?,
      zipCode: map['zip_code'] as String?,
      ssn: map['ssn'] as String?,
      studentId: map['student_id'] as String?,
      profileImagePath: map['profile_image_path'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  // Copy with method for updates
  FamilyMember copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? dateOfBirth,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? ssn,
    String? studentId,
    String? profileImagePath,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FamilyMember(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      ssn: ssn ?? this.ssn,
      studentId: studentId ?? this.studentId,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String get fullName => '$firstName $lastName';
}

