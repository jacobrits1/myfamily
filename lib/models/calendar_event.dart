// Calendar event model for storing calendar events
enum EventCategory {
  birthday,
  anniversary,
  personalReminder,
  medicalAppointment,
  fitnessGymSession,
  holidayVacation,
  familyEvent,
  billPaymentReminder;

  // Convert enum to string for database storage
  String get value {
    switch (this) {
      case EventCategory.birthday:
        return 'birthday';
      case EventCategory.anniversary:
        return 'anniversary';
      case EventCategory.personalReminder:
        return 'personal_reminder';
      case EventCategory.medicalAppointment:
        return 'medical_appointment';
      case EventCategory.fitnessGymSession:
        return 'fitness_gym_session';
      case EventCategory.holidayVacation:
        return 'holiday_vacation';
      case EventCategory.familyEvent:
        return 'family_event';
      case EventCategory.billPaymentReminder:
        return 'bill_payment_reminder';
    }
  }

  // Create enum from string (database value)
  static EventCategory fromString(String value) {
    switch (value) {
      case 'birthday':
        return EventCategory.birthday;
      case 'anniversary':
        return EventCategory.anniversary;
      case 'personal_reminder':
        return EventCategory.personalReminder;
      case 'medical_appointment':
        return EventCategory.medicalAppointment;
      case 'fitness_gym_session':
        return EventCategory.fitnessGymSession;
      case 'holiday_vacation':
        return EventCategory.holidayVacation;
      case 'family_event':
        return EventCategory.familyEvent;
      case 'bill_payment_reminder':
        return EventCategory.billPaymentReminder;
      default:
        return EventCategory.personalReminder;
    }
  }

  // Get display name for UI
  String get displayName {
    switch (this) {
      case EventCategory.birthday:
        return 'Birthday';
      case EventCategory.anniversary:
        return 'Anniversary';
      case EventCategory.personalReminder:
        return 'Personal Reminder';
      case EventCategory.medicalAppointment:
        return 'Medical Appointment';
      case EventCategory.fitnessGymSession:
        return 'Fitness / Gym Session';
      case EventCategory.holidayVacation:
        return 'Holiday / Vacation';
      case EventCategory.familyEvent:
        return 'Family Event';
      case EventCategory.billPaymentReminder:
        return 'Bill Payment Reminder';
    }
  }
}

// Calendar event model
class CalendarEvent {
  final int? id;
  final String title;
  final String? description;
  final DateTime eventDate;
  final DateTime? endDate;
  final EventCategory category;
  final DateTime createdAt;
  final DateTime updatedAt;

  CalendarEvent({
    this.id,
    required this.title,
    this.description,
    required this.eventDate,
    this.endDate,
    required this.category,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Convert to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'category': category.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create from Map (database result)
  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      eventDate: DateTime.parse(map['event_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      category: EventCategory.fromString(map['category'] as String),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
    );
  }

  // Copy with method for updates
  CalendarEvent copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? eventDate,
    DateTime? endDate,
    EventCategory? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Check if a date falls within this event's date range
  bool isDateInRange(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfEvent = endDate ?? eventDate;
    final startOfEvent = DateTime(eventDate.year, eventDate.month, eventDate.day);
    final endOfEventDay = DateTime(endOfEvent.year, endOfEvent.month, endOfEvent.day);
    
    return startOfDay.isAtSameMomentAs(startOfEvent) ||
        startOfDay.isAtSameMomentAs(endOfEventDay) ||
        (startOfDay.isAfter(startOfEvent) && startOfDay.isBefore(endOfEventDay));
  }
}
