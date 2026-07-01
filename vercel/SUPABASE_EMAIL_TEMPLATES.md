# Plantillas de email para Supabase Dashboard

Copia y pega en **Authentication → Emails** en Supabase.

> **IMPORTANTE:** Usa `{{ .TokenHash }}` (no `{{ .Token }}`).  
> `{{ .Token }}` es un código de 6 dígitos, NO va en la URL.  
> El dominio correcto es `loginfluttervercel.vercel.app` (sin "vercel" en medio).

---

## Confirm sign up

**Subject:** `Confirma tu cuenta - Login Pro`

**Body:**

```html
<h2>Confirma tu email</h2>
<p>Haz clic en el botón para verificar tu cuenta:</p>
<p>
  <a href="https://loginfluttervercel.vercel.app/verify-email?token_hash={{ .TokenHash }}&type=signup">
    Confirmar email
  </a>
</p>
<p>O ingresa este código en la app: <strong>{{ .Token }}</strong></p>
```

---

## Reset password

**Subject:** `Restablecer contraseña - Login Pro`

**Body:**

```html
<h2>Restablecer contraseña</h2>
<p>Para continuar con la recuperación de tu cuenta, haz clic en el enlace:</p>
<p>
  <a href="https://loginfluttervercel.vercel.app/reset-password?token_hash={{ .TokenHash }}&type=recovery">
    Restablecer contraseña
  </a>
</p>
<p>Si no solicitaste este cambio, ignora este mensaje.</p>
```

---

## Alternativa (más simple)

Si prefieres que Supabase genere el link automáticamente:

```html
<a href="{{ .ConfirmationURL }}">Confirmar email</a>
```

Con esta opción, el link pasa primero por `supabase.co/auth/v1/verify`. Algunos clientes de correo (Gmail, Outlook) pueden **consumir el link antes** y dar `otp_expired`. Por eso se recomienda la plantilla con `token_hash` arriba.
