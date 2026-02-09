-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- Create users table (extends auth.users)
create table public.profiles (
  id uuid references auth.users not null primary key,
  email text,
  full_name text,
  avatar_url text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Create task_lists table (Group/Shared Lists)
create table public.task_lists (
  id uuid primary key default uuid_generate_v4(),
  owner_id uuid references public.profiles(id) not null,
  name text not null,
  created_at timestamptz default now()
);

-- Create list_members table (Collaborators)
create table public.list_members (
  list_id uuid references public.task_lists(id) on delete cascade,
  user_id uuid references public.profiles(id) on delete cascade,
  role text check (role in ('editor', 'viewer')) default 'viewer',
  primary key (list_id, user_id)
);

-- Create tasks table
create table public.tasks (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references public.profiles(id) not null, -- Creator
  list_id uuid references public.task_lists(id) on delete cascade, -- Optional link to shared list
  title text not null,
  description text,
  due_date timestamptz,
  priority text check (priority in ('Low', 'Medium', 'High')),
  is_completed boolean default false,
  category text,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Enable RLS
alter table public.profiles enable row level security;
alter table public.task_lists enable row level security;
alter table public.list_members enable row level security;
alter table public.tasks enable row level security;

-- Profiles Policies
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- Task Lists Policies
create policy "Users can view lists they own or are members of."
  on task_lists for select
  using ( 
    auth.uid() = owner_id OR 
    exists (select 1 from list_members where list_id = id and user_id = auth.uid())
  );

create policy "Users can create lists."
  on task_lists for insert
  with check ( auth.uid() = owner_id );

create policy "Owners can update their lists."
  on task_lists for update
  using ( auth.uid() = owner_id );

create policy "Owners can delete their lists."
  on task_lists for delete
  using ( auth.uid() = owner_id );

-- List Members Policies
create policy "Members are viewable by list participants."
  on list_members for select
  using (
    exists (select 1 from task_lists where id = list_id and owner_id = auth.uid()) OR
    exists (select 1 from list_members lm where lm.list_id = list_id and lm.user_id = auth.uid())
  );

create policy "Owners can add members."
  on list_members for insert
  with check (
    exists (select 1 from task_lists where id = list_id and owner_id = auth.uid())
  );

-- Tasks Policies (Updated for Collaboration)
create policy "Users can view tasks they own or in shared lists."
  on tasks for select
  using ( 
    auth.uid() = user_id OR
    exists (select 1 from task_lists tl where tl.id = list_id and tl.owner_id = auth.uid()) OR
    exists (select 1 from list_members lm where lm.list_id = list_id and lm.user_id = auth.uid())
  );

create policy "Users can insert tasks."
  on tasks for insert
  with check ( 
    auth.uid() = user_id AND (
      list_id IS NULL OR
      exists (select 1 from task_lists tl where tl.id = list_id and tl.owner_id = auth.uid()) OR
      exists (select 1 from list_members lm where lm.list_id = list_id and lm.user_id = auth.uid() and lm.role = 'editor')
    )
  );

create policy "Users can update tasks."
  on tasks for update
  using ( 
    auth.uid() = user_id OR
    exists (select 1 from task_lists tl where tl.id = list_id and tl.owner_id = auth.uid()) OR
    exists (select 1 from list_members lm where lm.list_id = list_id and lm.user_id = auth.uid() and lm.role = 'editor')
  );

create policy "Users can delete tasks."
  on tasks for delete
  using ( 
    auth.uid() = user_id OR
    exists (select 1 from task_lists tl where tl.id = list_id and tl.owner_id = auth.uid())
  );

-- Function to handle new user signup
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, avatar_url)
  values (new.id, new.email, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  return new;
end;
$$ language plpgsql security definer;

-- Trigger for new user
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
