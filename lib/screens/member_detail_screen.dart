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

// Member detail screen
class MemberDetailScreen extends StatefulWidget {
  final FamilyMember member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  final DatabaseService _dbService = DatabaseService();
  List<Document> _documents = [];
  List<CustomField> _customFields = [];
  FamilyMember? _currentMember;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentMember = widget.member;
    _loadData();
  }

  // Load member data, documents, and custom fields
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Refresh member data
      final member = await _dbService.getFamilyMemberById(widget.member.id!);
      if (member != null) {
        _currentMember = member;
      }

      // Load documents
      final documents = await _dbService.getDocumentsForMember(widget.member.id!);
      
      // Load custom fields
      final customFields = await _dbService.getCustomFieldsForMember(widget.member.id!);

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
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  // Navigate to edit screen
  Future<void> _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditMemberScreen(member: _currentMember),
      ),
    );

    if (result == true) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _currentMember == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
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
        title: Text(
          _currentMember!.fullName,
          style: const TextStyle(
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
            backgroundImage: _currentMember!.profileImagePath != null
                ? ImageHelper.getImageProvider(_currentMember!.profileImagePath!)
                : null,
            child: _currentMember!.profileImagePath == null
                ? const Icon(Icons.person, color: Colors.white, size: 40)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentMember!.fullName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(AppConstants.textColor),
                  ),
                ),
                if (_currentMember!.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _currentMember!.email!,
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
          _buildInfoRow('Phone', _currentMember!.phone),
          _buildInfoRow('Date of Birth', _currentMember!.dateOfBirth),
          _buildInfoRow('Address', _currentMember!.address),
          if (_currentMember!.city != null || _currentMember!.state != null)
            _buildInfoRow(
              'City/State',
              '${_currentMember!.city ?? ''}${_currentMember!.city != null && _currentMember!.state != null ? ', ' : ''}${_currentMember!.state ?? ''}',
            ),
          _buildInfoRow('Student ID', _currentMember!.studentId),
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
                        preSelectedMember: _currentMember,
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

