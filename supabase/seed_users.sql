-- =====================================================================
-- Control Electoral - Usuarios de prueba (uno por rol)
-- Contrasena para todos: Ecuador2026
-- Cedulas validas (provincia 17 = Pichincha) verificadas con el algoritmo.
--   Provincial : 1710034065
--   Recinto    : 1710034073
--   Veedor     : 1710034081
-- =====================================================================

create extension if not exists pgcrypto;

-- ---------- AUTH USERS ----------
insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at,
  raw_app_meta_data, raw_user_meta_data,
  confirmation_token, recovery_token, email_change, email_change_token_new
) values
  ('00000000-0000-0000-0000-000000000000', 'c3333333-0000-0000-0000-000000000001', 'authenticated', 'authenticated',
   'provincial@control-electoral.com', crypt('Ecuador2026', gen_salt('bf')),
   now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'c3333333-0000-0000-0000-000000000002', 'authenticated', 'authenticated',
   'recinto@control-electoral.com', crypt('Ecuador2026', gen_salt('bf')),
   now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', '', '', '', ''),
  ('00000000-0000-0000-0000-000000000000', 'c3333333-0000-0000-0000-000000000003', 'authenticated', 'authenticated',
   'veedor@control-electoral.com', crypt('Ecuador2026', gen_salt('bf')),
   now(), now(), now(), '{"provider":"email","providers":["email"]}', '{}', '', '', '', '')
on conflict (id) do nothing;

-- ---------- AUTH IDENTITIES (necesario para login con email/password) ----------
insert into auth.identities (
  id, user_id, identity_data, provider, provider_id,
  last_sign_in_at, created_at, updated_at
) values
  (gen_random_uuid(), 'c3333333-0000-0000-0000-000000000001',
   '{"sub":"c3333333-0000-0000-0000-000000000001","email":"provincial@control-electoral.com","email_verified":true}',
   'email', 'c3333333-0000-0000-0000-000000000001', now(), now(), now()),
  (gen_random_uuid(), 'c3333333-0000-0000-0000-000000000002',
   '{"sub":"c3333333-0000-0000-0000-000000000002","email":"recinto@control-electoral.com","email_verified":true}',
   'email', 'c3333333-0000-0000-0000-000000000002', now(), now(), now()),
  (gen_random_uuid(), 'c3333333-0000-0000-0000-000000000003',
   '{"sub":"c3333333-0000-0000-0000-000000000003","email":"veedor@control-electoral.com","email_verified":true}',
   'email', 'c3333333-0000-0000-0000-000000000003', now(), now(), now())
on conflict do nothing;

-- ---------- PROFILES ----------
-- must_change_password = false en cuentas semilla para que las credenciales
-- documentadas funcionen siempre. Las cuentas creadas desde la app si forzaran
-- el cambio de contrasena en el primer login.
insert into profiles (id, cedula, nombres, apellidos, telefono, email, role, must_change_password, recinto_id) values
  ('c3333333-0000-0000-0000-000000000001', '1710034065', 'Maria',  'Coordinadora Provincial', '0991111111', 'provincial@control-electoral.com', 'provincial', false, null),
  ('c3333333-0000-0000-0000-000000000002', '1710034073', 'Carlos', 'Coordinador Recinto',     '0992222222', 'recinto@control-electoral.com',    'recinto',    false, 'a1111111-1111-1111-1111-111111110001'),
  ('c3333333-0000-0000-0000-000000000003', '1710034081', 'Luis',   'Veedor Mesa',             '0993333333', 'veedor@control-electoral.com',     'veedor',     false, 'a1111111-1111-1111-1111-111111110001')
on conflict (id) do nothing;

-- ---------- ASIGNACIONES ----------
update recintos set coordinador_id = 'c3333333-0000-0000-0000-000000000002'
  where id = 'a1111111-1111-1111-1111-111111110001';

update mesas set veedor_id = 'c3333333-0000-0000-0000-000000000003'
  where id in (
    'b2222222-0001-0000-0000-000000000001',
    'b2222222-0001-0000-0000-000000000002'
  );
