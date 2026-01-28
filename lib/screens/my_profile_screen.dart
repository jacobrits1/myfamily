import 'package:flutter/material.dart';
import '../models/family_member.dart';
import '../models/document.dart';
import '../models/custom_field.dart';
import '../services/database_service.dart';
import '../widgets/document_item.dart';
import '../utils/constants.dart';
import '../utils/image_helper.dart';
import 'add_edit_member_screen.dart';
import 'add_document_screen.dart';
import 'backup_screen.dart';

// My Profile screen - shows the current user's own profile
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Document> _documents = [];
  List<CustomField> _customFields = [];
  FamilyMember? _selfMember;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load self member data, documents, and custom fields
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load self member
      final selfMember = await _dbService.getSelfMember();
      
      if (selfMember == null) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No profile set. Please add yourself as a family member and mark as "This is me".'),
            ),
          );
          Navigator.pop(context);
        }
        return;
      }

      _selfMember = selfMember;

      // Load documents
      final documents = await _dbService.getDocumentsForMember(selfMember.id!);
      
      // Load custom fields
      final customFields = await _dbService.getCustomFieldsForMember(selfMember.id!);

      setState(() {
        _documents = documents;
        _customFields = customFields;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e')),
        );
      }
    }
  }

  // Navigate to edit screen
  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMemberScreen(member: _selfMember),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(AppConstants.backgroundColor),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'My Profile',
            style: TextStyle(
              color: Color(AppConstants.textColor),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_selfMember == null) {
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
            'My Profile',
            style: TextStyle(
              color: Color(AppConstants.textColor),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text('No profile found. Please add yourself as a family member.'),
        ),
      );
    }

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
          'My Profile',
          style: TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(AppConstants.primaryColor)),
            onPressed: _navigateToEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            _buildProfileHeader(),
            
            // Summary section
            _buildSummarySection(),
            
            // Backup section
            _buildBackupSection(),
            
            // Information section
            _buildInformationSection(),
            
            // Custom fields section
            if (_customFields.isNotEmpty) _buildCustomFieldsSection(),
            
            // Documents section
            _buildDocumentsSection(),
          ],
        ),
      ),
    );
  }

  // Build profile header
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Colors.white,
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: const Color(AppConstants.primaryColor),
            backgroundImage: _selfMember!.profileImagePath != null
                ? ImageHelper.getImageProvider(_selfMember!.profileImagePath!)
                : null,
            child: _selfMember!.profileImagePath == null
                ? const Icon(Icons.person, color: Colors.white, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selfMember!.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.textColor),
                  ),
                ),
                if (_selfMember!.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _selfMember!.email!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build summary section
  Widget _buildSummarySection() {
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Documents', '${_documents.length}'),
          Container(
            width: 1,
            height: 40,
            color: const Color(0xFFE5E7EB),
          ),
          _buildStatItem('Custom Fields', '${_customFields.length}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(AppConstants.primaryColor),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  // Build backup section
  Widget _buildBackupSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Backup & Restore',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textColor),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Back up all your family data, documents, and settings to the cloud. Restore your data anytime.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                if (_selfMember?.email == null || _selfMember!.email!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please add an email address to your profile to use backup.'),
                    ),
                  );
                  return;
                }
                
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BackupScreen(userEmail: _selfMember!.email!),
                  ),
                );
              },
              icon: const Icon(Icons.cloud_upload, color: Colors.white),
              label: const Text(
                'Backup',
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

  // Build information section
  Widget _buildInformationSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textColor),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Phone', _selfMember!.phone),
          _buildInfoRow('Date of Birth', _selfMember!.dateOfBirth),
          _buildInfoRow('Address', _selfMember!.address),
          if (_selfMember!.city != null || _selfMember!.state != null)
            _buildInfoRow(
              'City/State',
              '${_selfMember!.city ?? ''}${_selfMember!.city != null && _selfMember!.state != null ? ', ' : ''}${_selfMember!.state ?? ''}',
            ),
          _buildInfoRow('Student ID', _selfMember!.studentId),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(AppConstants.textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build custom fields section
  Widget _buildCustomFieldsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Fields',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textColor),
            ),
          ),
          const SizedBox(height: 16),
          ..._customFields.map((field) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            field.fieldName,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            field.fieldValue,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(AppConstants.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // Build documents section
  Widget _buildDocumentsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Documents',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(AppConstants.textColor),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddDocumentScreen(
                        preSelectedMember: _selfMember,
                      ),
                    ),
                  );
                  if (result == true) {
                    _loadData();
                  }
                },
                child: const Text('Add Document'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_documents.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No documents yet',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            )
          else
            ..._documents.map((doc) => DocumentItem(document: doc)),
        ],
      ),
    );
  }
}
