-- =====================================================================
-- Control Electoral - Row Level Security
-- =====================================================================

alter table profiles enable row level security;
alter table recintos enable row level security;
alter table mesas enable row level security;
alter table actas enable row level security;

-- ---------------------------------------------------------------------
-- profiles
-- ---------------------------------------------------------------------
-- Cada usuario puede leer su propio perfil.
create policy profiles_select_self on profiles
  for select using (id = auth.uid());

-- El provincial lee todos los perfiles.
create policy profiles_select_provincial on profiles
  for select using (current_user_role() = 'provincial');

-- El coordinador de recinto lee los perfiles de su recinto.
create policy profiles_select_recinto on profiles
  for select using (
    current_user_role() = 'recinto'
    and recinto_id = current_user_recinto()
  );

-- El usuario puede actualizar su propio perfil (must_change_password, etc.).
create policy profiles_update_self on profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- ---------------------------------------------------------------------
-- recintos
-- ---------------------------------------------------------------------
-- Lectura: cualquier usuario autenticado puede ver los recintos.
create policy recintos_select_all on recintos
  for select using (auth.uid() is not null);

-- El provincial puede crear/editar/eliminar recintos.
create policy recintos_insert_provincial on recintos
  for insert with check (current_user_role() = 'provincial');

create policy recintos_update_provincial on recintos
  for update using (current_user_role() = 'provincial');

create policy recintos_delete_provincial on recintos
  for delete using (current_user_role() = 'provincial');

-- El coordinador de recinto puede editar SU recinto (por si escribio algo mal).
create policy recintos_update_recinto on recintos
  for update using (
    current_user_role() = 'recinto'
    and id = current_user_recinto()
  );

-- ---------------------------------------------------------------------
-- mesas
-- ---------------------------------------------------------------------
-- Provincial ve todas las mesas.
create policy mesas_select_provincial on mesas
  for select using (current_user_role() = 'provincial');

-- Coordinador de recinto ve las mesas de su recinto.
create policy mesas_select_recinto on mesas
  for select using (
    current_user_role() = 'recinto'
    and recinto_id = current_user_recinto()
  );

-- Veedor solo ve las mesas que tiene asignadas.
create policy mesas_select_veedor on mesas
  for select using (
    current_user_role() = 'veedor'
    and veedor_id = auth.uid()
  );

-- Coordinador de recinto administra mesas de su recinto (crear/asignar/reasignar).
create policy mesas_insert_recinto on mesas
  for insert with check (
    current_user_role() = 'recinto'
    and recinto_id = current_user_recinto()
  );

create policy mesas_update_recinto on mesas
  for update using (
    current_user_role() = 'recinto'
    and recinto_id = current_user_recinto()
  );

-- Provincial tambien puede crear mesas al crear recintos.
create policy mesas_insert_provincial on mesas
  for insert with check (current_user_role() = 'provincial');

create policy mesas_update_provincial on mesas
  for update using (current_user_role() = 'provincial');

-- ---------------------------------------------------------------------
-- actas
-- ---------------------------------------------------------------------
-- Provincial: lectura global (consulta de avance).
create policy actas_select_provincial on actas
  for select using (current_user_role() = 'provincial');

-- Coordinador de recinto: lectura/escritura de actas de mesas de su recinto.
create policy actas_select_recinto on actas
  for select using (
    current_user_role() = 'recinto'
    and exists (
      select 1 from mesas m
      where m.id = actas.mesa_id
        and m.recinto_id = current_user_recinto()
    )
  );

create policy actas_insert_recinto on actas
  for insert with check (
    current_user_role() = 'recinto'
    and exists (
      select 1 from mesas m
      where m.id = actas.mesa_id
        and m.recinto_id = current_user_recinto()
    )
  );

create policy actas_update_recinto on actas
  for update using (
    current_user_role() = 'recinto'
    and exists (
      select 1 from mesas m
      where m.id = actas.mesa_id
        and m.recinto_id = current_user_recinto()
    )
  );

-- Veedor: lectura/escritura solo de actas de SUS mesas.
create policy actas_select_veedor on actas
  for select using (
    current_user_role() = 'veedor'
    and exists (
      select 1 from mesas m
      where m.id = actas.mesa_id
        and m.veedor_id = auth.uid()
    )
  );

create policy actas_insert_veedor on actas
  for insert with check (
    current_user_role() = 'veedor'
    and exists (
      select 1 from mesas m
      where m.id = actas.mesa_id
        and m.veedor_id = auth.uid()
    )
  );

create policy actas_update_veedor on actas
  for update using (
    current_user_role() = 'veedor'
    and exists (
      select 1 from mesas m
      where m.id = actas.mesa_id
        and m.veedor_id = auth.uid()
    )
  );

-- ---------------------------------------------------------------------
-- Storage: bucket privado actas-photos
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('actas-photos', 'actas-photos', false)
on conflict (id) do nothing;

-- Cualquier usuario autenticado puede subir/leer/actualizar fotos de actas.
-- El acceso fino a los registros lo controla la tabla actas (RLS arriba).
create policy actas_photos_select on storage.objects
  for select using (
    bucket_id = 'actas-photos' and auth.uid() is not null
  );

create policy actas_photos_insert on storage.objects
  for insert with check (
    bucket_id = 'actas-photos' and auth.uid() is not null
  );

create policy actas_photos_update on storage.objects
  for update using (
    bucket_id = 'actas-photos' and auth.uid() is not null
  );
