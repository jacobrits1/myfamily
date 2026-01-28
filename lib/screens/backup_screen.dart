import 'package:flutter/material.dart';
import '../models/backup_data.dart';
import '../services/backup_service.dart';
import '../services/restore_service.dart';
import '../utils/constants.dart';

// Backup screen for managing backups and restores
class BackupScreen extends StatefulWidget {
  final String userEmail;

  const BackupScreen({super.key, required this.userEmail});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  final BackupService _backupService = BackupService();
  final RestoreService _restoreService = RestoreService();
  List<BackupRecord> _backups = [];
  bool _isLoading = true;
  bool _isBackingUp = false;
  bool _isRestoring = false;
  String? _progressMessage;

  @override
  void initState() {
    super.initState();
    _loadBackups();
  }

  // Load list of backups
  Future<void> _loadBackups() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final backups = await _backupService.getBackups(widget.userEmail);
      setState(() {
        _backups = backups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading backups: $e')),
        );
      }
    }
  }

  // Perform backup
  Future<void> _performBackup() async {
    setState(() {
      _isBackingUp = true;
      _progressMessage = 'Starting backup...';
    });

    try {
      await _backupService.performBackup(
        widget.userEmail,
        (message) {
          setState(() {
            _progressMessage = message;
          });
        },
      );

      setState(() {
        _isBackingUp = false;
        _progressMessage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup completed successfully!'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
        _loadBackups();
      }
    } catch (e) {
      setState(() {
        _isBackingUp = false;
        _progressMessage = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Perform restore
  Future<void> _performRestore(String backupId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Backup'),
        content: const Text(
          'This will replace all current data with the backup. This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isRestoring = true;
      _progressMessage = 'Starting restore...';
    });

    try {
      await _restoreService.performRestore(
        backupId,
        widget.userEmail,
        clearExisting: true,
        onProgress: (message) {
          setState(() {
            _progressMessage = message;
          });
        },
      );

      setState(() {
        _isRestoring = false;
        _progressMessage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Restore completed successfully!'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate data changed
      }
    } catch (e) {
      setState(() {
        _isRestoring = false;
        _progressMessage = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Restore failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Delete backup
  Future<void> _deleteBackup(String backupId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Backup'),
        content: const Text(
          'Are you sure you want to delete this backup? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _backupService.deleteBackup(backupId, widget.userEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup deleted successfully'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
        _loadBackups();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting backup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(AppConstants.textColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Backup & Restore',
          style: TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: (_isBackingUp || _isRestoring)
          ? _buildProgressView()
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Backup button section
                  _buildBackupButtonSection(),
                  
                  // Backups list section
                  _buildBackupsListSection(),
                ],
              ),
            ),
    );
  }

  // Build progress view
  Widget _buildProgressView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            _progressMessage ?? 'Processing...',
            style: const TextStyle(
              fontSize: 16,
              color: Color(AppConstants.textColor),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build backup button section
  Widget _buildBackupButtonSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Create Backup',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textColor),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Back up all your family data, documents, calendar events, and checklists to the cloud.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _performBackup,
              icon: const Icon(Icons.cloud_upload, color: Colors.white),
              label: const Text(
                'Create Backup',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build backups list section
  Widget _buildBackupsListSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_backups.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 64,
                color: Color(0xFF6B7280),
              ),
              SizedBox(height: 16),
              Text(
                'No backups yet',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.textColor),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Create your first backup to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Available Backups',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.textColor),
              ),
            ),
          ),
          ..._backups.map((backup) => _buildBackupItem(backup)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // Build backup item
  Widget _buildBackupItem(BackupRecord backup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_upload,
            color: Color(AppConstants.primaryColor),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(backup.backupTimestamp),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.textColor),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version: ${backup.backupVersion}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.cloud_download, color: Color(AppConstants.primaryColor)),
            onPressed: () => _performRestore(backup.id),
            tooltip: 'Restore',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteBackup(backup.id),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }
}
