create extension if not exists "pgcrypto";

create table if not exists public.app_config (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

insert into public.app_config (key, value)
values
  ('appLatestVersion', '1.0.0'),
  ('mandatoryAppVersion', '1.0.0'),
  ('activeAppIcon', 'default')
on conflict (key) do nothing;

create table if not exists public.users (
  id uuid primary key references auth.users (id) on delete cascade,
  name text not null default '',
  email text not null default '',
  "photoUrl" text,
  "createdAt" timestamptz not null default now()
);

create table if not exists public.chats (
  id text primary key,
  participants uuid[] not null,
  "lastMessage" text not null default '',
  "lastMessageAt" timestamptz not null default now()
);

create index if not exists chats_participants_gin_idx
  on public.chats using gin (participants);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  "chatId" text not null references public.chats (id) on delete cascade,
  "senderId" uuid not null references auth.users (id) on delete cascade,
  text text not null,
  "createdAt" timestamptz not null default now()
);

create index if not exists messages_chat_created_idx
  on public.messages ("chatId", "createdAt" desc);

create table if not exists public.feedback (
  id uuid primary key default gen_random_uuid(),
  "userId" text not null default '',
  name text not null default '',
  email text not null default '',
  "phoneNumber" text not null default '',
  rating double precision not null,
  category text not null,
  message text not null,
  "createdAt" timestamptz not null default now()
);

alter table public.app_config enable row level security;
alter table public.users enable row level security;
alter table public.chats enable row level security;
alter table public.messages enable row level security;
alter table public.feedback enable row level security;

drop policy if exists "app_config_read_all" on public.app_config;
create policy "app_config_read_all"
on public.app_config for select
to anon, authenticated
using (true);

drop policy if exists "users_read_authenticated" on public.users;
create policy "users_read_authenticated"
on public.users for select
to authenticated
using (true);

drop policy if exists "users_upsert_own" on public.users;
create policy "users_upsert_own"
on public.users for insert
to authenticated
with check (id = auth.uid());

drop policy if exists "users_update_own" on public.users;
create policy "users_update_own"
on public.users for update
to authenticated
using (id = auth.uid())
with check (id = auth.uid());

drop policy if exists "users_delete_own" on public.users;
create policy "users_delete_own"
on public.users for delete
to authenticated
using (id = auth.uid());

drop policy if exists "chats_read_participant" on public.chats;
create policy "chats_read_participant"
on public.chats for select
to authenticated
using (auth.uid() = any(participants));

drop policy if exists "chats_upsert_participant" on public.chats;
create policy "chats_upsert_participant"
on public.chats for insert
to authenticated
with check (auth.uid() = any(participants));

drop policy if exists "chats_update_participant" on public.chats;
create policy "chats_update_participant"
on public.chats for update
to authenticated
using (auth.uid() = any(participants))
with check (auth.uid() = any(participants));

drop policy if exists "messages_read_participant" on public.messages;
create policy "messages_read_participant"
on public.messages for select
to authenticated
using (
  exists (
    select 1 from public.chats
    where chats.id = messages."chatId"
      and auth.uid() = any(chats.participants)
  )
);

drop policy if exists "messages_insert_sender" on public.messages;
create policy "messages_insert_sender"
on public.messages for insert
to authenticated
with check (
  "senderId" = auth.uid()
  and exists (
    select 1 from public.chats
    where chats.id = messages."chatId"
      and auth.uid() = any(chats.participants)
  )
);

drop policy if exists "feedback_insert_authenticated" on public.feedback;
create policy "feedback_insert_authenticated"
on public.feedback for insert
to authenticated
with check ("userId" = auth.uid()::text or "userId" = '');

create or replace function public.delete_current_user()
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
begin
  delete from auth.users where id = auth.uid();
end;
$$;

revoke all on function public.delete_current_user() from public;
grant execute on function public.delete_current_user() to authenticated;

do $$
begin
  alter publication supabase_realtime add table public.app_config;
exception when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.users;
exception when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.chats;
exception when duplicate_object then null;
end $$;

do $$
begin
  alter publication supabase_realtime add table public.messages;
exception when duplicate_object then null;
end $$;
