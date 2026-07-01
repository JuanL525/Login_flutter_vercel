# Control Electoral — Flutter + Supabase

Aplicación móvil para gestión de escrutinio electoral con tres roles: **coordinador provincial**, **coordinador de recinto** y **veedor de mesa**.

## Requisitos

- Flutter SDK 3.6+ (`flutter doctor`)
- Cuenta Supabase con migraciones aplicadas
- Proyecto Vercel desplegado (`vercel/`) para verificación de email y reset de contraseña
- Android: permisos de cámara y ubicación para el flujo del veedor

## Configuración rápida

### 1. Variables de entorno

Copia `.env.example` a `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu-anon-key
VERCEL_BASE_URL=https://loginfluttervercel.vercel.app
```

### 2. Base de datos Supabase

Ejecuta en orden (SQL Editor o CLI):

1. `supabase/migrations/0001_init.sql`
2. `supabase/migrations/0002_rls.sql`
3. `supabase/seed.sql` — recintos y mesas precargados (Pichincha / Quito)
4. `supabase/seed_users.sql` — usuarios de demostración del seed
5. Despliega la Edge Function: `supabase/functions/create-user`

### 3. Vercel (auth por correo)

Despliega la carpeta `vercel/` y configura en Supabase:

- **Authentication → URL Configuration**: redirect URLs con tu `VERCEL_BASE_URL`
- **Authentication → Emails**: plantillas con `token_hash` (ver `vercel/SUPABASE_EMAIL_TEMPLATES.md`)
- **SMTP** configurado (Gmail u otro)

### 4. Ejecutar la app

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # solo si regeneras injectable
flutter run
```

### 5. Generar APK (entregable)

```bash
flutter build apk --release
```

APK: `build/app/outputs/flutter-apk/app-release.apk`

---

## Credenciales de prueba

**Login:** cédula (10 dígitos) + contraseña.

| Rol | Cédula | Nombre | Contraseña | Notas |
|-----|--------|--------|------------|-------|
| Provincial | `1710034065` | Maria Coordinadora Provincial | `Ecuador2026` | Cuenta seed; no pide cambio de clave |
| Coordinador recinto | `1710034073` | Carlos Coordinador Recinto | `Ecuador2026` | Recinto seed: Unidad Educativa Calderón |
| Veedor | `1710034081` | Luis Veedor Mesa | `Ecuador2026` | Mesas 1 y 2 del recinto Calderón |

### Cuentas creadas en la app (demostración)

Contraseña inicial al crearlas: **`Ecuador2026`**. Deben **confirmar el correo** antes del primer login. En el primer ingreso deben **cambiar la contraseña** (si aún no lo hicieron, usar `Ecuador2026`).

| Rol | Cédula | Nombre | Contraseña inicial |
|-----|--------|--------|-------------------|
| Coordinador recinto | `0102030400` | Santiago Bladimir Lucero Galindo | `Ecuador2026` |
| Coordinador recinto | `1750093971` | Juan Andrés | `Ecuador2026` |
| Veedor | `1754262911` | Brandito Vinicio | `Ecuador2026` |

> Si una cuenta creada desde la app ya cambió su contraseña, usa la clave personalizada que el usuario definió.

Emails de las cuentas seed:

- `provincial@control-electoral.com`
- `recinto@control-electoral.com`
- `veedor@control-electoral.com`

---

## Modelo de datos (Supabase)

```
auth.users
    └── profiles (cedula, role, recinto_id, must_change_password, ...)
            │
recintos (provincia, canton, parroquia, nombre, coordinador_id)
    └── mesas (numero_jrv, veedor_id)
            └── actas (dignidad: alcalde|prefecto, votos jsonb, foto_path, gps_lat/lng, ...)
```

**Relaciones clave**

- Un **recinto** tiene un solo **coordinador de recinto** (`recintos.coordinador_id`).
- Un **coordinador** pertenece a un recinto (`profiles.recinto_id`).
- Una **mesa** tiene un veedor opcional; un **veedor** puede tener varias mesas.
- Cada mesa genera hasta **2 actas** (alcalde y prefecto).
- Fotos en Storage bucket privado `actas-photos`; GPS en columnas `gps_lat` / `gps_lng` del acta.

**Datos precargados**

- 5 recintos en Pichincha / Quito (`seed.sql`), 4 mesas por recinto.
- 5 organizaciones políticas por dignidad (alcalde y prefecto) en código: `lib/core/seeds/organizaciones_seed.dart`.

---

## Arquitectura Flutter

```
lib/
├── core/           # validadores, servicios (GPS, blur, sync), tema, DB local (Drift)
├── features/
│   ├── auth/       # login, cambio/recuperación de contraseña
│   ├── dashboard/  # homes por rol + informe de votos provincial
│   ├── recintos/   # CRUD recintos (provincial)
│   ├── mesas/      # mesas y asignación de veedores
│   ├── actas/      # registro/corrección de actas + fotos
│   ├── users/      # creación de usuarios vía Edge Function
│   └── sync/       # sincronización offline (outbox)
└── injection_container.dart
```

- **Estado:** BLoC
- **Capas:** presentation → domain (use cases) → data (repositories, datasources)
- **Offline (extra):** Drift + `SyncService` (cola outbox, last-write-wins al reconectar)

---

## Flujos principales

| Rol | Acciones |
|-----|----------|
| Provincial | Ver recintos, crear recinto + mesas, crear/asignar coordinador, avance, informe de votos, ver actas (solo lectura) |
| Coordinador recinto | Ver mesas, crear veedores, asignar/reasignar veedores, corregir actas |
| Veedor | Ver sus mesas, registrar/corregir actas alcalde+prefecto, foto con validación de nitidez, GPS |

---

## Checklist antes de la presentación (30 min)

Recorre estos pasos **en el mismo celular** que usarás en la defensa:

### Auth
- [ ] Login provincial (`1710034065`) → entra al panel
- [ ] Logout → login veedor seed (`1710034081`) → ve solo sus mesas
- [ ] Cuenta creada sin verificar correo → mensaje claro de email no confirmado
- [ ] Recuperar contraseña → llega correo y abre página Vercel

### Provincial
- [ ] Crear recinto con N mesas → aparecen en listado
- [ ] Recinto **sin** coordinador → opciones de asignar visibles
- [ ] Recinto **con** coordinador → no permite crear otro ni reemplazar
- [ ] Informe de votos carga sin error

### Coordinador recinto
- [ ] Crear veedor → llega correo de verificación
- [ ] Asignar veedor a mesa → estado de mesa actualiza
- [ ] Corregir acta de una mesa

### Veedor
- [ ] Registrar acta alcalde: votos + foto nítida + GPS
- [ ] Foto borrosa → rechazada con mensaje
- [ ] GPS denegado → no deja continuar
- [ ] Modo avión → guarda local; al reconectar → icono de sync en app bar

### Casos límite
- [ ] Coordinador huérfano (recinto eliminado en Supabase) → pantalla “Sin recinto asignado”, no crash
- [ ] Cédula incorrecta / contraseña mala → modal de error visible

---

## Riesgos conocidos (para sustentación)

| Tema | Situación | Qué decir si preguntan |
|------|-----------|------------------------|
| Appwrite vs Supabase | Usamos Supabase | “Cumplo auth, storage, RLS y flujo completo; conozco límites de rate de Supabase.” |
| Storage fotos | RLS de bucket permite lectura a cualquier autenticado | “El acceso fino está en tabla `actas`; mejoraría policies del bucket por mesa.” |
| Sync offline | Last-write-wins | “Explico outbox en Drift y resolución por `updated_at`.” |
| Nitidez | Laplacian + Tenengrad + edge ratio | Tienes tests en `test/core/services/blur_detector_test.dart` |

---

## Estructura del repositorio

| Carpeta | Descripción |
|---------|-------------|
| `lib/` | Código Flutter |
| `supabase/` | Migraciones, seed, Edge Functions |
| `vercel/` | Páginas verify-email / reset-password + API config |
| `android/` | Configuración Android (deep links, permisos) |
| `test/` | Tests unitarios (cédula, blur) |

---

## Licencia / autor

Proyecto académico — Prueba 2 Desarrollo de Aplicaciones Móviles (Control Electoral).
