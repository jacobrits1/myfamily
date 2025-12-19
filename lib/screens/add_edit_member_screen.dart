import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/family_member.dart';
import '../models/custom_field.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../utils/constants.dart';

// Add/Edit member screen
class AddEditMemberScreen extends StatefulWidget {
  final FamilyMember? member;

  const AddEditMemberScreen({super.key, this.member});

  @override
  State<AddEditMemberScreen> createState() => _AddEditMemberScreenState();
}

class _AddEditMemberScreenState extends State<AddEditMemberScreen> {
  final DatabaseService _dbService = DatabaseService();
  final StorageService _storageService = StorageService();
  final ImagePicker _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _ssnController = TextEditingController();
  final TextEditingController _studentIdController = TextEditingController();

  List<CustomField> _customFields = [];
  bool _isLoading = false;
  String? _profileImagePath;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _loadMemberData();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _ssnController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }

  // Load member data for editing
  Future<void> _loadMemberData() async {
    if (widget.member == null) return;

    _firstNameController.text = widget.member!.firstName;
    _lastNameController.text = widget.member!.lastName;
    _dateOfBirthController.text = widget.member!.dateOfBirth ?? '';
    _phoneController.text = widget.member!.phone ?? '';
    _emailController.text = widget.member!.email ?? '';
    _addressController.text = widget.member!.address ?? '';
    _cityController.text = widget.member!.city ?? '';
    _stateController.text = widget.member!.state ?? '';
    _zipCodeController.text = widget.member!.zipCode ?? '';
    _ssnController.text = widget.member!.ssn ?? '';
    _studentIdController.text = widget.member!.studentId ?? '';
    
    // Load profile image
    if (widget.member!.profileImagePath != null) {
      setState(() {
        _profileImagePath = widget.member!.profileImagePath;
        _selectedImage = File(widget.member!.profileImagePath!);
      });
    }

    // Load custom fields
    if (widget.member!.id != null) {
      final customFields = await _dbService.getCustomFieldsForMember(widget.member!.id!);
      setState(() {
        _customFields = customFields;
      });
    }
  }

  // Save member
  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save profile image if new one selected
      String? savedImagePath = _profileImagePath;
      if (_selectedImage != null && _selectedImage!.path != _profileImagePath) {
        final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
        savedImagePath = await _storageService.saveImage(_selectedImage!, fileName);
      }

      final member = FamilyMember(
        id: widget.member?.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _dateOfBirthController.text.trim().isEmpty
            ? null
            : _dateOfBirthController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty
            ? null
            : _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim().isEmpty
            ? null
            : _zipCodeController.text.trim(),
        ssn: _ssnController.text.trim().isEmpty
            ? null
            : _ssnController.text.trim(),
        studentId: _studentIdController.text.trim().isEmpty
            ? null
            : _studentIdController.text.trim(),
        profileImagePath: savedImagePath,
      );

      int memberId;
      if (widget.member?.id != null) {
        // Update existing member
        await _dbService.updateFamilyMember(member);
        memberId = widget.member!.id!;
      } else {
        // Insert new member
        memberId = await _dbService.insertFamilyMember(member);
      }

      // Save custom fields
      for (final field in _customFields) {
        if (field.id == null) {
          // New custom field
          await _dbService.insertCustomField(
            field.copyWith(memberId: memberId),
          );
        } else {
          // Update existing custom field
          await _dbService.updateCustomField(field);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving member: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  // Show image source selection dialog
  Future<void> _showImageSourceDialog() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_selectedImage != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedImage = null;
                    _profileImagePath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  // Add custom field
  void _addCustomField() {
    showDialog(
      context: context,
      builder: (context) => _CustomFieldDialog(
        onSave: (fieldName, fieldType, fieldValue) {
          setState(() {
            _customFields.add(
              CustomField(
                memberId: widget.member?.id ?? 0,
                fieldName: fieldName,
                fieldType: fieldType,
                fieldValue: fieldValue,
              ),
            );
          });
        },
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(AppConstants.textColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.member == null ? 'Add Member' : 'Edit Member',
          style: const TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveMember,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(AppConstants.primaryColor),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
          child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Image Card
            _buildCard(
              'Profile Photo',
              [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showImageSourceDialog,
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60,
                              backgroundColor: const Color(AppConstants.primaryColor),
                              backgroundImage: _selectedImage != null
                                  ? FileImage(_selectedImage!)
                                  : null,
                              child: _selectedImage == null
                                  ? const Icon(Icons.person, color: Colors.white, size: 60)
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(AppConstants.primaryColor),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _showImageSourceDialog,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: Text(
                          _selectedImage != null ? 'Change Photo' : 'Add Photo',
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(AppConstants.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Basic Information Card
            _buildCard(
              'Basic Information',
              [
                _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  required: true,
                ),
                _buildTextField(
                  controller: _lastNameController,
                  label: 'Last Name',
                  required: true,
                ),
                _buildTextField(
                  controller: _dateOfBirthController,
                  label: 'Date of Birth',
                  hint: 'YYYY-MM-DD',
                ),
              ],
            ),

            // Contact Information Card
            _buildCard(
              'Contact Information',
              [
                _buildTextField(
                  controller: _emailController,
                  label: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                _buildTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),

            // Address Information Card
            _buildCard(
              'Address',
              [
                _buildTextField(controller: _addressController, label: 'Address'),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(controller: _cityController, label: 'City'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(controller: _stateController, label: 'State'),
                    ),
                  ],
                ),
                _buildTextField(
                  controller: _zipCodeController,
                  label: 'Zip Code',
                  keyboardType: TextInputType.number,
                ),
              ],
            ),

            // Additional Information Card
            _buildCard(
              'Additional Information',
              [
                _buildTextField(
                  controller: _studentIdController,
                  label: 'Student ID',
                ),
                _buildTextField(
                  controller: _ssnController,
                  label: 'SSN',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ],
            ),

            // Custom Fields Card
            _buildCard(
              'Custom Fields',
              [
                ..._customFields.map((field) => _buildCustomFieldItem(field)),
                ElevatedButton.icon(
                  onPressed: _addCustomField,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Custom Field'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(AppConstants.primaryColor),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.textColor),
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    bool required = false,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: required
            ? (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildCustomFieldItem(CustomField field) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(field.fieldName),
        subtitle: Text('${field.fieldType}: ${field.fieldValue}'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            setState(() {
              _customFields.remove(field);
            });
          },
        ),
      ),
    );
  }
}

// Custom field dialog
class _CustomFieldDialog extends StatefulWidget {
  final Function(String, String, String) onSave;

  const _CustomFieldDialog({required this.onSave});

  @override
  State<_CustomFieldDialog> createState() => _CustomFieldDialogState();
}

class _CustomFieldDialogState extends State<_CustomFieldDialog> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  String _selectedType = 'text';

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Custom Field'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Field Name'),
          ),
          const SizedBox(height: 16),
            DropdownButtonFormField<String>(
            initialValue: _selectedType,
            decoration: const InputDecoration(labelText: 'Field Type'),
            items: const [
              DropdownMenuItem(value: 'text', child: Text('Text')),
              DropdownMenuItem(value: 'number', child: Text('Number')),
              DropdownMenuItem(value: 'date', child: Text('Date')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
              DropdownMenuItem(value: 'phone', child: Text('Phone')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value ?? 'text';
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            decoration: const InputDecoration(labelText: 'Field Value'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty &&
                _valueController.text.isNotEmpty) {
              widget.onSave(
                _nameController.text,
                _selectedType,
                _valueController.text,
              );
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

