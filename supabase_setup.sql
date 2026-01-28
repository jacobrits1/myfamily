-- Supabase Setup Script for Backup Feature
-- Run this script in your Supabase SQL Editor

-- Create user_backups table
CREATE TABLE IF NOT EXISTS user_backups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_email TEXT NOT NULL,
  backup_timestamp TIMESTAMPTZ NOT NULL,
  backup_version TEXT NOT NULL,
  data_snapshot JSONB NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on user_email for faster queries
CREATE INDEX IF NOT EXISTS idx_user_backups_email ON user_backups(user_email);

-- Create index on backup_timestamp for sorting
CREATE INDEX IF NOT EXISTS idx_user_backups_timestamp ON user_backups(backup_timestamp DESC);

-- Create backup_files table (optional - for tracking file references)
CREATE TABLE IF NOT EXISTS backup_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  backup_id UUID NOT NULL REFERENCES user_backups(id) ON DELETE CASCADE,
  file_type TEXT NOT NULL, -- 'document' or 'profile_image'
  original_path TEXT NOT NULL,
  supabase_storage_path TEXT NOT NULL,
  file_name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Create index on backup_id for faster lookups
CREATE INDEX IF NOT EXISTS idx_backup_files_backup_id ON backup_files(backup_id);

-- Enable Row Level Security (RLS)
ALTER TABLE user_backups ENABLE ROW LEVEL SECURITY;
ALTER TABLE backup_files ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user_backups
-- Users can only see their own backups
CREATE POLICY "Users can view their own backups"
  ON user_backups
  FOR SELECT
  USING (true); -- Allow all reads for now (can be restricted based on auth)

CREATE POLICY "Users can insert their own backups"
  ON user_backups
  FOR INSERT
  WITH CHECK (true); -- Allow all inserts for now

CREATE POLICY "Users can delete their own backups"
  ON user_backups
  FOR DELETE
  USING (true); -- Allow all deletes for now

-- Create RLS policies for backup_files
CREATE POLICY "Users can view their own backup files"
  ON backup_files
  FOR SELECT
  USING (true);

CREATE POLICY "Users can insert their own backup files"
  ON backup_files
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Users can delete their own backup files"
  ON backup_files
  FOR DELETE
  USING (true);

-- Note: In production, you should restrict RLS policies based on authenticated user
-- For example:
-- USING (auth.uid()::text = user_email)
-- This requires Supabase Auth to be set up
