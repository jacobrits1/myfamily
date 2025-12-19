import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/family_member.dart';
import '../models/document.dart';
import '../services/document_parser_service.dart';
import '../services/storage_service.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';

// Document parsing screen for auto-filling information
class DocumentParseScreen extends StatefulWidget {
  final FamilyMember? preSelectedMember;
  
  const DocumentParseScreen({super.key, this.preSelectedMember});

  @override
  State<DocumentParseScreen> createState() => _DocumentParseScreenState();
}

class _DocumentParseScreenState extends State<DocumentParseScreen> {
  final DocumentParserService _parserService = DocumentParserService();
  final StorageService _storageService = StorageService();
  final DatabaseService _dbService = DatabaseService();

  File? _selectedFile;
  String? _fileType;
  Map<String, dynamic>? _parsedData;
  List<FamilyMember> _members = [];
  FamilyMember? _selectedMember;
  bool _isProcessing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
    if (widget.preSelectedMember != null) {
      _selectedMember = widget.preSelectedMember;
    }
  }

  // Load all family members
  Future<void> _loadMembers() async {
    final members = await _dbService.getAllFamilyMembers();
    setState(() {
      _members = members;
    });
  }

  // Pick and process document
  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final file = File(filePath);
        final extension = result.files.single.extension?.toLowerCase() ?? '';

        setState(() {
          _selectedFile = file;
          _fileType = _determineFileType(extension);
          _parsedData = null;
          if (widget.preSelectedMember == null) {
            _selectedMember = null;
          }
        });

        await _processDocument();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking file: $e')),
        );
      }
    }
  }

  // Determine file type from extension
  String _determineFileType(String extension) {
    if (['pdf'].contains(extension)) {
      return 'pdf';
    } else if (['jpg', 'jpeg', 'png', 'gif', 'bmp'].contains(extension)) {
      return 'image';
    } else if (['eml', 'msg'].contains(extension)) {
      return 'email';
    }
    return 'unknown';
  }

  // Process document and extract information
  Future<void> _processDocument() async {
    if (_selectedFile == null || _fileType == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final parsedData = await _parserService.parseDocument(
        _selectedFile!.path,
        _fileType!,
      );

      setState(() {
        _parsedData = parsedData;
        _isProcessing = false;
      });

      // Try to match to existing member
      if (parsedData['parsed_fields'] != null) {
        await _suggestMember(parsedData['parsed_fields'] as Map<String, String>);
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error processing document: $e')),
        );
      }
    }
  }

  // Suggest member based on parsed data
  Future<void> _suggestMember(Map<String, String> parsedFields) async {
    // Simple matching logic - can be improved
    for (final member in _members) {
      // Match by email
      if (parsedFields['email'] != null &&
          member.email?.toLowerCase() == parsedFields['email']?.toLowerCase()) {
        setState(() {
          _selectedMember = member;
        });
        return;
      }

      // Match by name
      if (parsedFields['first_name'] != null &&
          parsedFields['last_name'] != null) {
        if (member.firstName.toLowerCase() ==
                parsedFields['first_name']!.toLowerCase() &&
            member.lastName.toLowerCase() ==
                parsedFields['last_name']!.toLowerCase()) {
          setState(() {
            _selectedMember = member;
          });
          return;
        }
      }

      // Match by student ID
      if (parsedFields['student_id'] != null &&
          member.studentId == parsedFields['student_id']) {
        setState(() {
          _selectedMember = member;
        });
        return;
      }
    }
  }

  // Save document and update member
  Future<void> _saveDocument() async {
    if (_selectedFile == null || _selectedMember == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a member')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Save file
      final fileName = _selectedFile!.path.split('/').last;
      final savedPath = await _storageService.saveFile(_selectedFile!, fileName);

      // Create document record
      final document = Document(
        memberId: _selectedMember!.id!,
        fileName: fileName,
        filePath: savedPath,
        fileType: _fileType ?? 'unknown',
        parsedData: _parsedData != null
            ? _parsedData.toString()
            : null,
      );

      await _dbService.insertDocument(document);

      // Update member with parsed fields if available
      if (_parsedData != null &&
          _parsedData!['parsed_fields'] != null) {
        final parsedFields =
            _parsedData!['parsed_fields'] as Map<String, String>;
        final updatedMember = _selectedMember!.copyWith(
          email: parsedFields['email'] ?? _selectedMember!.email,
          phone: parsedFields['phone'] ?? _selectedMember!.phone,
          dateOfBirth: parsedFields['date_of_birth'] ?? _selectedMember!.dateOfBirth,
          studentId: parsedFields['student_id'] ?? _selectedMember!.studentId,
        );

        await _dbService.updateFamilyMember(updatedMember);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving document: $e')),
        );
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
          icon: const Icon(Icons.arrow_back, color: Color(AppConstants.textColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Parse Document',
          style: TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File picker button
            Card(
              child: InkWell(
                onTap: _pickDocument,
                borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.upload_file,
                        size: 32,
                        color: Color(AppConstants.primaryColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Select Document',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedFile?.path.split('/').last ?? 'No file selected',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_isProcessing) ...[
              const SizedBox(height: 24),
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 8),
              const Center(
                child: Text('Processing document...'),
              ),
            ],

            // Parsed data display
            if (_parsedData != null && !_isProcessing) ...[
              const SizedBox(height: 24),
              _buildParsedDataCard(),
            ],

            // Member selection
            if (_parsedData != null && !_isProcessing) ...[
              const SizedBox(height: 24),
              _buildMemberSelectionCard(),
            ],

            // Save button
            if (_selectedFile != null &&
                _selectedMember != null &&
                !_isProcessing) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveDocument,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.primaryColor),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Document',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Build parsed data card
  Widget _buildParsedDataCard() {
    final parsedFields = _parsedData!['parsed_fields'] as Map<String, String>?;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Extracted Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (parsedFields != null && parsedFields.isNotEmpty)
              ...parsedFields.entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            entry.key.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(AppConstants.textColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
            else
              const Text(
                'No information extracted',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
          ],
        ),
      ),
    );
  }

  // Build member selection card
  Widget _buildMemberSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Family Member',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (_members.isEmpty)
              const Text('No family members found. Please add a member first.')
            else
              ..._members.map((member) => RadioListTile<FamilyMember>(
                    title: Text(member.fullName),
                    subtitle: member.email != null
                        ? Text(member.email!)
                        : null,
                    value: member,
                    groupValue: _selectedMember,
                    onChanged: (value) {
                      setState(() {
                        _selectedMember = value;
                      });
                    },
                  )),
          ],
        ),
      ),
    );
  }
}

