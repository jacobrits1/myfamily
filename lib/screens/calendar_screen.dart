import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/calendar_event.dart';
import '../models/checklist.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import 'checklist_detail_screen.dart';

// Helper function to get category color
Color _getCategoryColor(EventCategory category) {
  switch (category) {
    case EventCategory.birthday:
      return const Color(AppConstants.eventColorBirthday);
    case EventCategory.anniversary:
      return const Color(AppConstants.eventColorAnniversary);
    case EventCategory.personalReminder:
      return const Color(AppConstants.eventColorPersonalReminder);
    case EventCategory.medicalAppointment:
      return const Color(AppConstants.eventColorMedicalAppointment);
    case EventCategory.fitnessGymSession:
      return const Color(AppConstants.eventColorFitnessGymSession);
    case EventCategory.holidayVacation:
      return const Color(AppConstants.eventColorHolidayVacation);
    case EventCategory.familyEvent:
      return const Color(AppConstants.eventColorFamilyEvent);
    case EventCategory.billPaymentReminder:
      return const Color(AppConstants.eventColorBillPaymentReminder);
  }
}

// Calendar screen with event management
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late ValueNotifier<List<CalendarEvent>> _selectedEvents;
  late ValueNotifier<List<Checklist>> _selectedChecklists;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  List<CalendarEvent> _allEvents = [];
  List<Checklist> _allChecklists = [];

  @override
  void initState() {
    super.initState();
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    _selectedChecklists = ValueNotifier(_getChecklistsForDay(_selectedDay));
    _loadEvents();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    _selectedChecklists.dispose();
    super.dispose();
  }

  // Load all events and checklists from database
  Future<void> _loadEvents() async {
    final events = await _databaseService.getAllCalendarEvents();
    final checklists = await _databaseService.getAllChecklists();
    setState(() {
      _allEvents = events;
      _allChecklists = checklists.where((c) => c.dueDate != null).toList();
    });
    _selectedEvents.value = _getEventsForDay(_selectedDay);
    _selectedChecklists.value = _getChecklistsForDay(_selectedDay);
  }

  // Get events for a specific day
  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _allEvents.where((event) {
      return event.isDateInRange(day);
    }).toList();
  }

  // Get checklists for a specific day
  List<Checklist> _getChecklistsForDay(DateTime day) {
    return _allChecklists.where((checklist) {
      if (checklist.dueDate == null) return false;
      final dueDate = checklist.dueDate!;
      return dueDate.year == day.year &&
          dueDate.month == day.month &&
          dueDate.day == day.day;
    }).toList();
  }


  // Show add/edit event dialog
  Future<void> _showEventDialog([CalendarEvent? event]) async {
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    DateTime selectedDate = event?.eventDate ?? _selectedDay;
    DateTime? selectedEndDate = event?.endDate;
    EventCategory selectedCategory = event?.category ?? EventCategory.personalReminder;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Start Date'),
                  subtitle: Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: selectedEndDate != null ? selectedEndDate! : DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedDate = picked;
                        // If end date is before new start date, clear it
                        if (selectedEndDate != null && selectedEndDate!.isBefore(picked)) {
                          selectedEndDate = null;
                        }
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('End Date (optional)'),
                  subtitle: Text(
                    selectedEndDate != null
                        ? '${selectedEndDate!.year}-${selectedEndDate!.month.toString().padLeft(2, '0')}-${selectedEndDate!.day.toString().padLeft(2, '0')}'
                        : 'No end date',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedEndDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setDialogState(() {
                              selectedEndDate = null;
                            });
                          },
                        ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedEndDate ?? selectedDate,
                      firstDate: selectedDate,
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        selectedEndDate = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 8),
                const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                DropdownButtonFormField<EventCategory>(
                  initialValue: selectedCategory,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: EventCategory.values.map((category) {
                    return DropdownMenuItem<EventCategory>(
                      value: category,
                      child: Row(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: _getCategoryColor(category),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedCategory = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a title')),
                  );
                  return;
                }
                if (selectedEndDate != null && selectedEndDate!.isBefore(selectedDate)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('End date must be after start date')),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final calendarEvent = event?.copyWith(
            title: titleController.text.trim(),
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            eventDate: selectedDate,
            endDate: selectedEndDate,
            category: selectedCategory,
          ) ??
          CalendarEvent(
            title: titleController.text.trim(),
            description: descriptionController.text.trim().isEmpty
                ? null
                : descriptionController.text.trim(),
            eventDate: selectedDate,
            endDate: selectedEndDate,
            category: selectedCategory,
          );

      if (event == null) {
        await _databaseService.insertCalendarEvent(calendarEvent);
      } else {
        await _databaseService.updateCalendarEvent(calendarEvent);
      }
      await _loadEvents();
    }
  }

  // Show event details and delete option
  Future<void> _showEventDetails(CalendarEvent event) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (event.description != null && event.description!.isNotEmpty) ...[
              Text(event.description!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getCategoryColor(event.category),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(event.category.displayName),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event.endDate != null
                  ? 'Date: ${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')} to ${event.endDate!.year}-${event.endDate!.month.toString().padLeft(2, '0')}-${event.endDate!.day.toString().padLeft(2, '0')}'
                  : 'Date: ${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _showEventDialog(event);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Event'),
                  content: const Text('Are you sure you want to delete this event?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true && mounted) {
                await _databaseService.deleteCalendarEvent(event.id!);
                await _loadEvents();
                if (mounted) {
                  navigator.pop();
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(AppConstants.textColor)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Calendar widget
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Color(AppConstants.textColor)),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
            ),
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _selectedEvents.value = _getEventsForDay(selectedDay);
                _selectedChecklists.value = _getChecklistsForDay(selectedDay);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                final checklists = _getChecklistsForDay(date);
                final allMarkers = <Widget>[];
                
                // Add event markers
                for (final event in events.take(3)) {
                  allMarkers.add(
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(event.category),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                
                // Add checklist markers (orange color)
                for (final checklist in checklists.take(3 - events.length)) {
                  allMarkers.add(
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.checklistColor),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                
                if (allMarkers.isNotEmpty) {
                  return Positioned(
                    bottom: 1,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: allMarkers,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          const Divider(),
          // Events and checklists list for selected day
          Expanded(
            child: Column(
              children: [
                // Events
                Expanded(
                  child: ValueListenableBuilder<List<CalendarEvent>>(
                    valueListenable: _selectedEvents,
                    builder: (context, events, _) {
                      return ValueListenableBuilder<List<Checklist>>(
                        valueListenable: _selectedChecklists,
                        builder: (context, checklists, _) {
                          if (events.isEmpty && checklists.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.event_busy,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No events or checklists for this day',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.all(AppConstants.defaultPadding),
                            itemCount: events.length + checklists.length,
                            itemBuilder: (context, index) {
                              // Show events first
                              if (index < events.length) {
                                final event = events[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: AppConstants.cardElevation,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: _getCategoryColor(event.category),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    title: Text(
                                      event.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (event.description != null && event.description!.isNotEmpty)
                                          Text(event.description!),
                                        const SizedBox(height: 4),
                                        Text(
                                          event.endDate != null
                                              ? '${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')} to ${event.endDate!.year}-${event.endDate!.month.toString().padLeft(2, '0')}-${event.endDate!.day.toString().padLeft(2, '0')}'
                                              : '${event.eventDate.year}-${event.eventDate.month.toString().padLeft(2, '0')}-${event.eventDate.day.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (event.description == null || event.description!.isEmpty)
                                          Text(
                                            event.category.displayName,
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: event.eventDate.hour == 0 && event.eventDate.minute == 0
                                        ? const Text(
                                            'All day',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                            ),
                                          )
                                        : Text(
                                            '${event.eventDate.hour.toString().padLeft(2, '0')}:${event.eventDate.minute.toString().padLeft(2, '0')}',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 12,
                                            ),
                                          ),
                                    onTap: () => _showEventDetails(event),
                                  ),
                                );
                              }
                              // Then show checklists
                              else {
                                final checklistIndex = index - events.length;
                                final checklist = checklists[checklistIndex];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: AppConstants.cardElevation,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                                  ),
                                  child: ListTile(
                                    leading: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        color: Color(AppConstants.checklistColor),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    title: Text(
                                      checklist.title,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Checklist Due Date',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${checklist.dueDate!.year}-${checklist.dueDate!.month.toString().padLeft(2, '0')}-${checklist.dueDate!.day.toString().padLeft(2, '0')}',
                                          style: TextStyle(
                                            color: checklist.isOverdue
                                                ? Colors.red
                                                : checklist.isDueToday
                                                    ? Colors.orange
                                                    : Colors.grey[600],
                                            fontSize: 12,
                                            fontWeight: checklist.isOverdue || checklist.isDueToday
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        if (checklist.isOverdue)
                                          Text(
                                            '(Overdue)',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    onTap: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ChecklistDetailScreen(
                                            checklist: checklist,
                                          ),
                                        ),
                                      );
                                      if (result == true) {
                                        _loadEvents();
                                      }
                                    },
                                  ),
                                );
                              }
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        backgroundColor: const Color(AppConstants.calendarColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
