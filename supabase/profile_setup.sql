-- profile_setup.sql
-- Run this in Supabase SQL Editor to create the profile table.

-- 1. Create Profile Table
CREATE TABLE profile (
    profile_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    bio TEXT,
    profile_picture TEXT, -- URL or Path in Storage
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- 2. Enable RLS
ALTER TABLE profile ENABLE ROW LEVEL SECURITY;

-- 3. RLS Policies

-- Public Read (Anyone can view profiles)
CREATE POLICY "Profiles are viewable by everyone" 
    ON profile FOR SELECT 
    USING (true);

-- Insert: Users can create their own profile
-- We need to ensure the `user_id` foreign key points to a user owned by `auth.uid()`.
CREATE POLICY "Users can insert their own profile data" 
    ON profile FOR INSERT 
    WITH CHECK (
        user_id IN (
            SELECT user_id FROM users WHERE auth_user_id = auth.uid()
        )
    );

-- Update: Users can update their own profile
CREATE POLICY "Users can update their own profile data" 
    ON profile FOR UPDATE 
    USING (
        user_id IN (
            SELECT user_id FROM users WHERE auth_user_id = auth.uid()
        )
    );

-- 4. Triggers (Optional but good practice)
-- Auto-update `updated_at`
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_profile_updated_at
    BEFORE UPDATE ON profile
    FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();
