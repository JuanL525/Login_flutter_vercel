# Guía de sustentación — Control Electoral

Documento de apoyo para la defensa de la **Prueba 2: Desarrollo de Apps**. Resume cómo la aplicación cumple los requisitos del enunciado, con referencias a las líneas de código más relevantes y preguntas de práctica.

---

## 1. Resumen ejecutivo

**Control Electoral** es una app móvil Flutter para el escrutinio electoral con tres roles jerárquicos:


| Rol                        | Responsabilidad principal                               |
| -------------------------- | ------------------------------------------------------- |
| **Coordinador provincial** | Crea recintos, asigna coordinadores, ve avance global   |
| **Coordinador de recinto** | Crea veedores, asigna mesas, supervisa su recinto       |
| **Veedor de mesa**         | Registra actas (alcalde/prefecto) con foto, GPS y votos |


**Stack técnico:** Flutter 3.6+, **Supabase** (Auth, Postgres, Storage, Edge Functions), **Vercel** (páginas de verificación y reset de contraseña), **Drift** (SQLite local), patrón **Clean Architecture** + **BLoC**.

> **Nota para la defensa:** El documento recomienda Appwrite, pero también acepta explícitamente el **mecanismo nativo de Supabase** para recuperación de contraseña (§3.2). La justificación completa de Supabase, BLoC, Clean Architecture y el flujo de correos está en la **§7**.

---

## 2. Mapa de requisitos → implementación


| Requisito (documento)              | Dónde se implementa (archivo)                                                                                                               |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| Login con cédula ecuatoriana       | `lib/core/validators/cedula_validator.dart` + RPC `get_email_by_cedula` + `lib/features/auth/data/datasources/auth_remote_data_source.dart` |
| Tres roles con pantallas distintas | `_RootGate` en `lib/main.dart`                                                                                                              |
| Creación jerárquica de usuarios    | Edge Function `supabase/functions/create-user/index.ts`                                                                                     |
| Recintos y mesas (JRV)             | `lib/features/recintos/data/datasources/recintos_remote_data_source.dart`                                                                   |
| Actas con foto obligatoria         | `lib/core/services/photo_capture_service.dart` + `lib/core/services/blur_detector.dart`                                                     |
| GPS obligatorio                    | `lib/core/services/gps_service.dart`                                                                                                        |
| Validación votos = sufragantes     | `SaveActa.validateVotos` en `lib/features/actas/domain/usecases/save_acta.dart`                                                             |
| Modo offline                       | Drift (`lib/core/db/app_database.dart`) + `lib/features/sync/data/sync_service.dart` (outbox)                                               |
| Seguridad por rol                  | RLS en `supabase/migrations/0002_rls.sql`                                                                                                   |
| Cambio obligatorio de contraseña   | `must_change_password` + `AuthBloc._resolve` en `lib/features/auth/presentation/bloc/auth_bloc.dart`                                        |
| Verificación de correo             | Supabase Auth + Gmail SMTP + `vercel/public/verify-email.html`                                                                              |
| Recuperación de contraseña         | `sendPasswordResetEmail()` en `auth_remote_data_source.dart` + `vercel/public/reset-password.html`                                          |
| Separación de capas (§5.2)         | Clean Architecture: `domain/` → `data/` → `presentation/` en cada feature                                                                   |
| Gestor de estado (§5.2)            | BLoC (`*_bloc.dart`, `*_state.dart`) con estados `Loading` / `Error` / `Success` explícitos                                                 |


---

## 3. Arquitectura de la app

```
lib/
├── core/           # Validadores, GPS, blur, tema, Drift, widgets compartidos
├── features/       # auth, actas, dashboard, recintos, sync, users
│   └── <feature>/
│       ├── domain/       # Entidades, repositorios (interfaces), use cases
│       ├── data/         # Models, datasources, repository impl
│       └── presentation/ # BLoC + páginas
├── injection_container.dart   # GetIt + Injectable
└── main.dart                    # Bootstrap y enrutamiento por rol
```

**Flujo típico (veedor guarda acta):**


| Paso         | Archivo                                                           |
| ------------ | ----------------------------------------------------------------- |
| UI           | `lib/features/actas/presentation/pages/acta_detail_page.dart`     |
| BLoC         | `lib/features/actas/presentation/bloc/actas_bloc.dart`            |
| Use case     | `lib/features/actas/domain/usecases/save_acta.dart`               |
| Repositorio  | `lib/features/actas/data/repositories/actas_repository_impl.dart` |
| Sync offline | `lib/features/sync/data/sync_service.dart`                        |
| BD local     | `lib/core/db/app_database.dart` (Drift)                           |


```
UI (ActaDetailPage)
  → ActasBloc → SaveActa (validación dominio)
  → ActasRepositoryImpl → SyncService.enqueueActa
  → Drift (local) + outbox → processOutbox → Supabase (online)
```

---

## 4. Aspectos clave con código

> Antes de cada fragmento verás **Archivo:** con la ruta completa desde la raíz del proyecto, el rango de líneas y el método o elemento al que corresponde.

### 4.1 Arranque y enrutamiento por rol

Al iniciar la app se cargan variables de entorno, se configura la inyección de dependencias y se consulta la sesión. Según el rol del perfil, se muestra la pantalla correspondiente.

**Archivo:** `lib/main.dart` · líneas 22–27 · función `main()`

```22:27:lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await configureDependencies();
  runApp(const MyApp());
}
```

**Archivo:** `lib/main.dart` · líneas 104–120 · widget `_RootGate` (enrutamiento por rol)

```104:120:lib/main.dart
        if (state is AuthMustChangePassword) {
          return const ChangePasswordPage(mandatory: true);
        }
        if (state is AuthAuthenticated) {
          final profile = state.session.profile;
          switch (profile.role) {
            case UserRole.provincial:
              return const ProvincialHomePage();
            case UserRole.recinto:
              final rid = profile.recintoId;
              if (rid == null || rid.isEmpty) {
                return _SinRecintoPage(profile: profile);
              }
              return RecintoHomePage(recintoId: rid);
            case UserRole.veedor:
              return VeedorHomePage(veedorId: profile.id);
          }
        }
```

**Por qué importa:** Un solo punto de entrada (`_RootGate`) centraliza la navegación post-login y evita que un veedor acceda a pantallas provinciales.

---

### 4.2 Autenticación con cédula (no con email visible)

El usuario ingresa **cédula + contraseña**. Internamente se resuelve el email vía RPC segura y luego se usa Supabase Auth.

**Archivo:** `lib/features/auth/data/datasources/auth_remote_data_source.dart` · líneas 37–60 · método `signInWithCedula()`

```37:60:lib/features/auth/data/datasources/auth_remote_data_source.dart
    try {
      // 1. Resolver el email a partir de la cedula (RPC SECURITY DEFINER).
      final email = await supabaseClient.rpc(
        'get_email_by_cedula',
        params: {'p_cedula': cedula},
      ) as String?;

      if (email == null || email.isEmpty) {
        throw Exception(
          'No existe una cuenta registrada con esa cédula. '
          'Verifica el número o contacta a tu coordinador.',
        );
      }

      // 2. Iniciar sesion con email + password.
      try {
        final response = await supabaseClient.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (response.user == null) {
          throw Exception('Contraseña incorrecta');
        }
        return _fetchProfile(response.user!.id);
```

**Cambio obligatorio de contraseña** tras crear cuenta:

**Archivo:** `lib/features/auth/presentation/bloc/auth_bloc.dart` · líneas 36–41 · método `_resolve()`

```36:41:lib/features/auth/presentation/bloc/auth_bloc.dart
  AuthState _resolve(SessionEntity session) {
    if (session.profile.mustChangePassword) {
      return AuthMustChangePassword(session);
    }
    return AuthAuthenticated(session);
  }
```

**Mapeo de errores** (correo sin confirmar vs contraseña incorrecta):

**Archivo:** `lib/features/auth/data/datasources/auth_remote_data_source.dart` · líneas 130–141 · método `_mapAuthError()`

```130:141:lib/features/auth/data/datasources/auth_remote_data_source.dart
    if (_isEmailNotConfirmed(lower, codeLower)) {
      return 'Debes confirmar tu correo electrónico antes de ingresar. '
          'Revisa tu bandeja de entrada (y spam) y haz clic en el enlace '
          'de verificación.';
    }

    if (passwordAttempt ||
        lower.contains('invalid login') ||
        lower.contains('invalid credentials')) {
      return 'Contraseña incorrecta. Si es tu primer ingreso, '
          'recuerda que la clave inicial es Ecuador2026.';
    }
```

---

### 4.3 Validación de cédula ecuatoriana (módulo 10)

Implementada en **Dart puro** (capa domain/core), reutilizada en formularios y replicada en la Edge Function del servidor.

**Archivo:** `lib/core/validators/cedula_validator.dart` · líneas 16–39 · método `isValid()`

```16:39:lib/core/validators/cedula_validator.dart
  static bool isValid(String cedula) {
    if (cedula.length != 10) return false;
    if (int.tryParse(cedula) == null) return false;

    final provincia = int.parse(cedula.substring(0, 2));
    if (provincia < 1 || provincia > 24) return false;

    var sumaImpares = 0;
    for (var i = 0; i < 9; i += 2) {
      var producto = int.parse(cedula[i]) * 2;
      if (producto > 9) producto -= 9;
      sumaImpares += producto;
    }

    var sumaPares = 0;
    for (var i = 1; i < 9; i += 2) {
      sumaPares += int.parse(cedula[i]);
    }

    final total = sumaImpares + sumaPares;
    final decenaSuperior = ((total + 9) ~/ 10) * 10;
    final verificador = (decenaSuperior - total) % 10;

    return verificador == int.parse(cedula[9]);
  }
```

---

### 4.4 Creación jerárquica de usuarios (Edge Function)

#### ¿Qué es una Edge Function?

Una **Edge Function** es código **serverless** que corre en los servidores de Supabase (runtime **Deno/TypeScript**), no dentro de la app Flutter. Es un mini-backend invocable por HTTP: la app le envía datos y la función responde con JSON.


| Concepto                 | En Control Electoral                                               |
| ------------------------ | ------------------------------------------------------------------ |
| **Dónde vive**           | `supabase/functions/create-user/index.ts`                          |
| **Cómo se despliega**    | Supabase CLI o Dashboard (`supabase functions deploy create-user`) |
| **Cómo la llama la app** | `supabaseClient.functions.invoke('create-user', ...)`              |
| **Cuándo se ejecuta**    | Al crear un coordinador (provincial) o un veedor (recinto)         |


**Flujo en nuestra app:**

```
CreateUserPage (Flutter)
  → UsersBloc → CreateUser use case
  → UsersRemoteDataSource.functions.invoke('create-user')
  → Edge Function create-user (servidor Supabase)
  → auth.admin.createUser + profiles + correo confirmación
```

**Archivo:** `lib/features/users/data/datasources/users_remote_data_source.dart` · líneas 47–58 · invocación desde Flutter

```47:58:lib/features/users/data/datasources/users_remote_data_source.dart
      await supabaseClient.functions.invoke(
        'create-user',
        body: {
          'cedula': cedula,
          'nombres': nombres,
          'apellidos': apellidos,
          'telefono': telefono,
          'email': email,
          'role': role.dbValue,
          if (recintoId != null) 'recinto_id': recintoId,
        },
      );
```

#### ¿Por qué la necesitamos? (no basta con Flutter + RLS)

El documento exige que **solo el provincial cree coordinadores** y **solo el recinto cree veedores** (§3.1). Crear usuarios en Supabase Auth requiere la clave `**service_role`**, que tiene permisos de administrador. Esa clave **nunca puede ir en la app móvil** (cualquiera la extraería del APK).

La Edge Function resuelve eso:

1. **Seguridad:** la `service_role` solo existe en el servidor (variables de entorno de Supabase).
2. **Identidad del que llama:** lee el JWT del coordinador logueado y comprueba su rol en `profiles`.
3. **Reglas de negocio en servidor:** jerarquía, cédula válida, correo/cédula únicos, un solo coordinador por recinto.
4. **Operación atómica:** crea en `auth.users`, inserta `profiles`, asigna recinto y dispara el correo de confirmación; si algo falla, hace rollback.

**Archivo:** `supabase/functions/create-user/index.ts` · líneas 60–77 · validación del caller + cliente admin

```60:77:supabase/functions/create-user/index.ts
  // Cliente con el JWT del que llama (para conocer su identidad/rol).
  const authHeader = req.headers.get("Authorization") ?? "";
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });
  // ...
  // Cliente admin (service role) para crear usuarios y escribir profiles.
  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
```

**Archivo:** `supabase/functions/create-user/index.ts` · líneas 108–130 · reglas de jerarquía por rol

```108:130:supabase/functions/create-user/index.ts
  if (callerProfile.role === "provincial") {
    if (role !== "recinto") {
      return json(
        { error: "El coordinador provincial solo crea coordinadores de recinto" },
        403,
      );
    }
    // ...
  } else if (callerProfile.role === "recinto") {
    if (role !== "veedor") {
      return json(
        { error: "El coordinador de recinto solo crea veedores" },
        403,
      );
    }
    recinto_id = callerProfile.recinto_id;
  } else {
    return json({ error: "Rol sin permiso para crear usuarios" }, 403);
  }
```

**Frase para la defensa:** *“Usamos una Edge Function porque crear cuentas Auth exige service role; la app solo invoca la función con su JWT y el servidor valida quién puede crear a quién.”*

---

Solo el **provincial** crea coordinadores; solo el **recinto** crea veedores. Contraseña inicial fija `Ecuador2026` y `must_change_password = true`.

**Archivo:** `supabase/functions/create-user/index.ts` · líneas 1–6 · comentario de cabecera de la Edge Function

```1:6:supabase/functions/create-user/index.ts
// Edge Function: create-user
// Crea cuentas de usuario respetando la jerarquia:
//   - provincial -> crea coordinadores de recinto
//   - recinto    -> crea veedores de su recinto
// Contrasena inicial fija: Ecuador2026 (must_change_password = true)
```

La función valida cédula en servidor (`isValidCedula`) antes de crear el usuario en `auth.users` y su fila en `profiles`.

---

### 4.5 Recintos y mesas (JRV)

Al crear un recinto, se insertan automáticamente las mesas numeradas del 1 al N.

**Archivo:** `lib/features/recintos/data/datasources/recintos_remote_data_source.dart` · líneas 39–46 · método `createRecinto()`

```39:46:lib/features/recintos/data/datasources/recintos_remote_data_source.dart
    // Insertar las mesas (JRV) numeradas del 1 al cantidadMesas.
    if (cantidadMesas > 0) {
      final mesas = List.generate(
        cantidadMesas,
        (i) => {'recinto_id': created.id, 'numero_jrv': i + 1},
      );
      await supabaseClient.from('mesas').insert(mesas);
    }
```

---

### 4.6 Asignación de coordinador a recinto

Operación atómica en dos tablas: `recintos.coordinador_id` y `profiles.recinto_id`, con validaciones de unicidad.

**Archivo:** `lib/features/users/data/datasources/users_remote_data_source.dart` · líneas 103–117 · método `assignCoordinadorToRecinto()`

```103:117:lib/features/users/data/datasources/users_remote_data_source.dart
    if (recintoRow['coordinador_id'] != null) {
      throw Exception('Este recinto ya tiene un coordinador asignado');
    }

    final coordRow = await supabaseClient
        .from('profiles')
        .select('recinto_id, role')
        .eq('id', coordinadorId)
        .single();
    if (coordRow['role'] != UserRole.recinto.dbValue) {
      throw Exception('El usuario seleccionado no es coordinador de recinto');
    }
    if (coordRow['recinto_id'] != null) {
      throw Exception('Este coordinador ya esta asignado a otro recinto');
    }
```

---

### 4.7 Registro de acta: validación de votos, foto y GPS

**Dominio** — reglas de negocio antes de persistir:

**Archivo:** `lib/features/actas/domain/usecases/save_acta.dart` · líneas 24–48 · método estático `validateVotos()`

```24:48:lib/features/actas/domain/usecases/save_acta.dart
  static String? validateVotos(ActaEntity acta) {
    if (acta.totalSufragantes <= 0) {
      return 'Ingrese el total de sufragantes';
    }
    // ... votos no negativos, no superan sufragantes ...
    if (acta.votosContabilizados != acta.totalSufragantes) {
      return 'La suma de votos (${acta.votosContabilizados}) debe ser igual al '
          'total de sufragantes (${acta.totalSufragantes})';
    }
    if (acta.fotoLocalPath == null && acta.fotoPath == null) {
      return 'Debe adjuntar la foto del acta';
    }
    if (acta.gpsLat == null || acta.gpsLng == null) {
      return 'No se registraron las coordenadas GPS';
    }
    return null;
  }
```

**Foto con detección de borrosidad** — el documento exige validar nitidez antes de aceptar la imagen del acta (§4.3 veedor, §5.3 sensores). La app usa la clase `BlurDetector`.

#### Idea general (sin matemáticas pesadas)

Una foto **nítida** del acta tiene **mucho contraste**: líneas de la tabla, números, texto, bordes del papel. Una foto **borrosa** (movimiento de mano, enfoque malo) hace que esos cambios sean **suaves**; los píxeles vecinos se parecen más.

El algoritmo no “ve” texto; mide **cuánto cambia el brillo** entre píxeles vecinos. Si hay pocos cambios bruscos → probablemente borrosa.

#### ¿Qué es el Laplaciano?

El **operador Laplaciano** es un filtro clásico de visión por computadora. En cada píxel compara su brillo con el de arriba, abajo, izquierda y derecha:

```
Laplaciano = (arriba + abajo + izquierda + derecha) − 4 × centro
```

- En una **zona plana** (fondo uniforme), los vecinos se parecen al centro → Laplaciano ≈ **0**.
- En un **borde nítido** (negro junto a blanco), hay salto fuerte → Laplaciano **grande** (positivo o negativo).

En código (kernel discreto 4-vecinos):

**Archivo:** `lib/core/services/blur_detector.dart` · líneas 120–127 · cálculo del Laplaciano por píxel

```120:127:lib/core/services/blur_detector.dart
      final c = lum[y * w + x];
      final up = lum[(y - 1) * w + x];
      final down = lum[(y + 1) * w + x];
      final left = lum[y * w + (x - 1)];
      final right = lum[y * w + (x + 1)];
      final laplace = (up + down + left + right) - 4 * c;
```

#### ¿Qué es la “varianza del Laplaciano”?

Se calcula el Laplaciano en **toda** la imagen y luego la **varianza** de esos valores (qué tan dispersos están respecto a la media):

**Archivo:** `lib/core/services/blur_detector.dart` · líneas 143–144 · varianza = E[L²] − E[L]²

```143:144:lib/core/services/blur_detector.dart
  final mean = sum / count;
  final variance = (sumSq / count) - (mean * mean);
```

| Tipo de foto | Varianza del Laplaciano |
|--------------|-------------------------|
| **Nítida** (muchos bordes) | **Alta** — muchos píxeles con Laplaciano grande y distinto |
| **Borrosa** (transiciones suaves) | **Baja** — casi todo cerca de cero |

Umbral en la app: `minLaplacianVariance = 180.0` (línea 45 de `blur_detector.dart`).

#### ¿Por qué no basta solo con el Laplaciano?

A veces una foto tiene **una zona muy contrastada** (ej. sombra fuerte en un rincón) pero el resto borroso. Por eso se combinan **tres métricas**; la foto debe pasar **las tres**:

| Métrica | Qué mide | Umbral mínimo |
|---------|----------|---------------|
| **Varianza Laplaciana** | Bordes definidos en general | ≥ 180 |
| **Tenengrad (Sobel)** | Energía del gradiente (otra forma de medir cambios de brillo) | ≥ 18 |
| **Ratio de bordes fuertes** | % de píxeles con \|Laplaciano\| ≥ 35 (evita aprobar por un solo borde) | ≥ 4 % |

**Archivo:** `lib/core/services/blur_detector.dart` · líneas 95–97 · decisión final `isSharp`

```95:97:lib/core/services/blur_detector.dart
    final isSharp = lapStats.variance >= minLaplacianVariance &&
        tenengradMean >= minTenengradMean &&
        lapStats.edgeRatio >= minEdgeRatio;
```

#### Preprocesado antes de medir

1. Redimensionar a **800 px** de ancho (más rápido, comparable entre fotos).
2. Convertir a **escala de grises** (solo brillo).
3. **Gaussian blur** leve (radio 1) para ignorar ruido JPEG de la cámara, no el desenfoque real.

**Archivo:** `lib/core/services/blur_detector.dart` · líneas 67–72

```67:72:lib/core/services/blur_detector.dart
    final resized = decoded.width > _analysisWidth
        ? img.copyResize(decoded, width: _analysisWidth)
        : decoded;
    final gray = img.grayscale(resized);
    // Reduce artefactos de compresion JPEG antes de medir enfoque.
    final denoised = img.gaussianBlur(gray, radius: 1);
```

#### ¿Cuándo se ejecuta en la app?

1. **Al tomar la foto** — `PhotoCaptureService.capture()` rechaza de inmediato si no pasa (`BlurryPhotoException`).
2. **Al guardar el acta** — `ActaFormPage` vuelve a comprobar por si la foto cambió.

**Archivo:** `lib/core/services/photo_capture_service.dart` · líneas 56–60 · método `capture()`

```56:60:lib/core/services/photo_capture_service.dart
    final bytes = await xfile.readAsBytes();
    final blur = _blurDetector.analyze(bytes);
    if (!blur.isSharp) {
      throw BlurryPhotoException(blur);
    }
```

**Frase para la defensa:** *“Usamos la varianza del Laplaciano porque mide cuántos bordes nítidos hay en la imagen; una acta borrosa tiene transiciones suaves y puntúa bajo. Combinamos Sobel y ratio de bordes para no dejar pasar fotos borrosas con un solo punto enfocado.”*

**GPS obligatorio** — sin permiso no continúa:

**Archivo:** `lib/core/services/gps_service.dart` · líneas 29–37 · método `getCurrentPosition()`

```29:37:lib/core/services/gps_service.dart
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw LocationPermissionException(
        'Permiso de ubicacion denegado. No es posible continuar.',
      );
    }
```

---

### 4.8 Modo offline y sincronización (Outbox)

Patrón **Outbox**: guardar localmente + encolar; al recuperar red, subir en FIFO.

**Archivo:** `lib/features/sync/data/sync_service.dart` · líneas 9–19 · documentación de la clase `SyncService`

```9:19:lib/features/sync/data/sync_service.dart
/// Servicio de sincronizacion offline (patron Outbox).
///
/// Flujo:
///  - El veedor registra/corrige actas estando offline: se guardan en Drift
///    (actas_local) y se encola una operacion en la tabla `outbox`.
///  - Cuando vuelve la conectividad, [processOutbox] sube las operaciones
///    pendientes en orden FIFO.
///
/// Resolucion de conflictos: *last-write-wins por updated_at*.
```

**Resolución de conflictos** (gana el servidor si `updated_at` remoto es más reciente):

**Archivo:** `lib/features/sync/data/sync_service.dart` · líneas 87–101 · método `processOutbox()`

```87:101:lib/features/sync/data/sync_service.dart
          // --- Resolucion de conflictos (last-write-wins) ---
          final remotas = await remote.getActasByMesa(local.mesaId);
          ActaModel? remota;
          for (final r in remotas) {
            if (r.dignidad == local.dignidad) {
              remota = r;
              break;
            }
          }
          if (remota != null && remota.updatedAt.isAfter(local.updatedAt)) {
            // El servidor tiene una version mas nueva: gana el servidor.
            await db.upsertActaLocal(remota.toCompanion());
            await db.removeOutbox(item.id);
            continue;
          }
```

**Persistencia offline-first** en el repositorio:

**Archivo:** `lib/features/actas/data/repositories/actas_repository_impl.dart` · líneas 49–54 · método `saveActa()`

```49:54:lib/features/actas/data/repositories/actas_repository_impl.dart
  Future<Either<Failure, ActaEntity>> saveActa(ActaEntity acta) async {
    try {
      final model = ActaModel.fromEntity(acta);
      // Guarda local + encola sincronizacion (y la intenta si hay red).
      await syncService.enqueueActa(model);
      return Right(model);
```

---

### 4.9 Seguridad: Row Level Security (RLS)

El veedor solo puede leer/escribir actas de **sus mesas asignadas**:

**Archivo:** `supabase/migrations/0002_rls.sql` · líneas 146–154 · política `actas_insert_veedor`

```146:154:supabase/migrations/0002_rls.sql
create policy actas_insert_veedor on actas
  for insert with check (
    current_user_role() = 'veedor'
    and exists (
      select 1 from mesas m
      where m.id = actas.mesa_id
        and m.veedor_id = auth.uid()
    )
  );
```

Las fotos van al bucket privado `actas-photos`; el acceso fino se controla vía políticas de Storage + RLS en `actas`.

---

## 5. Modelo de datos (resumen)

```
auth.users
    └── profiles (cedula, role, recinto_id, must_change_password)
recintos (provincia, canton, parroquia, nombre, coordinador_id)
    └── mesas (numero_jrv, veedor_id)
            └── actas (dignidad, votos jsonb, foto_path, gps_lat/lng, updated_at)
```

- Cada mesa puede tener **2 actas**: alcalde y prefecto.
- Organizaciones políticas precargadas en `lib/core/seeds/organizaciones_seed.dart`.

---

## 6. Credenciales de demostración


| Rol                 | Cédula       | Contraseña    |
| ------------------- | ------------ | ------------- |
| Provincial          | `1710034065` | `Ecuador2026` |
| Coordinador recinto | `1710034073` | `Ecuador2026` |
| Veedor              | `1710034081` | `Ecuador2026` |


APK release: `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`

---

## 7. Decisiones técnicas para la sustentación

Esta sección responde directamente a lo que la rúbrica pide en **§7.2 Sustentación — Justifica las decisiones técnicas (10 pts)** y a los requisitos de **§5.1 Backend**, **§5.2 Arquitectura del cliente** y **§3.1 / §3.2 Gestión de usuarios**.

---

### 7.1 ¿Por qué Supabase en lugar de Appwrite?

**Qué dice el documento:** §5.1 recomienda Appwrite “para hacer el flujo completo en la defensa”, mencionando límites de transacciones en Supabase. También exige reglas de acceso por rol, Storage para fotos, GPS en el registro del acta y (como extra) sincronización offline.

**Qué respondemos en la sustentación:**


| Criterio del enunciado                             | Cómo lo cubre Supabase en este proyecto                                                        |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Auth + confirmación de correo + reset (§3.1, §3.2) | Supabase Auth nativo + SMTP (Gmail) + páginas Vercel                                           |
| Reglas de acceso por rol (§5.1)                    | **Row Level Security (RLS)** en PostgreSQL por `role`, `recinto_id`, `veedor_id`               |
| Storage de fotos de actas (§5.1)                   | Bucket privado `actas-photos`                                                                  |
| Modelo relacional (recintos → mesas → actas)       | PostgreSQL encaja naturalmente con JOINs y agregaciones (informe de votos, avance por recinto) |
| Creación jerárquica de usuarios (§3.1)             | Edge Function `create-user` con **service role** y validación server-side                      |
| Offline (extra §7.3)                               | Implementado en **Flutter** (Drift + outbox), independiente del BaaS                           |


**Argumentos de defensa (memorizar en tus palabras):**

1. **El enunciado no prohíbe Supabase.** En §3.2 dice literalmente usar el mecanismo nativo de **“Supabase o Appwrite”** para el enlace de restablecimiento. Elegimos Supabase Auth, que cumple el mismo contrato funcional.
2. **RLS en PostgreSQL** modela mejor la jerarquía electoral (provincial → recinto → mesa → acta) que permisos genéricos de documentos. Las políticas SQL son auditables y se prueban en migraciones (`0002_rls.sql`).
3. **Consultas analíticas del provincial** (votos consolidados, mesas con/sin acta, GPS por acta) son más simples en SQL relacional que en una BD orientada a documentos.
4. **Sobre el límite de transacciones:** para una demo académica con pocos usuarios de prueba, el plan gratuito de Supabase es suficiente. La carga real del día electoral la absorbe la **persistencia local offline** del veedor; la sync es por lotes al reconectar, no transacción por transacción en tiempo real.
5. **Appwrite vs Supabase no cambia la arquitectura Flutter.** Presentation → Domain → Data permanece igual; solo cambia el datasource remoto. La decisión es de **backend**, no de diseño de la app móvil.

**Frase corta para cerrar:** *“Usamos Supabase porque el dominio es relacional y jerárquico; RLS nos da seguridad por rol en SQL, Auth cubre confirmación y reset como pide el documento, y el offline lo resolvimos en el cliente con Drift.”*

---

### 7.2 ¿Por qué Clean Architecture?

**Qué dice el documento:** §5.2 exige *“Separación clara entre capas: presentación, lógica de negocio y acceso a datos”* y que el estudiante **explique esa separación** en sustentación (6 pts en funcionalidad + parte de sustentación).

**Cómo está organizado el proyecto:**


| Capa             | Responsabilidad                                  | Ejemplos en el repo (rutas)                                                                                                                                                      |
| ---------------- | ------------------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Presentation** | UI, BLoC, navegación                             | `lib/features/auth/presentation/pages/login_page.dart`, `lib/features/auth/presentation/bloc/auth_bloc.dart`, `lib/features/actas/presentation/pages/acta_detail_page.dart`      |
| **Domain**       | Reglas de negocio puras, sin Flutter ni Supabase | `lib/features/actas/domain/usecases/save_acta.dart`, `lib/core/validators/cedula_validator.dart`, entidades e interfaces en `domain/`                                            |
| **Data**         | Fuentes concretas (Supabase, Drift, Storage)     | `lib/features/auth/data/datasources/auth_remote_data_source.dart`, `lib/features/actas/data/repositories/actas_repository_impl.dart`, `lib/features/sync/data/sync_service.dart` |


**Use case como frontera de negocio** — la UI no valida votos directamente; delega al dominio:

**Archivo:** `lib/features/actas/domain/usecases/save_acta.dart` · líneas 14–20 · método `call()`

```14:20:lib/features/actas/domain/usecases/save_acta.dart
  Future<Either<Failure, ActaEntity>> call(ActaEntity acta) async {
    final error = validateVotos(acta);
    if (error != null) {
      return Left(ValidationFailure(error));
    }
    return repository.saveActa(acta);
  }
```

**Contrato genérico de casos de uso** (patrón reutilizable en todos los features):

**Archivo:** `lib/core/usecase/usecase.dart` · líneas 4–6 · clase abstracta `UseCase`

```4:6:lib/core/usecase/usecase.dart
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
```

**Por qué elegimos Clean Architecture:**

- **Testabilidad:** `SaveActa.validateVotos` y `CedulaValidator` son Dart puro; se pueden probar sin emulador ni red.
- **Independencia del backend:** si mañana migráramos a Appwrite, cambiaríamos `data/` y migraciones, no las reglas de actas ni la UI.
- **Cumplimiento explícito del PDF:** tres carpetas por feature (`domain`, `data`, `presentation`) demuestran la separación que pide §5.2.
- **Errores tipados:** `Either<Failure, T>` (paquete `dartz`) obliga a manejar fallo/éxito en BLoC, evitando pantallas en blanco.

**Flujo para explicar en viva voz:** *“La pantalla dispara un evento al BLoC → el BLoC llama un UseCase → el UseCase aplica reglas y llama al Repository → el Repository decide Drift local o Supabase remoto.”*

---

### 7.3 ¿Por qué BLoC como gestor de estado?

**Qué dice el documento:** §5.2 permite BLoC, Riverpod, Provider u otro, pero exige **justificar la elección** y representar **explícitamente** estados de carga, éxito y error en la UI (sin pantallas en blanco).

**Por qué BLoC y no Provider/Riverpod:**


| Ventaja de BLoC                   | Aplicación en Control Electoral                                         |
| --------------------------------- | ----------------------------------------------------------------------- |
| **Eventos → Estados** explícitos  | `SignInRequested` → `AuthLoading` → `AuthAuthenticated` / `AuthError`   |
| **Estados inmutables y tipados**  | Clases `Equatable` fáciles de comparar en `BlocBuilder`                 |
| **Separación UI / lógica**        | La página solo hace `context.read<AuthBloc>().add(...)`                 |
| **Ecosistema maduro**             | `flutter_bloc` + documentación oficial Flutter                          |
| **Encaja con Clean Architecture** | BLoC vive solo en `presentation/`; llama use cases, no Supabase directo |


**Estados explícitos de auth** (carga, éxito, error, cambio de clave obligatorio):

**Archivo:** `lib/features/auth/presentation/bloc/auth_state.dart` · líneas 10–47 · clases de estado de `AuthBloc`

```10:47:lib/features/auth/presentation/bloc/auth_state.dart
class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final SessionEntity session;
  const AuthAuthenticated(this.session);
  // ...
}

class AuthMustChangePassword extends AuthState {
  final SessionEntity session;
  const AuthMustChangePassword(this.session);
  // ...
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  // ...
}

class ResetPasswordSent extends AuthState {
  const ResetPasswordSent();
}
```

**Estados explícitos al guardar acta** (cumple retroalimentación visual del documento):

**Archivo:** `lib/features/actas/presentation/bloc/actas_bloc.dart` · líneas 39–65 · clases de estado de `ActasBloc`

```39:65:lib/features/actas/presentation/bloc/actas_bloc.dart
class ActasLoading extends ActasState {
  const ActasLoading();
}

class ActasLoaded extends ActasState {
  final String mesaId;
  final ActaEntity? alcalde;
  final ActaEntity? prefecto;
  // ...
}

class ActasError extends ActasState {
  final String message;
  const ActasError(this.message);
  // ...
}

class ActaSaving extends ActasState {
  const ActaSaving();
}

class ActaSaveSuccess extends ActasState {
  const ActaSaveSuccess();
}
```

**Ejemplo de emisión secuencial** (login con feedback):

**Archivo:** `lib/features/auth/presentation/bloc/auth_bloc.dart` · líneas 54–62 · método `_onSignIn()`

```54:62:lib/features/auth/presentation/bloc/auth_bloc.dart
  Future<void> _onSignIn(SignInRequested e, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    final result = await signIn(
      SignInParams(cedula: e.cedula, password: e.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (session) => emit(_resolve(session)),
    );
  }
```

**Frase para la defensa:** *“Elegí BLoC porque cada operación tiene estados discretos que la UI puede pintar: spinner en Loading, diálogo en Error, navegación en Authenticated. Eso es exactamente lo que pide la rúbrica de retroalimentación visual.”*

---

### 7.4 Flujo de correos electrónicos (Gmail SMTP)

**Qué dice el documento:**

- §3.1: al crear veedor o coordinador debe **llegar un correo de confirmación**.
- §3.2: recuperación de contraseña **mediante correo**, con mecanismo nativo de Supabase o Appwrite.

**Componentes del sistema de correo:**

```
┌─────────────┐     create-user / resetPasswordForEmail      ┌──────────────┐
│  App Flutter │ ───────────────────────────────────────────► │ Supabase Auth │
└─────────────┘                                                └──────┬───────┘
                                                                      │
                                      Gmail SMTP (Dashboard Supabase) │
                                                                      ▼
                                                               ┌─────────────┐
                                                               │ Bandeja del │
                                                               │   usuario   │
                                                               └──────┬──────┘
                                                                      │ clic en enlace
                                                                      ▼
                                                               ┌─────────────┐
                                                               │   Vercel    │
                                                               │ verify-email│
                                                               │ reset-pass  │
                                                               └──────┬──────┘
                                                                      │ verifyOtp / updateUser
                                                                      ▼
                                                               ┌──────────────┐
                                                               │ Supabase Auth│
                                                               │ (cuenta OK)  │
                                                               └──────────────┘
```

**Configuración Gmail SMTP (Supabase Dashboard):**

En **Authentication → SMTP Settings** se configuró Gmail como servidor de salida (típicamente `smtp.gmail.com`, puerto **587**, TLS, con **contraseña de aplicación** de Google — no la clave normal de la cuenta). Supabase Auth usa ese SMTP para todos los correos transaccionales: confirmación de registro y recuperación de contraseña.

**Importante:** La app Flutter **no envía correos directamente**. Solo invoca APIs de Supabase; el envío físico lo hace Auth + SMTP.

---

#### A) Confirmación de cuenta al crear usuario (§3.1)

**Paso 1 — App:** coordinador provincial/recinto completa el formulario en `lib/features/users/presentation/pages/create_user_page.dart` → llama Edge Function `create-user`.

**Paso 2 — Servidor:** crea usuario sin confirmar y dispara el correo:

**Archivo:** `supabase/functions/create-user/index.ts` · líneas 170–191 · creación de usuario y `resend()` de confirmación

```170:191:supabase/functions/create-user/index.ts
  const { data: created, error: createErr } = await admin.auth.admin.createUser({
    email,
    password: INITIAL_PASSWORD,
    email_confirm: false,
    user_metadata: { display_name: `${nombres} ${apellidos}` },
  });
  // ...
  const { error: resendErr } = await admin.auth.resend({
    type: "signup",
    email,
    options: {
      emailRedirectTo: "https://loginfluttervercel.vercel.app/verify-email",
    },
  });
```

**Paso 3 — Supabase + Gmail:** envía email con plantilla *Confirm signup*. El enlace incluye `token_hash` y redirige a Vercel (`/verify-email`).

**Paso 4 — Página Vercel:** valida el token con el SDK de Supabase:

**Archivo:** `vercel/public/verify-email.html` · líneas 159–163 · función `verifyEmail()` → `verifyOtp`

```159:163:vercel/public/verify-email.html
                const { data, error } = await supabase.auth.verifyOtp({
                    token_hash: tokenHash,
                    type: 'signup',
                });
```

**Paso 5 — Usuario:** ve “Email verificado” → puede hacer login en la app con cédula + `Ecuador2026` → sistema fuerza cambio de contraseña (`must_change_password` en `lib/features/auth/presentation/pages/change_password_page.dart`).

**Si intenta login sin confirmar:** la app muestra mensaje específico (no “contraseña incorrecta”):

**Archivo:** `lib/features/auth/data/datasources/auth_remote_data_source.dart` · líneas 130–134 · método `_mapAuthError()`

```130:134:lib/features/auth/data/datasources/auth_remote_data_source.dart
    if (_isEmailNotConfirmed(lower, codeLower)) {
      return 'Debes confirmar tu correo electrónico antes de ingresar. '
          'Revisa tu bandeja de entrada (y spam) y haz clic en el enlace '
          'de verificación.';
    }
```

---

#### B) Recuperación de contraseña (§3.2)

**Paso 1 — App:** pantalla “Olvidé mi contraseña” en `lib/features/auth/presentation/pages/reset_password_page.dart` → usuario ingresa **email** registrado.

**Paso 2 — Flutter:** llama mecanismo nativo Supabase con redirect a Vercel:

**Archivo:** `lib/features/auth/data/datasources/auth_remote_data_source.dart` · líneas 78–84 · método `sendPasswordResetEmail()`

```78:84:lib/features/auth/data/datasources/auth_remote_data_source.dart
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await supabaseClient.auth.resetPasswordForEmail(
        email,
        redirectTo:
            '${AppConstants.vercelBaseUrl}${AppConstants.resetPasswordPath}',
      );
```

**Paso 3 — Supabase + Gmail:** envía correo *Reset password* con enlace a `/reset-password?token_hash=...&type=recovery`.

**Paso 4 — Página Vercel:** verifica OTP de recuperación y muestra formulario de nueva clave:

**Archivo:** `vercel/public/reset-password.html` · líneas 525–530 · función `checkSession()` → `verifyOtp`

```525:530:vercel/public/reset-password.html
          if (token && type === "recovery") {
            const { data, error } = await supabase.auth.verifyOtp({
              token_hash: token,
              type: "recovery",
            });
```

**Paso 5 — Usuario:** escribe nueva contraseña → `supabase.auth.updateUser({ password })` → mensaje de éxito → puede iniciar sesión en la app.

**¿Por qué Vercel además de Supabase?** Los enlaces de correo deben abrirse en **navegador** (móvil o PC). Supabase redirige a una URL HTTPS; nuestras páginas estáticas en Vercel completan la verificación con JavaScript y muestran UX clara (loading / éxito / error), cumpliendo la retroalimentación visual del documento.

**Variables necesarias:** `.env` de Flutter (`VERCEL_BASE_URL`, definido en `lib/core/constants/app_constants.dart`) y variables en Vercel (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) expuestas de forma segura vía `/api/config`:

**Archivo:** `vercel/api/config.js` · líneas 14–17 · handler que expone config pública a las páginas HTML

```14:17:vercel/api/config.js
  res.status(200).json({
    supabaseUrl: process.env.SUPABASE_URL,
    supabaseAnonKey: process.env.SUPABASE_ANON_KEY,
  });
```

**Redirect URLs en Supabase:** en **Authentication → URL Configuration** deben estar registradas `https://tu-dominio.vercel.app/verify-email` y `/reset-password`.

---

### 7.5 Edge Functions: resumen para sustentación

**Definición en una frase:** código TypeScript en el **servidor de Supabase** que la app invoca como API privada, con acceso seguro a operaciones admin.

**En este proyecto solo tenemos una:** `create-user` (`supabase/functions/create-user/index.ts`).


| Pregunta del evaluador          | Respuesta corta                                                                   |
| ------------------------------- | --------------------------------------------------------------------------------- |
| ¿Qué es?                        | Función serverless en Supabase (Deno), desplegada en la nube                      |
| ¿Qué hace en nuestra app?       | Crea usuarios Auth + fila en `profiles` + correo de verificación                  |
| ¿Por qué no hacerlo en Flutter? | Requiere `service_role`; exponerla en el APK sería una falla grave de seguridad   |
| ¿Cómo sabe quién llama?         | El JWT del usuario logueado viaja en el header `Authorization`                    |
| ¿Qué valida?                    | Rol del caller, jerarquía, cédula módulo 10, unicidad email/cédula, recinto libre |
| ¿Equivalencia con Appwrite?     | Similar a una **Cloud Function** de Appwrite que crea usuarios con la API admin   |


**Analogía útil:** la app es el mostrador; la Edge Function es la oficina trasera con llave maestra: el cliente pide “crear veedor”, pero solo el servidor puede abrir la caja fuerte (`auth.admin.createUser`).

**Despliegue (recordatorio):** la función debe estar desplegada en el proyecto Supabase; si no, `functions.invoke` falla aunque el resto de la app funcione.

---

### 7.6 Detección de borrosidad: resumen para sustentación

**Pregunta típica del evaluador:** *“¿Qué técnica usaste para medir la nitidez y por qué funciona?”*

**Respuesta en 30 segundos:**

1. Convertimos la foto a grises y medimos **bordes** con el **Laplaciano** (diferencia entre un píxel y sus vecinos).
2. Calculamos la **varianza**: fotos nítidas → muchos bordes fuertes → varianza alta; fotos borrosas → varianza baja.
3. Añadimos **Sobel (Tenengrad)** y **% de píxeles con borde fuerte** para no aprobar fotos borrosas con un solo detalle enfocado.
4. Si falla, mostramos mensaje y pedimos **volver a tomar la foto** (requisito §5.3).

**Analogía:** enfocar el acta es como leer letra impresa vs. letra difuminada; el Laplaciano cuenta cuántos “saltos” de claridad hay en la imagen. Poca variedad de saltos = borrosa.

**Archivo principal:** `lib/core/services/blur_detector.dart`  
**Integración:** `lib/core/services/photo_capture_service.dart` + validación extra en `lib/features/actas/presentation/pages/acta_form_page.dart`

---

## 8. Limitaciones conocidas (útil mencionar en defensa)

1. **Supabase vs Appwrite:** ver justificación completa en §7.1; el documento acepta Supabase Auth para reset de contraseña.
2. **Desasignación offline:** si un veedor pierde la mesa mientras está offline, al sincronizar **RLS rechaza** el push; los datos quedan en local hasta resolverse manualmente.
3. **Last-write-wins:** no hay merge de campos; gana la versión con `updated_at` más reciente.
4. **Storage:** políticas del bucket permiten upload autenticado; el control fino está en la tabla `actas`.

---

## 9. Preguntas de práctica (21)

Responde por escrito o en voz alta antes de la sustentación. Al final del documento (§10) hay una **guía breve de respuestas** para autoevaluarte.

1. ¿Cuáles son los tres roles de la aplicación y qué puede hacer cada uno?
2. ¿Por qué el login pide cédula si Supabase Auth usa email y contraseña?
3. Explica el algoritmo de validación de cédula ecuatoriana (módulo 10) en tus propias palabras.
4. ¿Qué ocurre cuando un usuario creado desde la app intenta ingresar por primera vez?
5. ¿Dónde se decide qué pantalla principal ve cada usuario después del login?
6. ¿Qué validaciones debe cumplir un acta antes de guardarse?
7. ¿Cómo funciona la detección de foto borrosa y por qué es importante?
8. ¿Qué pasa si el veedor no concede permiso de ubicación?
9. Describe el flujo **offline-first** desde que el veedor guarda un acta hasta que llega a Supabase.
10. ¿Qué es el patrón Outbox y qué tablas locales lo implementan?
11. ¿Cómo se resuelve un conflicto si la misma acta fue modificada localmente y en el servidor?
12. ¿Qué es RLS y cómo impide que un veedor modifique actas de otra mesa?
13. ¿Quién puede crear usuarios y qué restricciones tiene la Edge Function `create-user`?
14. ¿Cómo se crean las mesas (JRV) al registrar un nuevo recinto?
15. Si el documento pide Appwrite y el proyecto usa Supabase, ¿cómo justificarías esa elección en la sustentación?
16. ¿Cuáles son las tres capas de Clean Architecture en este proyecto y qué archivo representa cada una?
17. ¿Por qué elegiste BLoC y cómo se ve un estado de carga y un estado de error en la UI?
18. ¿Quién envía físicamente el correo de confirmación: la app Flutter, Vercel o Supabase?
19. Describe paso a paso qué ocurre desde que el provincial crea un veedor hasta que ese veedor puede iniciar sesión.
20. ¿Para qué sirven las páginas `verify-email.html` y `reset-password.html` en Vercel?
21. ¿Qué es una Edge Function y cuál es su trabajo concreto en Control Electoral?

---

## 10. Guía breve de respuestas (autoevaluación)

Mostrar respuestas modelo

1. **Roles:** Provincial (recintos, coordinadores, avance global); Recinto (veedores, mesas, su recinto); Veedor (actas de sus mesas con foto/GPS/votos).
2. **Cédula vs email:** UX ecuatoriana; RPC `get_email_by_cedula` resuelve el email internamente; Auth sigue siendo email+password.
3. **Módulo 10:** 10 dígitos, provincia 01–24, posiciones impares×2 (restar 9 si >9), pares suman directo, dígito verificador = decena superior − total (mod 10).
4. **Primer ingreso:** Debe confirmar correo; contraseña inicial `Ecuador2026`; `must_change_password` fuerza cambio antes del home.
5. `**_RootGate` en `main.dart`:** `BlocBuilder<AuthBloc>` + `switch (profile.role)`.
6. **Validaciones acta:** Sufragantes > 0; votos no negativos; suma = sufragantes; foto; GPS.
7. **Blur / Laplaciano:** El Laplaciano mide cambio de brillo entre píxeles (bordes). La **varianza** resume cuántos bordes nítidos hay: alta = enfocada, baja = borrosa. Umbrales: varianza ≥180, Tenengrad ≥18, bordes fuertes ≥4%. Tres métricas juntas en `BlurDetector`; rechaza en captura y al guardar. Importante para que el acta escaneada sea legible en auditoría.
8. **Sin GPS:** `LocationPermissionException`; la UI no permite guardar el acta.
9. **Offline:** `saveActa` → `enqueueActa` → Drift + outbox → al volver red `processOutbox` → `pushActa` + Storage foto.
10. **Outbox:** Cola FIFO de operaciones pendientes; tablas Drift `actas_local` y `outbox`.
11. **Conflicto:** Last-write-wins por `updated_at`; si remoto es más nuevo, descarta local y elimina de outbox.
12. **RLS:** Políticas Postgres por rol; veedor solo INSERT/UPDATE donde `mesas.veedor_id = auth.uid()`.
13. **create-user:** Provincial → coordinadores; Recinto → veedores de su recinto; valida cédula; service role para crear auth.
14. **Mesas:** `List.generate` en `createRecinto` inserta filas `{ recinto_id, numero_jrv: i+1 }`.
15. **Supabase vs Appwrite:** §3.2 acepta Supabase; RLS en Postgres para roles; modelo relacional; offline en cliente; plan free suficiente para demo académica.
16. **Capas:** Presentation (`AuthBloc`, páginas); Domain (`SaveActa`, entidades); Data (`AuthRemoteDataSource`, repos, Drift).
17. **BLoC:** Eventos/estados explícitos; `AuthLoading` muestra spinner; `AuthError` abre diálogo; `ActaSaving` deshabilita botón guardar.
18. **Correo:** Supabase Auth vía **Gmail SMTP** configurado en el dashboard; Flutter solo invoca `resend` o `resetPasswordForEmail`.
19. **Crear veedor:** Formulario app → `create-user` → `createUser` + `resend signup` → correo Gmail → usuario confirma en Vercel → login cédula → cambio clave obligatorio → home veedor.
20. **Vercel:** Landing HTTPS que recibe el enlace del correo, ejecuta `verifyOtp` o `updateUser` con el SDK JS, y muestra éxito/error al usuario.
21. **Edge Function:** Código serverless en Supabase (Deno); en nuestra app `create-user` crea cuentas Auth con `service_role` de forma segura, valida jerarquía provincial→recinto→veedor, inserta `profiles` y envía correo de confirmación; la app solo hace `functions.invoke` con su JWT.



---

*Generado para sustentación académica del proyecto Control Electoral.*