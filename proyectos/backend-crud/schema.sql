-- Backend-CRUD / proyecto knlspzqaodqexqnqyojr
-- Conserva public.usuarios (tabla que ya existía y estaba vacía).
-- Las contraseñas se gestionan en Supabase Auth; nunca se almacenan en usuarios.

create table if not exists public.usuarios (
  id uuid primary key default gen_random_uuid(),
  identificacion text unique,
  tipo_identificacion text,
  nombres_1_y_2 text,
  apellidos_1_y_2 text,
  correo_electronico text unique,
  telefono text,
  direccion text,
  username text unique,
  foto text
);

create table if not exists public.app_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('admin')),
  created_at timestamptz not null default now()
);
alter table public.app_roles enable row level security;
drop policy if exists "Users can read their own app role" on public.app_roles;
create policy "Users can read their own app role" on public.app_roles
  for select to authenticated using ((select auth.uid()) = user_id);

alter table public.usuarios
  add column if not exists created_by uuid references auth.users(id),
  add column if not exists created_at timestamptz not null default now(),
  add column if not exists updated_at timestamptz not null default now();

-- La columna antigua no se usaba (la tabla tenía 0 registros) y no debe guardar claves.
alter table public.usuarios drop column if exists password;

alter table public.usuarios
  alter column identificacion set not null,
  alter column tipo_identificacion set not null,
  alter column nombres_1_y_2 set not null,
  alter column apellidos_1_y_2 set not null,
  alter column correo_electronico set not null,
  alter column username set not null;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'usuarios_tipo_identificacion_check'
      and conrelid = 'public.usuarios'::regclass
  ) then
    alter table public.usuarios add constraint usuarios_tipo_identificacion_check
      check (tipo_identificacion in ('CC','TI','CE','PA','PPT','OTRO'));
  end if;
end;
$$;

create unique index if not exists usuarios_correo_lower_unique_idx
  on public.usuarios (lower(correo_electronico));
create index if not exists usuarios_nombre_idx
  on public.usuarios (lower(apellidos_1_y_2), lower(nombres_1_y_2));
create index if not exists usuarios_created_by_idx on public.usuarios (created_by);

alter table public.usuarios enable row level security;
drop policy if exists "Admins manage usuarios" on public.usuarios;
create policy "Admins manage usuarios" on public.usuarios
  for all to authenticated
  using (exists (
    select 1 from public.app_roles
    where user_id = (select auth.uid()) and role = 'admin'
  ))
  with check (exists (
    select 1 from public.app_roles
    where user_id = (select auth.uid()) and role = 'admin'
  ));

create or replace function public.set_usuarios_updated_at()
returns trigger language plpgsql set search_path = '' as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
revoke all on function public.set_usuarios_updated_at() from public, anon, authenticated;
drop trigger if exists usuarios_set_updated_at on public.usuarios;
create trigger usuarios_set_updated_at before update on public.usuarios
  for each row execute function public.set_usuarios_updated_at();

-- Data API access is explicit; RLS still limits all rows to admins.
grant usage on schema public to authenticated;
grant select, insert, update, delete on public.usuarios to authenticated;
grant select on public.app_roles to authenticated;
create index if not exists usuarios_created_by_idx on public.usuarios (created_by);
do $$ begin
  if to_regprocedure('public.rls_auto_enable()') is not null then
    execute 'revoke all on function public.rls_auto_enable() from public, anon, authenticated';
  end if;
end $$;

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('profile-photos', 'profile-photos', false, 5242880, array['image/jpeg','image/png','image/webp'])
on conflict (id) do update
  set public = false, file_size_limit = 5242880,
      allowed_mime_types = array['image/jpeg','image/png','image/webp'];

drop policy if exists "Directory admins manage profile photos" on storage.objects;
create policy "Directory admins manage profile photos" on storage.objects
  for all to authenticated
  using (bucket_id = 'profile-photos' and exists (
    select 1 from public.app_roles
    where user_id = (select auth.uid()) and role = 'admin'
  ))
  with check (bucket_id = 'profile-photos' and exists (
    select 1 from public.app_roles
    where user_id = (select auth.uid()) and role = 'admin'
  ));

-- 1. Crea tu cuenta desde la app y confirma el correo.
-- 2. En SQL Editor, cambia el correo y promueve tu cuenta:
-- insert into public.app_roles (user_id, role)
-- select id, 'admin' from auth.users where lower(email) = lower('tu-correo@ejemplo.com')
-- on conflict (user_id) do update set role = excluded.role;
