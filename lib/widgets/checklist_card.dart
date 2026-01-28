import 'package:flutter/material.dart';
import '../models/checklist.dart';
import '../models/list_type.dart';
import '../utils/constants.dart';
import 'checklist_progress_indicator.dart';

// Checklist card widget for displaying checklist in list view
class ChecklistCard extends StatelessWidget {
  final Checklist checklist;
  final double completionPercentage;
  final VoidCallback onTap;
  final String? creatorName; // Name of the person who created the list
  final String? sharerName; // Name of the person who shared the list
  final bool isShared; // Whether this is a shared list

  const ChecklistCard({
    super.key,
    required this.checklist,
    required this.completionPercentage,
    required this.onTap,
    this.creatorName,
    this.sharerName,
    this.isShared = false,
  });

  // Get list type display name
  String _getTypeDisplayName() {
    final listType = ListType.fromString(checklist.type);
    if (listType == ListType.custom) {
      // For custom types, we'd need to store the custom name separately
      // For now, just return "Custom"
      return 'Custom';
    }
    return listType.displayName;
  }

  // Format due date
  String? _formatDueDate() {
    if (checklist.dueDate == null) return null;
    final date = checklist.dueDate!;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get sharing information text
  String _getSharingInfo() {
    final parts = <String>[];
    if (creatorName != null) {
      parts.add('Created by $creatorName');
    }
    if (sharerName != null) {
      parts.add('Shared by $sharerName');
    }
    return parts.join(' • ');
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            children: [
              // Progress indicator
              ChecklistProgressIndicator(
                percentage: completionPercentage,
                size: 60.0,
              ),
              const SizedBox(width: 16),
              // Title and details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with shared badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            checklist.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(AppConstants.textColor),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isShared)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.share,
                              size: 18,
                              color: const Color(AppConstants.primaryColor),
                            ),
                          ),
                      ],
                    ),
                    // Creator and sharer info
                    if (isShared && (creatorName != null || sharerName != null)) ...[
                      const SizedBox(height: 4),
                      Text(
                        _getSharingInfo(),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.checklistColor)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getTypeDisplayName(),
                        style: TextStyle(
                          fontSize: 12,
                          color: const Color(AppConstants.checklistColor),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // Due date
                    if (checklist.dueDate != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: checklist.isOverdue
                                ? Colors.red
                                : checklist.isDueToday
                                    ? Colors.orange
                                    : Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDueDate()!,
                            style: TextStyle(
                              fontSize: 12,
                              color: checklist.isOverdue
                                  ? Colors.red
                                  : checklist.isDueToday
                                      ? Colors.orange
                                      : Colors.grey[600],
                              fontWeight: checklist.isOverdue ||
                                      checklist.isDueToday
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          if (checklist.isOverdue) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(Overdue)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
