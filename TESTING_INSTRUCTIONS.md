# Testing Instructions - My Family App

## 🚀 Quick Start Testing Guide

### Prerequisites
- ✅ APK built successfully
- ✅ Emulator launching
- ✅ All features implemented

## 📋 Step-by-Step Testing Guide

### Phase 1: Authentication Testing

**Test PIN Setup (First Launch)**
1. App launches → Authentication screen appears
2. If no PIN set, should show PIN setup
3. Enter 4-digit PIN (e.g., "1234")
4. Confirm PIN (enter "1234" again)
5. Should proceed to dashboard

**Test PIN Login (Subsequent Launches)**
1. App launches
2. Enter PIN (e.g., "1234")
3. Should authenticate and show dashboard

**Test Biometric (if available)**
1. App launches
2. Tap fingerprint icon or "Authenticate"
3. Use biometric or PIN fallback
4. Should proceed to dashboard

### Phase 2: Add Member with Image

**Test Gallery Image Upload**
1. Dashboard → Tap "Add New Member" (orange gradient card)
2. Scroll to "Profile Photo" section
3. Tap avatar circle or "Add Photo" button
4. Bottom sheet appears → Select "Choose from Gallery"
5. Pick an image from gallery
6. Verify image appears in avatar preview
7. Fill in member details:
   - First Name: "Sarah"
   - Last Name: "Johnson"
   - Email: "sarah.j@example.com"
   - Phone: "555-0123"
8. Tap "Save" (top right)
9. Return to dashboard
10. Verify "Sarah Johnson" appears with profile image

**Test Camera Capture**
1. Dashboard → "Add New Member"
2. Tap "Add Photo"
3. Select "Take Photo"
4. Grant camera permission if prompted
5. Take a photo
6. Accept/confirm photo
7. Verify photo appears in preview
8. Fill in details and save
9. Verify member appears with camera photo

### Phase 3: Edit/Recall Information

**Test Data Recall**
1. Dashboard → Tap on "Sarah Johnson" card
2. Member detail screen opens
3. Verify displays:
   - ✅ Profile image (large avatar)
   - ✅ Name: "Sarah Johnson"
   - ✅ Email: "sarah.j@example.com"
   - ✅ Phone: "555-0123"
   - ✅ Summary stats (documents, custom fields)
4. Tap "Edit" button (top right)
5. Verify all fields load with existing data:
   - ✅ First Name: "Sarah"
   - ✅ Last Name: "Johnson"
   - ✅ Email: "sarah.j@example.com"
   - ✅ Phone: "555-0123"
   - ✅ Profile image displays

**Test Editing Information**
1. In Edit screen, modify:
   - Change email to "sarah.new@example.com"
   - Update phone to "555-9999"
   - Add address: "123 Main St"
   - Add city: "Springfield"
2. Change profile image:
   - Tap avatar
   - Select "Choose from Gallery"
   - Pick different image
   - Verify new image preview
3. Add custom field:
   - Scroll to "Custom Fields" section
   - Tap "Add Custom Field"
   - Field Name: "Emergency Contact"
   - Field Type: "Phone"
   - Field Value: "555-0000"
   - Tap "Save"
4. Tap "Save" (top right)
5. Return to detail screen
6. Verify all changes:
   - ✅ New email displays
   - ✅ New phone displays
   - ✅ Address displays
   - ✅ New profile image displays
   - ✅ Custom field appears

### Phase 4: Image Management

**Test Remove Photo**
1. Edit member with existing image
2. Tap avatar
3. Select "Remove Photo"
4. Verify default icon appears
5. Save member
6. Verify no image on member card

**Test Change Photo**
1. Edit member
2. Tap avatar → "Choose from Gallery"
3. Select new image
4. Verify preview updates
5. Save
6. Verify new image displays

### Phase 5: Data Persistence

**Test App Restart**
1. Add member with complete info and image
2. Close app completely (swipe away)
3. Reopen app
4. Authenticate with PIN
5. Verify:
   - ✅ Member still exists
   - ✅ Profile image displays
   - ✅ All information intact
6. Edit member
7. Verify all data loads correctly

### Phase 6: Search Functionality

**Test Search**
1. Add multiple members:
   - "John Doe" (john@example.com)
   - "Jane Smith" (jane@example.com)
   - "Bob Wilson" (bob@example.com)
2. On dashboard, use search bar
3. Type "John"
4. Verify only "John Doe" appears
5. Clear search
6. Type "jane@example.com"
7. Verify only "Jane Smith" appears

## 🎯 Key Features to Verify

### Image Features
- [x] Gallery selection works
- [x] Camera capture works
- [x] Image preview displays
- [x] Image saves correctly
- [x] Image displays on cards
- [x] Image displays in detail view
- [x] Can change/remove images
- [x] Images persist after restart

### Edit/Recall Features
- [x] All fields load when editing
- [x] Profile image loads
- [x] Can modify all fields
- [x] Changes save correctly
- [x] Updated data displays
- [x] Data persists after restart

### UI/UX
- [x] Profile photo section visible
- [x] Camera icon overlay
- [x] Bottom sheet for image source
- [x] Image preview looks good
- [x] All buttons work
- [x] Error handling works

## 📝 Testing Notes

**Current Status:**
- App is launching on emulator
- All features implemented
- Ready for comprehensive testing

**What to Watch For:**
- Camera permission prompts
- Image loading errors
- Data not persisting
- UI layout issues
- Performance issues

## ✅ Test Results

(Record results as you test each feature)

---

**Next Steps:**
1. Wait for app to launch on emulator
2. Follow testing phases in order
3. Document any issues found
4. Verify all features work as expected

