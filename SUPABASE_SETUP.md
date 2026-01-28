# Supabase Setup Guide for Backup Feature

## Prerequisites

1. Supabase project created at: `https://wcldlmpvphqqqcyvewuf.supabase.co`
2. Access to Supabase Dashboard

## Setup Steps

### 1. Create Database Tables

1. Open your Supabase Dashboard
2. Navigate to **SQL Editor**
3. Copy and paste the contents of `supabase_setup.sql`
4. Click **Run** to execute the script

This will create:
- `user_backups` table - Stores backup metadata and data snapshots
- `backup_files` table - Tracks file references (optional)
- Indexes for better query performance
- Row Level Security (RLS) policies

### 2. Create Storage Buckets

1. Navigate to **Storage** in Supabase Dashboard
2. Create two buckets:

   **Bucket 1: `backups`**
   - Name: `backups`
   - Public: No (private bucket)
   - File size limit: Set according to your needs (e.g., 50MB per file)

   **Bucket 2: `profile-images`**
   - Name: `profile-images`
   - Public: No (private bucket)
   - File size limit: Set according to your needs (e.g., 10MB per file)

### 3. Configure Storage Policies

For each bucket, set up policies to allow authenticated users to:
- Upload files
- Download files
- Delete files

**Example Policy for `backups` bucket:**

```sql
-- Allow authenticated users to upload
CREATE POLICY "Users can upload backups"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'backups');

-- Allow authenticated users to download
CREATE POLICY "Users can download backups"
ON storage.objects FOR SELECT
USING (bucket_id = 'backups');

-- Allow authenticated users to delete
CREATE POLICY "Users can delete backups"
ON storage.objects FOR DELETE
USING (bucket_id = 'backups');
```

**Note:** For now, the app uses email-based identification. If you implement Supabase Auth later, you can restrict policies based on `auth.uid()`.

### 4. Update RLS Policies (Optional - for Production)

If you implement Supabase Auth, update the RLS policies in `supabase_setup.sql` to restrict access based on authenticated user:

```sql
-- Example: Restrict to authenticated users
CREATE POLICY "Users can view their own backups"
  ON user_backups
  FOR SELECT
  USING (auth.uid()::text = user_email);
```

## Current Implementation

The current implementation uses:
- **Email-based identification**: User email from self member profile
- **Public access**: RLS policies allow all operations (for development)
- **Storage buckets**: Private buckets with basic policies

## Security Considerations

1. **For Production:**
   - Implement Supabase Auth for proper user authentication
   - Update RLS policies to restrict access based on `auth.uid()`
   - Add rate limiting for backup operations
   - Implement file size limits
   - Add backup retention policies (auto-delete old backups)

2. **Storage Security:**
   - Keep buckets private
   - Use signed URLs for file access if needed
   - Implement file validation before upload
   - Scan files for malware (if applicable)

3. **Data Privacy:**
   - Encrypt sensitive data before backup
   - Implement backup encryption at rest
   - Add GDPR compliance features (data export, deletion)

## Testing

After setup:
1. Test backup creation from the app
2. Verify files are uploaded to storage buckets
3. Test restore functionality
4. Verify RLS policies work correctly
5. Test with multiple users (different emails)

## Troubleshooting

**Issue: "Permission denied" errors**
- Check RLS policies are enabled
- Verify storage bucket policies
- Check if buckets are created correctly

**Issue: "Bucket not found" errors**
- Verify bucket names match exactly: `backups` and `profile-images`
- Check bucket is created and accessible

**Issue: "Table does not exist" errors**
- Run the SQL setup script again
- Verify tables are created in the correct schema

## Next Steps

1. Test the backup feature on Android emulator
2. Monitor Supabase usage and costs
3. Implement premium service check (future enhancement)
4. Add backup scheduling (future enhancement)
5. Implement backup encryption (future enhancement)
