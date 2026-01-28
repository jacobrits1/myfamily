# Backup Feature Testing Guide

## Pre-Testing Setup

### 1. Supabase Setup (Required for Full Functionality)
Before testing backup, you need to set up Supabase:

**Option A: Quick Setup (Recommended)**
1. Go to: https://wcldlmpvphqqqcyvewuf.supabase.co
2. Navigate to **SQL Editor**
3. Copy and paste contents of `supabase_setup.sql`
4. Click **Run**
5. Go to **Storage** → Create buckets:
   - `backups` (private)
   - `profile-images` (private)

**Option B: Test UI Only (Without Supabase)**
- App will run and show backup UI
- Backup will fail with error (expected)
- Good for testing UI flow

### 2. App Build Status
- ✅ Dependencies installed
- ✅ Android emulator online (emulator-5554)
- 🔄 App building...

## Testing Steps

### Step 1: Authentication
1. **First Launch:**
   - App will show PIN setup screen
   - Enter PIN: `1607`
   - Confirm PIN: `1607`
   - Should authenticate and show landing screen

2. **Subsequent Launches:**
   - App will show PIN entry screen
   - Enter PIN: `1607`
   - Should authenticate

### Step 2: Navigate to My Profile
1. From landing screen, tap **"My Profile"** button (or navigate via dashboard)
2. Should see profile screen with:
   - Profile header (name, email)
   - Summary section (documents count, custom fields count)
   - **Backup & Restore section** (NEW) ← This is what we're testing
   - Information section
   - Documents section

### Step 3: Test Backup UI
1. **Locate Backup Button:**
   - Should see "Backup & Restore" section
   - Should see "Back up all your family data..." description
   - Should see blue "Backup" button with backup icon

2. **Click Backup Button:**
   - Should navigate to Backup Screen
   - Should show "Create Backup" section at top
   - Should show "Available Backups" section below

### Step 4: Test Backup Creation

**If Supabase is NOT set up:**
- Click "Create Backup"
- Should show error message (expected)
- Error might be: "Error creating backup: ..." or "Table does not exist"

**If Supabase IS set up:**
- Click "Create Backup"
- Should show progress indicator
- Should show progress messages:
  - "Starting backup..."
  - "Collecting data..."
  - "Uploading documents..."
  - "Uploading profile images..."
  - "Creating backup record..."
- Should show success message: "Backup completed successfully!"
- Should see new backup in the list

### Step 5: Test Backup List
1. **View Backups:**
   - Should see list of backups (if any exist)
   - Each backup shows:
     - Date/time
     - Version number
     - Restore icon button
     - Delete icon button

2. **Empty State:**
   - If no backups, should show:
     - "No backups yet" message
     - Icon
     - "Create your first backup to get started"

### Step 6: Test Restore (If Backup Exists)

**Warning: Restore will replace all current data!**

1. **Click Restore Icon:**
   - Should show confirmation dialog
   - "This will replace all current data with the backup..."
   - Options: "Cancel" or "Restore"

2. **Confirm Restore:**
   - Click "Restore"
   - Should show progress indicator
   - Progress messages:
     - "Starting restore..."
     - "Downloading backup data..."
     - "Downloading documents..."
     - "Downloading profile images..."
     - "Validating backup..."
     - "Clearing existing data..."
     - "Restoring family members..."
     - "Restoring custom fields..."
     - "Restoring documents..."
     - "Restoring calendar events..."
     - "Restoring checklists..."
     - "Restoring checklist items..."
     - "Restore complete!"

3. **After Restore:**
   - Should show success message
   - Should navigate back to previous screen
   - Data should be restored

### Step 7: Test Delete Backup
1. **Click Delete Icon:**
   - Should show confirmation dialog
   - "Are you sure you want to delete this backup?"
   - Options: "Cancel" or "Delete"

2. **Confirm Delete:**
   - Click "Delete"
   - Should remove backup from list
   - Should show success message

## Expected Results

### ✅ Success Indicators:
- Backup button visible in My Profile
- Backup screen loads correctly
- Progress indicators show during operations
- Success/error messages display appropriately
- Backup list updates after operations

### ⚠️ Known Issues (If Supabase Not Set Up):
- Backup creation will fail (expected)
- Error message should be clear and helpful
- App should not crash

### 🐛 Potential Issues to Watch For:
- App crashes on backup screen
- Progress indicators don't show
- Error messages not displayed
- Navigation issues
- UI layout problems

## Test Data Recommendations

Before testing backup:
1. **Add Test Data:**
   - Add at least 1 family member (mark as "This is me")
   - Add email to self member (required for backup)
   - Add 1-2 documents
   - Add 1 calendar event
   - Add 1 checklist with items

2. **Verify Data:**
   - Check all data appears correctly
   - Verify self member has email

## Testing Checklist

- [ ] App builds successfully
- [ ] Authentication works with PIN 1607
- [ ] My Profile screen loads
- [ ] Backup button is visible
- [ ] Backup screen loads
- [ ] Create Backup button works
- [ ] Progress indicators show
- [ ] Error handling works (if Supabase not set up)
- [ ] Backup list displays (if backups exist)
- [ ] Restore works (if backup exists)
- [ ] Delete works (if backup exists)
- [ ] Navigation works correctly
- [ ] No crashes or freezes

## Next Steps After Testing

1. **If Supabase Not Set Up:**
   - Set up Supabase tables and buckets
   - Re-test backup creation
   - Verify files upload correctly
   - Verify restore works completely

2. **If Issues Found:**
   - Document errors
   - Check logs
   - Fix issues
   - Re-test

## Logs to Check

If issues occur, check:
- Flutter console output
- Android logcat: `adb logcat | grep -i flutter`
- Supabase dashboard logs (if set up)
