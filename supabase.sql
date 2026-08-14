-- Run this whole file once in the Supabase SQL Editor.
-- It creates the public.users table that mirrors auth.users and tracks who is online.

create table if not exists public.users (
  id         uuid primary key references auth.users (id) on delete cascade,
  email      text        not null,
  created_at timestamptz not null default now(),
  last_seen  timestamptz not null default now()
);

alter table public.users enable row level security;

-- Any signed-in user can see the list of users.
drop policy if exists "authenticated can read users" on public.users;
create policy "authenticated can read users"
  on public.users for select
  to authenticated
  using (true);

-- A user may only update their own row (used for the last_seen heartbeat).
drop policy if exists "user can update own row" on public.users;
create policy "user can update own row"
  on public.users for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- Copy every new auth.users row into public.users.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, email)
  values (new.id, new.email)
  on conflict (id) do update set email = excluded.email;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill anyone who signed up before this script was run.
insert into public.users (id, email)
select id, email from auth.users
on conflict (id) do nothing;
