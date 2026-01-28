import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../models/checklist.dart';
import '../widgets/checklist_card.dart';
import 'checklist_detail_screen.dart';

// Lists screen - full-screen list view with all checklists
class ListsScreen extends StatefulWidget {
  const ListsScreen({super.key});

  @override
  State<ListsScreen> createState() => _ListsScreenState();
}

class _ListsScreenState extends State<ListsScreen> {
  final DatabaseService _databaseService = DatabaseService();
  List<Checklist> _myChecklists = []; // Lists I created
  List<Map<String, dynamic>> _sharedChecklists = []; // Lists shared with me (with creator/sharer info)
  Map<int, double> _completionPercentages = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadChecklists();
  }

  // Load all checklists and calculate completion percentages
  Future<void> _loadChecklists() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get self member
      final selfMember = await _databaseService.getSelfMember();
      if (selfMember?.id == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load my checklists (lists I created)
      final allChecklists = await _databaseService.getAllChecklists();
      _myChecklists = allChecklists
          .where((c) => c.creatorId == selfMember!.id)
          .toList();

      // Load shared lists (lists shared with me)
      final sharedListsData = await _databaseService.getListsSharedWithMe(selfMember!.id!);
      _sharedChecklists = sharedListsData;

      // Calculate completion percentages for all lists
      final percentages = <int, double>{};
      final allListsToCheck = <Checklist>[..._myChecklists];
      
      // Convert shared lists data to Checklist objects for percentage calculation
      for (final sharedData in _sharedChecklists) {
        final checklist = Checklist.fromMap(sharedData);
        allListsToCheck.add(checklist);
      }

      for (final checklist in allListsToCheck) {
        if (checklist.id != null) {
          final items = await _databaseService
              .getChecklistItemsByListId(checklist.id!);
          if (items.isEmpty) {
            percentages[checklist.id!] = 0.0;
          } else {
            final checkedCount = items.where((item) => item.isChecked).length;
            percentages[checklist.id!] = (checkedCount / items.length) * 100;
          }
        }
      }

      setState(() {
        _completionPercentages = percentages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading checklists: $e')),
        );
      }
    }
  }

  // Navigate to checklist detail screen
  Future<void> _navigateToChecklistDetail(Checklist? checklist) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChecklistDetailScreen(checklist: checklist),
      ),
    );

    // Reload checklists if a change was made
    if (result == true) {
      _loadChecklists();
    }
  }

  // Delete checklist with confirmation
  Future<void> _deleteChecklist(Checklist checklist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Checklist'),
        content: Text('Are you sure you want to delete "${checklist.title}"?'),
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

    if (confirm == true && checklist.id != null) {
      try {
        // Delete sharing relationships (cascade will handle this, but explicit is better)
        await _databaseService.deleteSharedListsForChecklist(checklist.id!);
        await _databaseService.deleteChecklist(checklist.id!);
        _loadChecklists();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Checklist deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting checklist: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(AppConstants.textColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lists',
          style: TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myChecklists.isEmpty && _sharedChecklists.isEmpty
              ? _buildEmptyState()
              : _buildChecklistsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToChecklistDetail(null),
        backgroundColor: const Color(AppConstants.secondaryColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'No Checklists',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textColor),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to create your first checklist',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build checklists list with two sections
  Widget _buildChecklistsList() {
    return RefreshIndicator(
      onRefresh: _loadChecklists,
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // My Lists section
          if (_myChecklists.isNotEmpty) ...[
            const Text(
              'My Lists',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.textColor),
              ),
            ),
            const SizedBox(height: 12),
            ..._myChecklists.map((checklist) {
              final percentage = checklist.id != null
                  ? _completionPercentages[checklist.id!] ?? 0.0
                  : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key('my_checklist_${checklist.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(
                          AppConstants.cardBorderRadius),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteChecklist(checklist);
                  },
                  confirmDismiss: (direction) async {
                    return await _showDeleteConfirmation(checklist);
                  },
                  child: ChecklistCard(
                    checklist: checklist,
                    completionPercentage: percentage,
                    onTap: () => _navigateToChecklistDetail(checklist),
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],

          // Shared with me section
          if (_sharedChecklists.isNotEmpty) ...[
            const Text(
              'Shared with me',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.textColor),
              ),
            ),
            const SizedBox(height: 12),
            ..._sharedChecklists.map((sharedData) {
              final checklist = Checklist.fromMap(sharedData);
              final percentage = checklist.id != null
                  ? _completionPercentages[checklist.id!] ?? 0.0
                  : 0.0;

              // Get creator and sharer names
              final creatorFirstName = sharedData['creator_first_name'] as String?;
              final creatorLastName = sharedData['creator_last_name'] as String?;
              final creatorName = creatorFirstName != null && creatorLastName != null
                  ? '$creatorFirstName $creatorLastName'
                  : null;

              final sharerFirstName = sharedData['sharer_first_name'] as String?;
              final sharerLastName = sharedData['sharer_last_name'] as String?;
              final sharerName = sharerFirstName != null && sharerLastName != null
                  ? '$sharerFirstName $sharerLastName'
                  : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ChecklistCard(
                  checklist: checklist,
                  completionPercentage: percentage,
                  onTap: () => _navigateToChecklistDetail(checklist),
                  creatorName: creatorName,
                  sharerName: sharerName,
                  isShared: true,
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  // Show delete confirmation dialog
  Future<bool> _showDeleteConfirmation(Checklist checklist) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Checklist'),
        content: Text('Are you sure you want to delete "${checklist.title}"?'),
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
    return confirm ?? false;
  }
}
