# My Family App - Testing Guide

## App Status
The app has been built and is ready for testing on the Android emulator.

## Key Features to Test

### 1. Biometric Authentication
- **Expected Behavior**: App should prompt for biometric authentication on launch
- **Test Steps**:
  1. Launch the app
  2. Should see authentication screen with fingerprint icon
  3. Authenticate using emulator's biometric (or PIN if biometric not available)
  4. Should navigate to dashboard after successful authentication

### 2. Dashboard Screen
- **Expected Behavior**: Shows family members in card-based list view
- **Test Steps**:
  1. After authentication, should see dashboard
  2. Search bar at top
  3. Summary card showing total family members
  4. "Add New Member" card with gradient background
  5. List of family members (empty initially)

### 3. Add Family Member
- **Expected Behavior**: Can add new family member with all fields
- **Test Steps**:
  1. Tap "Add New Member" card
  2. Fill in required fields (First Name, Last Name)
  3. Add optional fields (email, phone, address, etc.)
  4. Add custom fields if needed
  5. Tap "Save"
  6. Should return to dashboard with new member visible

### 4. View Member Details
- **Expected Behavior**: Shows all member information and documents
- **Test Steps**:
  1. Tap on a family member card
  2. Should see member detail screen with:
     - Profile picture/avatar
     - Summary stats (document count, custom fields count)
     - Information section
     - Custom fields section (if any)
     - Documents section
  3. Tap "Edit" to modify member
  4. Tap "Add Document" to add documents

### 5. Document Parsing
- **Expected Behavior**: Can upload and parse documents to extract information
- **Test Steps**:
  1. From member detail screen, tap "Add Document"
  2. Or from dashboard, use document scanner icon
  3. Select a document (PDF, image, or email)
  4. App should parse the document
  5. Extracted information should be displayed
  6. Select which family member to attach document to
  7. Tap "Save Document"
  8. Document should appear in member's document list

### 6. Search Functionality
- **Expected Behavior**: Can search for family members by name or email
- **Test Steps**:
  1. On dashboard, type in search bar
  2. Results should filter in real-time
  3. Clear search to see all members

### 7. Edit Member
- **Expected Behavior**: Can edit existing member information
- **Test Steps**:
  1. Open member detail screen
  2. Tap "Edit" button
  3. Modify fields
  4. Add/remove custom fields
  5. Save changes
  6. Verify changes are reflected

## UI Design Verification
- Cards should have rounded corners (12px radius)
- White background with subtle shadows
- Primary color: Cyan (#0891B2)
- Gradient buttons for primary actions
- Clean, modern typography
- Profile avatars in circular format

## Known Limitations
- PDF text extraction is basic (may need enhancement)
- Autofill service requires MethodChannel implementation for full functionality
- iOS autofill extension is a foundation (needs App Group setup for production)

## Testing Checklist
- [ ] App launches successfully
- [ ] Biometric authentication works
- [ ] Dashboard displays correctly
- [ ] Can add family member
- [ ] Can view member details
- [ ] Can edit member
- [ ] Can search members
- [ ] Can upload and parse documents
- [ ] Documents are saved correctly
- [ ] Custom fields work
- [ ] UI matches design reference

## Troubleshooting
- If biometric doesn't work: Check emulator settings for biometric configuration
- If documents don't parse: Check file permissions in Android settings
- If app crashes: Check logcat for error messages

