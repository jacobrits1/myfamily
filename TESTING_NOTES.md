# Testing Notes

## Important: Supabase Setup Required

Before testing the backup feature, you need to:

1. **Set up Supabase Tables:**
   - Go to Supabase Dashboard: https://wcldlmpvphqqqcyvewuf.supabase.co
   - Navigate to SQL Editor
   - Run the SQL script from `supabase_setup.sql`

2. **Create Storage Buckets:**
   - Go to Storage in Supabase Dashboard
   - Create bucket: `backups` (private)
   - Create bucket: `profile-images` (private)
   - Configure policies (see SUPABASE_SETUP.md)

## Testing Steps

### 1. Authentication
- PIN: 1607 (as requested)
- The app should authenticate with this PIN

### 2. Navigate to My Profile
- Go to My Profile screen
- Should see "Backup" button in the Backup & Restore section

### 3. Test Backup
- Click "Backup" button
- Should navigate to Backup screen
- Click "Create Backup"
- If Supabase is set up: Should create backup successfully
- If Supabase is NOT set up: Will show error (expected)

### 4. Test Restore
- If backup exists, should see it in the list
- Click restore icon
- Confirm restore
- Should restore data

## Expected Behavior

**Without Supabase Setup:**
- App will compile and run
- Backup button will be visible
- Clicking backup will show error about Supabase connection/table not found
- This is expected and indicates the feature is working (just needs Supabase setup)

**With Supabase Setup:**
- Backup should work completely
- Files should upload to storage
- Restore should work

## Current Test Status

- App is building for Android emulator
- Will test with PIN 1607
- Will navigate to backup feature
- Will document any errors
