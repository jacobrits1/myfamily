import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

// Document parser service for extracting information from documents
class DocumentParserService {
  static final DocumentParserService _instance = DocumentParserService._internal();
  factory DocumentParserService() => _instance;
  DocumentParserService._internal();

  final TextRecognizer _textRecognizer = TextRecognizer();

  // Parse document based on type
  Future<Map<String, dynamic>> parseDocument(String filePath, String fileType) async {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return await parsePDF(filePath);
      case 'image':
        return await parseImage(filePath);
      case 'email':
        return await parseEmail(filePath);
      default:
        return {'error': 'Unsupported file type'};
    }
  }

  // Parse PDF file
  Future<Map<String, dynamic>> parsePDF(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      // Use pdf package to extract text
      // Note: pdf package is primarily for creating PDFs, not parsing
      // For better PDF parsing, consider using pdf_text or syncfusion_flutter_pdf
      // For now, we'll return basic info and extracted text if possible
      
      final extractedData = <String, dynamic>{
        'file_name': file.path.split('/').last,
        'file_type': 'pdf',
        'file_size': bytes.length,
        'extracted_text': '', // PDF text extraction would go here
        'parsed_fields': <String, String>{},
      };

      // Try to extract common fields from filename or metadata
      _extractCommonFields(extractedData, file.path.split('/').last);

      return extractedData;
    } catch (e) {
      return {'error': 'Failed to parse PDF: $e'};
    }
  }

  // Parse image file using OCR
  Future<Map<String, dynamic>> parseImage(String filePath) async {
    try {
      final file = File(filePath);
      final inputImage = InputImage.fromFilePath(filePath);
      
      // Perform OCR
      final recognizedText = await _textRecognizer.processImage(inputImage);
      
      final extractedData = <String, dynamic>{
        'file_name': file.path.split('/').last,
        'file_type': 'image',
        'file_size': await file.length(),
        'extracted_text': recognizedText.text,
        'parsed_fields': <String, String>{},
      };

      // Extract common fields from OCR text
      _extractFieldsFromText(extractedData, recognizedText.text);

      return extractedData;
    } catch (e) {
      return {'error': 'Failed to parse image: $e'};
    } finally {
      // Note: Don't close the recognizer if it might be used again
      // await _textRecognizer.close();
    }
  }

  // Parse email file
  Future<Map<String, dynamic>> parseEmail(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      
      final extractedData = <String, dynamic>{
        'file_name': file.path.split('/').last,
        'file_type': 'email',
        'file_size': content.length,
        'extracted_text': content,
        'parsed_fields': <String, String>{},
      };

      // Extract email fields
      _extractEmailFields(extractedData, content);

      return extractedData;
    } catch (e) {
      return {'error': 'Failed to parse email: $e'};
    }
  }

  // Extract common fields from text
  void _extractFieldsFromText(Map<String, dynamic> data, String text) {
    final parsedFields = <String, String>{};

    // Extract name patterns
    final namePattern = RegExp(r'\b([A-Z][a-z]+)\s+([A-Z][a-z]+)\b');
    final nameMatch = namePattern.firstMatch(text);
    if (nameMatch != null) {
      parsedFields['first_name'] = nameMatch.group(1) ?? '';
      parsedFields['last_name'] = nameMatch.group(2) ?? '';
    }

    // Extract email
    final emailPattern = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final emailMatch = emailPattern.firstMatch(text);
    if (emailMatch != null) {
      parsedFields['email'] = emailMatch.group(0) ?? '';
    }

    // Extract phone
    final phonePattern = RegExp(r'\b\d{3}[-.]?\d{3}[-.]?\d{4}\b');
    final phoneMatch = phonePattern.firstMatch(text);
    if (phoneMatch != null) {
      parsedFields['phone'] = phoneMatch.group(0) ?? '';
    }

    // Extract date of birth
    final dobPattern = RegExp(r'\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b');
    final dobMatch = dobPattern.firstMatch(text);
    if (dobMatch != null) {
      parsedFields['date_of_birth'] = dobMatch.group(0) ?? '';
    }

    // Extract student ID
    final studentIdPattern = RegExp(r'(?i)student\s*id[:\s]*(\w+)');
    final studentIdMatch = studentIdPattern.firstMatch(text);
    if (studentIdMatch != null) {
      parsedFields['student_id'] = studentIdMatch.group(1) ?? '';
    }

    // Extract SSN
    final ssnPattern = RegExp(r'\b\d{3}-\d{2}-\d{4}\b');
    final ssnMatch = ssnPattern.firstMatch(text);
    if (ssnMatch != null) {
      parsedFields['ssn'] = ssnMatch.group(0) ?? '';
    }

    data['parsed_fields'] = parsedFields;
  }

  // Extract common fields from filename
  void _extractCommonFields(Map<String, dynamic> data, String fileName) {
    final parsedFields = <String, String>{};

    // Try to extract student ID from filename
    final studentIdPattern = RegExp(r'(\d{6,})');
    final studentIdMatch = studentIdPattern.firstMatch(fileName);
    if (studentIdMatch != null) {
      parsedFields['student_id'] = studentIdMatch.group(1) ?? '';
    }

    data['parsed_fields'] = parsedFields;
  }

  // Extract email fields
  void _extractEmailFields(Map<String, dynamic> data, String content) {
    final parsedFields = <String, String>{};

    // Extract from email headers
    final fromPattern = RegExp(r'From:\s*(.+?)(?:\n|$)');
    final fromMatch = fromPattern.firstMatch(content);
    if (fromMatch != null) {
      final fromLine = fromMatch.group(1) ?? '';
      // Extract email from "Name <email@domain.com>" or just "email@domain.com"
      final emailPattern = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
      final emailMatch = emailPattern.firstMatch(fromLine);
      if (emailMatch != null) {
        parsedFields['email'] = emailMatch.group(0) ?? '';
      }
    }

    // Extract subject
    final subjectPattern = RegExp(r'Subject:\s*(.+?)(?:\n|$)');
    final subjectMatch = subjectPattern.firstMatch(content);
    if (subjectMatch != null) {
      parsedFields['subject'] = subjectMatch.group(1)?.trim() ?? '';
    }

    // Extract fields from email body
    _extractFieldsFromText(data, content);

    data['parsed_fields'] = parsedFields;
  }

  // Match parsed data to family member
  Future<int?> matchToMember(Map<String, dynamic> parsedData) async {
    // This would match extracted fields to existing family members
    // For now, return null (no match found)
    // Implementation would query database and find best match
    return null;
  }

  // Dispose resources
  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}

