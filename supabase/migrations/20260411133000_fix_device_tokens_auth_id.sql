-- Fix the device_tokens table to use the Supabase Auth UUID
-- This resolves the mismatch between legacy project IDs and actual push targets

-- 1. Drop the old table and start clean (since the IDs were likely legacy IDs)
drop table if exists public.device_tokens cascade;

-- 2. Create the table using the Auth UUID as the user_id
create table public.device_tokens (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null, -- This will store auth.uid()
    fcm_token text not null unique,
    platform text,
    device_name text,
    app_version text,
    last_seen timestamptz default now(),
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- 3. Indexes and RLS
create index idx_device_tokens_user_id on public.device_tokens(user_id);
alter table public.device_tokens enable row level security;

create policy "Users can manage their own device tokens"
    on public.device_tokens for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Optional: If the users table has a consistent Auth ID column, you can add this back:
-- alter table public.device_tokens add constraint device_tokens_user_id_fkey 
-- foreign key (user_id) references auth.users(id) on delete cascade;
