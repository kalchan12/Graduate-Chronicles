-- Create the device_tokens table for multi-device push notification delivery
create table if not exists public.device_tokens (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    fcm_token text not null unique,
    platform text,
    device_name text,
    app_version text,
    last_seen timestamptz default now(),
    created_at timestamptz default now(),
    updated_at timestamptz default now()
);

-- Fast lookup indexes
create index if not exists idx_device_tokens_user_id on public.device_tokens(user_id);

-- Enable RLS
alter table public.device_tokens enable row level security;

-- Setup basic RLS policies for the device_tokens table
create policy "Users can manage their own device tokens"
    on public.device_tokens for all
    using (auth.uid() = user_id)
    with check (auth.uid() = user_id);

-- Forward-migrate existing tokens from the single-device implementation safely
-- Note: 'user_id' selected from profiles will match auth.uid() based on typical schema mappings.
-- If the PK in profiles is 'id', we map profile.id to device_tokens.user_id.
insert into public.device_tokens (user_id, fcm_token)
select id, fcm_token
from public.profiles
where fcm_token is not null
on conflict (fcm_token) do nothing;
