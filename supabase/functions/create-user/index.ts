// Edge Function: create-user
// Crea cuentas de usuario respetando la jerarquia:
//   - provincial -> crea coordinadores de recinto
//   - recinto    -> crea veedores de su recinto
// Contrasena inicial fija: Ecuador2026 (must_change_password = true)
//
// deno-lint-ignore-file no-explicit-any
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const INITIAL_PASSWORD = "Ecuador2026";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// Validacion de cedula ecuatoriana (modulo 10).
function isValidCedula(cedula: string): boolean {
  if (!/^\d{10}$/.test(cedula)) return false;
  const prov = parseInt(cedula.substring(0, 2), 10);
  if (prov < 1 || prov > 24) return false;

  let sumaImpares = 0;
  for (let i = 0; i < 9; i += 2) {
    let v = parseInt(cedula[i], 10) * 2;
    if (v > 9) v -= 9;
    sumaImpares += v;
  }
  let sumaPares = 0;
  for (let i = 1; i < 9; i += 2) {
    sumaPares += parseInt(cedula[i], 10);
  }
  const total = sumaImpares + sumaPares;
  const decena = Math.ceil(total / 10) * 10;
  const verificador = (decena - total) % 10;
  return verificador === parseInt(cedula[9], 10);
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return json({ error: "Metodo no permitido" }, 405);
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  // Cliente con el JWT del que llama (para conocer su identidad/rol).
  const authHeader = req.headers.get("Authorization") ?? "";
  const callerClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
  });

  const {
    data: { user: caller },
    error: callerErr,
  } = await callerClient.auth.getUser();
  if (callerErr || !caller) {
    return json({ error: "No autenticado" }, 401);
  }

  // Cliente admin (service role) para crear usuarios y escribir profiles.
  const admin = createClient(supabaseUrl, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });

  const { data: callerProfile, error: profErr } = await admin
    .from("profiles")
    .select("role, recinto_id")
    .eq("id", caller.id)
    .single();
  if (profErr || !callerProfile) {
    return json({ error: "Perfil del solicitante no encontrado" }, 403);
  }

  let body: any;
  try {
    body = await req.json();
  } catch {
    return json({ error: "JSON invalido" }, 400);
  }

  const { cedula, nombres, apellidos, telefono, email, role } = body;
  let recinto_id: string | null = body.recinto_id ?? null;

  // Validacion de campos obligatorios.
  if (!cedula || !nombres || !apellidos || !telefono || !email || !role) {
    return json({ error: "Faltan campos obligatorios" }, 400);
  }

  // Validacion de cedula.
  if (!isValidCedula(cedula)) {
    return json({ error: "La cedula ingresada no es valida" }, 400);
  }

  // Reglas de jerarquia.
  if (callerProfile.role === "provincial") {
    if (role !== "recinto") {
      return json(
        { error: "El coordinador provincial solo crea coordinadores de recinto" },
        403,
      );
    }
    if (!recinto_id) {
      return json({ error: "Debe asignar un recinto al coordinador" }, 400);
    }
  } else if (callerProfile.role === "recinto") {
    if (role !== "veedor") {
      return json(
        { error: "El coordinador de recinto solo crea veedores" },
        403,
      );
    }
    // El veedor pertenece al recinto del coordinador que lo crea.
    recinto_id = callerProfile.recinto_id;
  } else {
    return json({ error: "Rol sin permiso para crear usuarios" }, 403);
  }

  // Unicidad: un correo pertenece a un unico rol/usuario.
  const { data: existingEmail } = await admin
    .from("profiles")
    .select("id")
    .eq("email", email)
    .maybeSingle();
  if (existingEmail) {
    return json({ error: "El correo ya esta registrado" }, 409);
  }

  // Unicidad de cedula.
  const { data: existingCedula } = await admin
    .from("profiles")
    .select("id")
    .eq("cedula", cedula)
    .maybeSingle();
  if (existingCedula) {
    return json({ error: "La cedula ya esta registrada" }, 409);
  }

  // Crear usuario en Auth.
  const { data: created, error: createErr } = await admin.auth.admin.createUser({
    email,
    password: INITIAL_PASSWORD,
    email_confirm: true,
    user_metadata: { display_name: `${nombres} ${apellidos}` },
  });
  if (createErr || !created.user) {
    return json({ error: createErr?.message ?? "No se pudo crear el usuario" }, 400);
  }

  // Insertar profile.
  const { error: insertErr } = await admin.from("profiles").insert({
    id: created.user.id,
    cedula,
    nombres,
    apellidos,
    telefono,
    email,
    role,
    must_change_password: true,
    recinto_id,
    created_by: caller.id,
  });
  if (insertErr) {
    // Rollback del usuario de Auth si falla el profile.
    await admin.auth.admin.deleteUser(created.user.id);
    return json({ error: insertErr.message }, 400);
  }

  // Si es coordinador de recinto, asignarlo como coordinador del recinto.
  if (role === "recinto" && recinto_id) {
    const { error: assignErr } = await admin
      .from("recintos")
      .update({ coordinador_id: created.user.id })
      .eq("id", recinto_id);
    if (assignErr) {
      return json(
        { warning: "Usuario creado pero no se pudo asignar al recinto", id: created.user.id },
        207,
      );
    }
  }

  return json({ id: created.user.id, email, role }, 201);
});
