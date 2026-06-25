-- =====================================================================
-- Control Electoral - Esquema inicial
-- =====================================================================

-- ---------------------------------------------------------------------
-- Tipos enumerados
-- ---------------------------------------------------------------------
create type user_role as enum ('provincial', 'recinto', 'veedor');
create type dignidad as enum ('alcalde', 'prefecto');
create type acta_status as enum ('pendiente', 'registrada', 'corregida');

-- ---------------------------------------------------------------------
-- profiles: extiende auth.users con datos de dominio
-- La cedula se usa como nombre de usuario para el login.
-- ---------------------------------------------------------------------
create table profiles (
  id uuid primary key references auth.users on delete cascade,
  cedula text unique not null,
  nombres text not null,
  apellidos text not null,
  telefono text not null,
  email text unique not null,
  role user_role not null,
  must_change_password boolean not null default true,
  recinto_id uuid,            -- FK agregada mas abajo (referencia circular)
  created_by uuid references profiles(id),
  created_at timestamptz not null default now()
);

-- Un email pertenece a un unico rol (Auth ya garantiza email unico).
create unique index profiles_email_role_uniq on profiles (email);

-- ---------------------------------------------------------------------
-- recintos electorales
-- ---------------------------------------------------------------------
create table recintos (
  id uuid primary key default gen_random_uuid(),
  provincia text not null,
  canton text not null,
  parroquia text not null,
  nombre text not null,
  -- Un recinto solo puede tener un coordinador de recinto asociado.
  coordinador_id uuid unique references profiles(id) on delete set null,
  created_at timestamptz not null default now()
);

-- FK circular: profiles.recinto_id -> recintos.id
alter table profiles
  add constraint profiles_recinto_id_fkey
  foreign key (recinto_id) references recintos(id) on delete set null;

-- ---------------------------------------------------------------------
-- mesas (JRV)
-- ---------------------------------------------------------------------
create table mesas (
  id uuid primary key default gen_random_uuid(),
  recinto_id uuid not null references recintos(id) on delete cascade,
  numero_jrv int not null,
  -- Un veedor puede tener varias mesas (sin limite). Una mesa, un veedor.
  veedor_id uuid references profiles(id) on delete set null,
  unique (recinto_id, numero_jrv)
);

-- ---------------------------------------------------------------------
-- actas de escrutinio (una por dignidad por mesa)
-- ---------------------------------------------------------------------
create table actas (
  id uuid primary key default gen_random_uuid(),
  mesa_id uuid not null references mesas(id) on delete cascade,
  dignidad dignidad not null,
  votos jsonb not null default '{}'::jsonb,   -- { "org_id": cantidad }
  votos_blancos int not null default 0,
  votos_nulos int not null default 0,
  total_sufragantes int not null default 0,
  foto_path text,                              -- ruta dentro del bucket actas-photos
  gps_lat double precision,
  gps_lng double precision,
  status acta_status not null default 'registrada',
  registrado_por uuid not null references profiles(id),
  updated_at timestamptz not null default now(),
  unique (mesa_id, dignidad)
);

-- ---------------------------------------------------------------------
-- Indices de apoyo
-- ---------------------------------------------------------------------
create index mesas_recinto_idx on mesas (recinto_id);
create index mesas_veedor_idx on mesas (veedor_id);
create index actas_mesa_idx on actas (mesa_id);
create index profiles_recinto_idx on profiles (recinto_id);

-- ---------------------------------------------------------------------
-- Trigger: mantiene actas.updated_at
-- ---------------------------------------------------------------------
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger actas_set_updated_at
  before update on actas
  for each row execute function set_updated_at();

-- ---------------------------------------------------------------------
-- RPC: login por cedula -> email (SECURITY DEFINER para uso de anonimos)
-- ---------------------------------------------------------------------
create or replace function get_email_by_cedula(p_cedula text)
returns text
language sql
security definer
set search_path = public
as $$
  select email from profiles where cedula = p_cedula;
$$;

revoke all on function get_email_by_cedula(text) from public;
grant execute on function get_email_by_cedula(text) to anon, authenticated;

-- ---------------------------------------------------------------------
-- Helpers para RLS (SECURITY DEFINER para evitar recursion en policies)
-- ---------------------------------------------------------------------
create or replace function current_user_role()
returns user_role
language sql
security definer
set search_path = public
stable
as $$
  select role from profiles where id = auth.uid();
$$;

create or replace function current_user_recinto()
returns uuid
language sql
security definer
set search_path = public
stable
as $$
  select recinto_id from profiles where id = auth.uid();
$$;

grant execute on function current_user_role() to authenticated;
grant execute on function current_user_recinto() to authenticated;
