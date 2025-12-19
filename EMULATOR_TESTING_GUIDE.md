# Emulator Testing Guide - My Family App

## ✅ Build Status
- **APK Built:** ✅ Successfully
- **Emulator:** ✅ Running (emulator-5554)
- **App Launch:** ⏳ In Progress

## 🧪 Complete Testing Checklist

### Phase 1: Authentication Testing

#### Test PIN Setup (First Launch)
1. App launches → Authentication screen appears
2. Should prompt for PIN setup (if no PIN exists)
3. Enter 4-digit PIN (e.g., "1234")
4. Confirm PIN (enter "1234" again)
5. ✅ Should proceed to dashboard

#### Test PIN Login
1. Close and reopen app
2. Enter PIN ("1234")
3. ✅ Should authenticate and show dashboard

#### Test Biometric (if available)
1. App launches
2. Tap fingerprint icon
3. Use biometric or PIN fallback
4. ✅ Should proceed to dashboard

### Phase 2: Add Family Member with Profile Photo

#### Test Gallery Image Upload
1. Dashboard → Tap "Add New Member"
2. Scroll to "Profile Photo" section
3. Tap avatar or "Add Photo"
4. Select "Choose from Gallery"
5. Pick an image
6. ✅ Verify image preview appears
7. Fill in:
   - First Name: "John"
   - Last Name: "Doe"
   - Email: "john@example.com"
   - Phone: "555-1234"
8. Tap "Save"
9. ✅ Verify member appears with image on dashboard

#### Test Camera Capture
1. Add another member
2. Tap "Add Photo"
3. Select "Take Photo"
4. Grant camera permission
5. Take a photo
6. Accept photo
7. ✅ Verify photo preview
8. Fill details and save
9. ✅ Verify member with camera photo appears

### Phase 3: Add Document with Title

#### Test Document Add with Camera
1. Tap on a member card
2. Tap "Add Document" button
3. **Enter Title:** "School Report Card"
4. Tap "Camera" button
5. Take a photo
6. ✅ Verify image preview appears (200x200 area)
7. Select family member (if not pre-selected)
8. Tap "Save" (top right)
9. ✅ Verify document appears in list with title "School Report Card"

#### Test Document Add with Gallery
1. Member Detail → "Add Document"
2. **Enter Title:** "Medical Record"
3. Tap "Gallery" button
4. Select image from gallery
5. ✅ **Easy Navigation:** Use back button to return
6. ✅ Verify image preview appears
7. Select member
8. Tap "Save"
9. ✅ Verify document appears with title "Medical Record"

#### Test Document Title Display
1. View member's documents list
2. ✅ Verify documents show custom titles (not filenames)
3. ✅ Verify document type and date display

### Phase 4: Edit/Recall Information

#### Test Data Recall
1. Tap on a member card
2. ✅ Verify all information displays:
   - Profile image
   - Name, email, phone
   - Address, city, state
   - Custom fields
   - Documents with titles
3. Tap "Edit" button
4. ✅ Verify all fields load with existing data:
   - First Name, Last Name
   - Email, Phone
   - Address fields
   - Profile image displays
   - Custom fields load

#### Test Editing
1. In Edit screen, modify:
   - Change email
   - Update phone
   - Change profile image (gallery or camera)
2. Add custom field
3. Tap "Save"
4. Return to detail screen
5. ✅ Verify all changes reflected

### Phase 5: Image Management

#### Test Change Profile Image
1. Edit member
2. Tap avatar
3. Select "Choose from Gallery" or "Take Photo"
4. Select new image
5. ✅ Verify preview updates
6. Save
7. ✅ Verify new image on member card

#### Test Remove Profile Image
1. Edit member with image
2. Tap avatar
3. Select "Remove Photo"
4. ✅ Verify default icon appears
5. Save
6. ✅ Verify no image on card

### Phase 6: Data Persistence

#### Test App Restart
1. Add member with complete info and image
2. Add document with title
3. Close app completely
4. Reopen app
5. Authenticate
6. ✅ Verify:
   - Member still exists
   - Profile image displays
   - Document with title exists
   - All information intact

### Phase 7: Search Functionality

#### Test Search
1. Add multiple members
2. Use search bar
3. Type "John"
4. ✅ Verify only "John Doe" appears
5. Clear search
6. Type email
7. ✅ Verify filtering works

## 🎯 Key Features to Verify

### Document Add Feature (NEW)
- [ ] Title field accepts input
- [ ] Camera button works
- [ ] Gallery button works
- [ ] Easy navigation back from gallery
- [ ] Image preview displays (200x200)
- [ ] Can change image before saving
- [ ] Member selection works
- [ ] Documents save with titles
- [ ] Titles display in document list

### Profile Images
- [ ] Gallery upload works
- [ ] Camera capture works
- [ ] Images display on cards
- [ ] Images display in detail view
- [ ] Can change images
- [ ] Can remove images
- [ ] Images persist

### Edit/Recall
- [ ] All fields load when editing
- [ ] Profile image loads
- [ ] Can modify all fields
- [ ] Changes save correctly
- [ ] Data persists

## 📱 Testing Notes

**Emulator:** emulator-5554 (Android 14)
**Build:** Debug APK
**Status:** App launching

**What to Watch For:**
- Camera permission prompts
- Gallery navigation
- Image loading
- Data persistence
- Title display in documents

## ✅ Expected Results

All features should work smoothly:
- ✅ PIN authentication
- ✅ Image upload from gallery
- ✅ Camera capture
- ✅ Document add with title
- ✅ Easy gallery navigation
- ✅ Edit/recall all information
- ✅ Data persistence

**Ready for comprehensive testing!**

