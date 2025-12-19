# Quick Test Steps - My Family App

## 🚀 App is Launching on Emulator

### Immediate Tests to Perform

#### 1. Authentication (30 seconds)
- [ ] App launches → See authentication screen
- [ ] Set up PIN: Enter "1234" → Confirm "1234"
- [ ] Dashboard appears

#### 2. Add Member with Photo (1 minute)
- [ ] Tap "Add New Member" (orange gradient card)
- [ ] Tap avatar or "Add Photo"
- [ ] Select "Choose from Gallery"
- [ ] Pick an image → See preview
- [ ] Fill: First Name "John", Last Name "Doe", Email "john@test.com"
- [ ] Tap "Save" (top right)
- [ ] See member card with image on dashboard

#### 3. Add Document with Title (1 minute)
- [ ] Tap on "John Doe" card
- [ ] Tap "Add Document" button
- [ ] Enter Title: "School Report"
- [ ] Tap "Gallery" button
- [ ] Select image → **Use back button to return**
- [ ] See image preview (200x200 area)
- [ ] Tap "Save"
- [ ] See document "School Report" in list

#### 4. Test Camera (30 seconds)
- [ ] Tap "Add Document" again
- [ ] Enter Title: "Photo Document"
- [ ] Tap "Camera" button
- [ ] Grant permission → Take photo
- [ ] See preview → Save
- [ ] Document appears with title

#### 5. Edit/Recall (1 minute)
- [ ] Tap on "John Doe" card
- [ ] Tap "Edit" button (top right)
- [ ] **Verify all fields load:**
  - [ ] Name: "John Doe"
  - [ ] Email: "john@test.com"
  - [ ] Profile image displays
- [ ] Change email to "john.new@test.com"
- [ ] Tap "Save"
- [ ] Verify email updated in detail view

#### 6. Persistence Test (30 seconds)
- [ ] Close app (swipe away)
- [ ] Reopen app
- [ ] Enter PIN "1234"
- [ ] **Verify:**
  - [ ] "John Doe" still exists
  - [ ] Profile image displays
  - [ ] Documents with titles exist
  - [ ] All information intact

## ✅ Success Criteria

All tests should complete without errors:
- ✅ PIN authentication works
- ✅ Images upload from gallery
- ✅ Camera captures photos
- ✅ Documents save with titles
- ✅ Easy navigation back from gallery
- ✅ All data recalls when editing
- ✅ Data persists after restart

## 🎯 Total Test Time: ~5 minutes

**Status:** App launching, ready to test!

