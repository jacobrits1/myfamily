import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../services/premium_service.dart';
import '../models/checklist.dart';
import '../models/checklist_item.dart';
import '../models/list_type.dart';
import '../models/family_member.dart';

// Checklist detail/edit screen
class ChecklistDetailScreen extends StatefulWidget {
  final Checklist? checklist;

  const ChecklistDetailScreen({super.key, this.checklist});

  @override
  State<ChecklistDetailScreen> createState() => _ChecklistDetailScreenState();
}

class _ChecklistDetailScreenState extends State<ChecklistDetailScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final PremiumService _premiumService = PremiumService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _customTypeController = TextEditingController();

  ListType _selectedType = ListType.other;
  bool _isCustomType = false;
  DateTime? _dueDate;
  List<ChecklistItem> _items = [];
  bool _isLoading = false;
  bool _hasChanges = false;
  List<FamilyMember> _sharedMembers = [];
  bool _isPremiumEnabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.checklist != null) {
      _titleController.text = widget.checklist!.title;
      final listType = ListType.fromString(widget.checklist!.type);
      if (listType == ListType.custom) {
        _isCustomType = true;
        _customTypeController.text = widget.checklist!.type;
        _selectedType = ListType.custom;
      } else {
        _selectedType = listType;
      }
      _dueDate = widget.checklist!.dueDate;
      _loadItems();
      _checkPremiumAndLoadSharing();
    } else {
      _checkPremium();
    }
  }

  // Check premium status
  Future<void> _checkPremium() async {
    final isPremium = await _premiumService.isListSharingEnabled();
    setState(() {
      _isPremiumEnabled = isPremium;
    });
  }

  // Check premium and load sharing for existing checklist
  Future<void> _checkPremiumAndLoadSharing() async {
    await _checkPremium();
    if (_isPremiumEnabled && widget.checklist?.id != null) {
      await _loadSharedMembers();
    }
  }

  // Load shared members for this checklist
  Future<void> _loadSharedMembers() async {
    if (widget.checklist?.id == null) return;
    try {
      final members = await _databaseService.getSharedMembersForList(widget.checklist!.id!);
      setState(() {
        _sharedMembers = members;
      });
    } catch (e) {
      // Silently fail
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _customTypeController.dispose();
    super.dispose();
  }

  // Load checklist items
  Future<void> _loadItems() async {
    if (widget.checklist?.id == null) return;

    try {
      final items = await _databaseService
          .getChecklistItemsByListId(widget.checklist!.id!);
      setState(() {
        _items = items;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  // Add new item
  void _addItem() {
    setState(() {
      _items.add(ChecklistItem(
        listId: widget.checklist?.id ?? 0,
        text: '',
        isChecked: false,
        itemOrder: _items.length,
      ));
      _hasChanges = true;
    });
  }

  // Remove item
  void _removeItem(int index) {
    setState(() {
      final item = _items[index];
      _items.removeAt(index);
      // Update item orders
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(itemOrder: i);
      }
      _hasChanges = true;
      // Delete from database if it has an ID
      if (item.id != null) {
        _databaseService.deleteChecklistItem(item.id!);
      }
    });
  }

  // Update item text
  void _updateItemText(int index, String text) {
    setState(() {
      _items[index] = _items[index].copyWith(text: text);
      _hasChanges = true;
    });
  }

  // Toggle item checked state
  void _toggleItemChecked(int index) {
    setState(() {
      _items[index] = _items[index].copyWith(
        isChecked: !_items[index].isChecked,
      );
      _hasChanges = true;
    });
  }

  // Handle item reorder
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _items.removeAt(oldIndex);
      _items.insert(newIndex, item);
      // Update item orders
      for (int i = 0; i < _items.length; i++) {
        _items[i] = _items[i].copyWith(itemOrder: i);
      }
      _hasChanges = true;
    });
  }

  // Save checklist
  Future<void> _saveChecklist() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    // Validate items
    final validItems = _items.where((item) => item.text.trim().isNotEmpty).toList();
    if (validItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final typeString = _isCustomType && _customTypeController.text.trim().isNotEmpty
          ? _customTypeController.text.trim()
          : _selectedType.value;

      Checklist checklist;
      if (widget.checklist != null) {
        // Update existing checklist
        checklist = widget.checklist!.copyWith(
          title: _titleController.text.trim(),
          type: typeString,
          dueDate: _dueDate,
        );
        await _databaseService.updateChecklist(checklist);
        // Sharing is saved immediately, so no need to save again here
      } else {
        // Create new checklist
        checklist = Checklist(
          title: _titleController.text.trim(),
          type: typeString,
          dueDate: _dueDate,
        );
        final id = await _databaseService.insertChecklist(checklist);
        checklist = checklist.copyWith(id: id);
      }

      // Save items
      final itemIds = <int>[];
      for (int i = 0; i < validItems.length; i++) {
        final item = validItems[i].copyWith(
          listId: checklist.id!,
          itemOrder: i,
        );

        if (item.id != null) {
          // Update existing item
          await _databaseService.updateChecklistItem(item);
          itemIds.add(item.id!);
        } else {
          // Insert new item
          final itemId = await _databaseService.insertChecklistItem(item);
          itemIds.add(itemId);
        }
      }

      // Delete items that were removed
      if (widget.checklist?.id != null) {
        final existingItems = await _databaseService
            .getChecklistItemsByListId(widget.checklist!.id!);
        for (final existingItem in existingItems) {
          if (!itemIds.contains(existingItem.id)) {
            await _databaseService.deleteChecklistItem(existingItem.id!);
          }
        }
      }

      // Update item order in database
      if (itemIds.isNotEmpty && checklist.id != null) {
        await _databaseService.updateChecklistItemOrder(checklist.id!, itemIds);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate changes
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving checklist: $e')),
        );
      }
    }
  }

  // Delete checklist
  Future<void> _deleteChecklist() async {
    if (widget.checklist?.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Checklist'),
        content: Text('Are you sure you want to delete "${widget.checklist!.title}"?'),
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

    if (confirm == true) {
      try {
        // Delete sharing relationships (cascade will handle this, but explicit is better)
        await _databaseService.deleteSharedListsForChecklist(widget.checklist!.id!);
        await _databaseService.deleteChecklist(widget.checklist!.id!);
        if (mounted) {
          Navigator.pop(context, true);
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

  // Show sharing dialog with member selection
  Future<void> _showSharingDialog() async {
    if (widget.checklist?.id == null) return;

    try {
      // Get self member
      final selfMember = await _databaseService.getSelfMember();
      if (selfMember?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please set your profile first')),
        );
        return;
      }

      // Get all family members except self
      final allMembers = await _databaseService.getAllFamilyMembers();
      final availableMembers = allMembers
          .where((member) => member.id != selfMember!.id)
          .toList();

      if (availableMembers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No other family members to share with')),
        );
        return;
      }

      // Get currently shared member IDs (filter out nulls)
      final sharedMemberIds = _sharedMembers
          .where((m) => m.id != null)
          .map((m) => m.id!)
          .toSet();

      // Show dialog with checkboxes
      final selectedMembers = await showDialog<Set<int>>(
        context: context,
        builder: (context) {
          final selected = <int>{...sharedMemberIds};
          return StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: const Text('Share with Family Members'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableMembers.length,
                    itemBuilder: (context, index) {
                      final member = availableMembers[index];
                      final isSelected = selected.contains(member.id);
                      final isAlreadyShared = sharedMemberIds.contains(member.id);

                      return CheckboxListTile(
                        title: Text('${member.firstName} ${member.lastName}'),
                        value: isSelected,
                        enabled: !isAlreadyShared, // Disable if already shared
                        onChanged: isAlreadyShared
                            ? null
                            : (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    selected.add(member.id!);
                                  } else {
                                    selected.remove(member.id);
                                  }
                                });
                              },
                        subtitle: isAlreadyShared
                            ? const Text('Already shared', style: TextStyle(fontSize: 12))
                            : null,
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, selected),
                    child: const Text('Share'),
                  ),
                ],
              );
            },
          );
        },
      );

      if (selectedMembers != null && selectedMembers.isNotEmpty) {
        await _addSharing(selectedMembers, selfMember!.id!);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // Add sharing for selected members
  Future<void> _addSharing(Set<int> memberIds, int sharedByMemberId) async {
    if (widget.checklist?.id == null) return;

    try {
      for (final memberId in memberIds) {
        // Check if already shared
        final alreadyShared = await _databaseService.isListSharedWithMember(
          widget.checklist!.id!,
          memberId,
        );
        if (!alreadyShared) {
          await _databaseService.shareListWithMember(
            widget.checklist!.id!,
            sharedByMemberId,
            memberId,
          );
        }
      }
      // Reload shared members
      await _loadSharedMembers();
      setState(() {
        _hasChanges = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sharing list: $e')),
        );
      }
    }
  }

  // Remove sharing with a member
  Future<void> _removeSharing(int memberId) async {
    if (widget.checklist?.id == null) return;

    try {
      await _databaseService.unshareListWithMember(widget.checklist!.id!, memberId);
      // Reload shared members
      await _loadSharedMembers();
      setState(() {
        _hasChanges = true;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error removing sharing: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (!didPop && _hasChanges) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Discard Changes?'),
              content: const Text('You have unsaved changes. Are you sure you want to go back?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Discard'),
                ),
              ],
            ),
          );
          if (shouldPop == true && mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(AppConstants.backgroundColor),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back,
                color: Color(AppConstants.textColor)),
            onPressed: () async {
              if (_hasChanges) {
                final shouldPop = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Discard Changes?'),
                    content: const Text(
                        'You have unsaved changes. Are you sure you want to go back?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Discard'),
                      ),
                    ],
                  ),
                );
                if (shouldPop == true && mounted) {
                  Navigator.of(context).pop();
                }
              } else if (mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Text(
            widget.checklist == null ? 'New Checklist' : 'Edit Checklist',
            style: const TextStyle(
              color: Color(AppConstants.textColor),
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (widget.checklist != null)
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: _deleteChecklist,
              ),
            IconButton(
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check, color: Color(AppConstants.successColor)),
              onPressed: _isLoading ? null : _saveChecklist,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title field
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setState(() => _hasChanges = true),
                    ),
                    const SizedBox(height: 16),

                    // Type selector
                    const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<ListType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: ListType.values
                          .where((type) => type != ListType.custom)
                          .map((type) {
                        return DropdownMenuItem<ListType>(
                          value: type,
                          child: Text(type.displayName),
                        );
                      }).toList()
                        ..add(
                          const DropdownMenuItem<ListType>(
                            value: ListType.custom,
                            child: Text('Custom'),
                          ),
                        ),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                            _isCustomType = value == ListType.custom;
                            _hasChanges = true;
                          });
                        }
                      },
                    ),

                    // Custom type field
                    if (_isCustomType) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _customTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Custom Type',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() => _hasChanges = true),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Sharing section (only for existing checklists with premium)
                    if (_isPremiumEnabled && widget.checklist?.id != null) ...[
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Share with',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _showSharingDialog,
                            icon: const Icon(Icons.person_add),
                            label: const Text('Add Members'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Shared members chips
                      if (_sharedMembers.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            'No members shared yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _sharedMembers.map((member) {
                            return Chip(
                              label: Text('${member.firstName} ${member.lastName}'),
                              deleteIcon: const Icon(Icons.close, size: 18),
                              onDeleted: () => _removeSharing(member.id!),
                              avatar: CircleAvatar(
                                backgroundColor: const Color(AppConstants.primaryColor).withValues(alpha: 0.2),
                                child: Text(
                                  member.firstName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Color(AppConstants.primaryColor),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      const SizedBox(height: 16),
                    ],

                    const SizedBox(height: 16),

                    // Due date picker
                    ListTile(
                      title: const Text('Due Date'),
                      subtitle: Text(
                        _dueDate != null
                            ? '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'
                            : 'No due date',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_dueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                setState(() {
                                  _dueDate = null;
                                  _hasChanges = true;
                                });
                              },
                            ),
                          const Icon(Icons.calendar_today),
                        ],
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _dueDate = picked;
                            _hasChanges = true;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Items section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Items',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Item'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Reorderable list of items
                    if (_items.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No items yet. Tap "Add Item" to get started.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        onReorder: _onReorder,
                        itemBuilder: (context, index) {
                          final item = _items[index];
                          return Card(
                            key: ValueKey('item_${item.id}_$index'),
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: Checkbox(
                                value: item.isChecked,
                                onChanged: (_) => _toggleItemChecked(index),
                              ),
                              title: TextField(
                                controller: TextEditingController(text: item.text)
                                  ..selection = TextSelection.collapsed(
                                      offset: item.text.length),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Item text',
                                ),
                                onChanged: (text) => _updateItemText(index, text),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeItem(index),
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 16),

                    // Add item button at bottom
                    ElevatedButton.icon(
                      onPressed: _addItem,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppConstants.secondaryColor),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
