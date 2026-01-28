# Quick Supabase Setup - Fix the Backup Error

## Current Status
✅ **Backup Feature:** Working perfectly!
❌ **Error:** Table 'user_backups' not found (expected - needs setup)

## Quick Fix (5 minutes)

### Step 1: Open Supabase Dashboard
1. Go to: https://wcldlmpvphqqqcyvewuf.supabase.co
2. Sign in to your Supabase account

### Step 2: Create Tables
1. Click **"SQL Editor"** in the left sidebar
2. Click **"New query"**
3. Copy and paste the entire contents of `supabase_setup.sql`
4. Click **"Run"** (or press Ctrl+Enter)
5. You should see "Success. No rows returned"

### Step 3: Create Storage Buckets
1. Click **"Storage"** in the left sidebar
2. Click **"New bucket"**
3. Create first bucket:
   - **Name:** `backups`
   - **Public:** No (unchecked - keep it private)
   - Click **"Create bucket"**
4. Click **"New bucket"** again
5. Create second bucket:
   - **Name:** `profile-images`
   - **Public:** No (unchecked - keep it private)
   - Click **"Create bucket"**

### Step 4: Test Again
1. Go back to the app on emulator
2. Tap **"Create Backup"** again
3. **Expected:** Should work now! ✅

## What Was Created

### Tables:
- `user_backups` - Stores backup records
- `backup_files` - Tracks file references (optional)

### Storage Buckets:
- `backups` - For document files
- `profile-images` - For profile images

## After Setup

Once Supabase is configured:
- ✅ Backup will work
- ✅ Files will upload to storage
- ✅ Restore will work
- ✅ Multiple users can use it

## Verification

After setup, when you tap "Create Backup":
- Should show progress: "Collecting data..."
- Should show: "Uploading documents..."
- Should show: "Creating backup record..."
- Should show: "Backup completed successfully!"
- Should see backup in the list

## Need Help?

If you encounter issues:
1. Check Supabase dashboard for errors
2. Verify tables exist in "Table Editor"
3. Verify buckets exist in "Storage"
4. Check the error message in the app
