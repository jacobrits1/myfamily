# Autofill Testing Guide

## 🎯 Overview

This guide explains how to test the autofill functionality that allows other apps (like WhatsApp, forms, etc.) to access family member data from the My Family app.

## 📱 How Android Autofill Works

The My Family app implements Android's Autofill Framework, which allows it to:
1. **Detect fillable fields** in other apps (email, phone, name, address, etc.)
2. **Provide suggestions** from family member data
3. **Auto-populate fields** when user selects a suggestion
4. **Access documents** stored in the app (via file paths)

## ✅ Prerequisites

1. **Enable Autofill Service:**
   - Go to Android Settings → System → Languages & input → Autofill service
   - Select "My Family" or "myfamily" from the list
   - Grant necessary permissions

2. **Add Family Members:**
   - Open My Family app
   - Add at least one family member with:
     - First Name
     - Last Name
     - Email (optional but recommended)
     - Phone (optional but recommended)
     - Address (optional)

3. **Test Apps:**
   - WhatsApp (for contact forms)
   - Chrome/Web Browser (for web forms)
   - Any app with text input fields

## 🧪 Testing Steps

### Test 1: Enable Autofill Service

1. **Open Android Settings**
   ```
   Settings → System → Languages & input → Autofill service
   ```

2. **Select My Family**
   - Tap "Autofill service"
   - Select "myfamily" or "My Family"
   - Grant any requested permissions

3. **Verify Service is Active**
   - You should see "myfamily" listed as the active autofill service
   - Status should show as "On" or "Active"

### Test 2: Test in WhatsApp

1. **Open WhatsApp**
   - Go to Settings → Profile
   - Tap to edit your name or phone number

2. **Trigger Autofill**
   - Tap on a text field (name, phone, etc.)
   - You should see an autofill suggestion appear
   - The suggestion should show data from your family member

3. **Select Suggestion**
   - Tap the autofill suggestion
   - Field should populate with family member data

### Test 3: Test in Web Forms

1. **Open Chrome/Browser**
   - Navigate to any website with a form (e.g., contact form, signup form)
   - Look for fields like:
     - Name
     - Email
     - Phone
     - Address

2. **Trigger Autofill**
   - Tap on a field (e.g., "Email" or "Name")
   - Autofill suggestion should appear above keyboard
   - Suggestion should show family member data

3. **Fill Multiple Fields**
   - Select the autofill suggestion
   - Multiple related fields should populate automatically
   - For example: Name, Email, Phone all fill at once

### Test 4: Test Document Access

1. **Add Document to Family Member**
   - In My Family app, add a document to a family member
   - Document should be saved with a file path

2. **Access Document Path**
   - The autofill service can access document file paths
   - Documents are stored in: `/data/data/com.example.myfamily/files/documents/`
   - File paths are accessible via the database

3. **Share Document**
   - Documents can be shared via Android's share intent
   - Other apps can request document access through autofill

## 🔍 What Data is Available for Autofill

The autofill service provides the following data from the most recently updated family member:

- **Name Fields:**
  - First Name
  - Last Name
  - Full Name (First + Last)

- **Contact Fields:**
  - Email Address
  - Phone Number

- **Address Fields:**
  - Street Address
  - City
  - State
  - ZIP Code

- **Documents:**
  - Document file paths (accessible via database)
  - Document titles
  - Document types (PDF, image, email)

## 🐛 Troubleshooting

### Autofill Not Appearing

1. **Check Service is Enabled:**
   - Settings → System → Languages & input → Autofill service
   - Ensure "myfamily" is selected

2. **Check App Has Data:**
   - Open My Family app
   - Verify at least one family member exists
   - Verify member has data in relevant fields

3. **Check Field Hints:**
   - The target app must use proper autofill hints
   - Common hints: `emailAddress`, `phone`, `personName`, `postalAddress`

4. **Restart Autofill Service:**
   - Disable and re-enable the autofill service
   - Restart the device if needed

### Wrong Data Appearing

1. **Check Most Recent Member:**
   - Autofill uses the most recently updated family member
   - Update the member you want to use for autofill

2. **Verify Data in App:**
   - Check that the family member has the correct data
   - Ensure fields are not empty

### Database Access Issues

1. **Check Database Path:**
   - Database should be at: `/data/data/com.example.myfamily/files/myfamily.db`
   - Verify file exists and is readable

2. **Check Permissions:**
   - Autofill service needs read access to app's data directory
   - This is automatic for same-package services

## 📊 Test Results Checklist

- [ ] Autofill service can be enabled in Android settings
- [ ] Service appears in autofill service list
- [ ] Service status shows as "Active"
- [ ] Autofill suggestions appear in WhatsApp
- [ ] Autofill suggestions appear in web forms
- [ ] Name fields populate correctly
- [ ] Email fields populate correctly
- [ ] Phone fields populate correctly
- [ ] Address fields populate correctly
- [ ] Multiple fields fill simultaneously
- [ ] Document paths are accessible
- [ ] Data updates when family member is updated

## 🔒 Security & Privacy

- **Data Access:** Only the autofill service (same package) can access the database
- **User Control:** User must explicitly enable autofill service
- **No External Access:** Other apps cannot directly access the database
- **Permissions:** Autofill service only has access to its own app's data

## 📝 Notes

- Autofill uses the **most recently updated** family member
- If no family members exist, autofill will not provide suggestions
- Document access is via file paths stored in the database
- The service reads directly from SQLite database for performance

## 🎯 Next Steps

1. Test autofill in various apps (WhatsApp, Chrome, Forms)
2. Verify data accuracy
3. Test with multiple family members
4. Test document access functionality
5. Verify security and privacy controls

