import 'package:flutter/material.dart';
import '../utils/constants.dart';

// Circular progress indicator widget for checklist completion
class ChecklistProgressIndicator extends StatelessWidget {
  final double percentage;
  final double size;

  const ChecklistProgressIndicator({
    super.key,
    required this.percentage,
    this.size = 60.0,
  });

  // Get color based on completion percentage
  Color _getProgressColor() {
    if (percentage < 50) {
      return Colors.red;
    } else if (percentage < 80) {
      return Colors.orange;
    } else {
      return const Color(AppConstants.successColor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: percentage / 100,
              strokeWidth: 6.0,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
            ),
          ),
          // Percentage text
          Text(
            '${percentage.toInt()}%',
            style: TextStyle(
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
              color: _getProgressColor(),
            ),
          ),
        ],
      ),
    );
  }
}
