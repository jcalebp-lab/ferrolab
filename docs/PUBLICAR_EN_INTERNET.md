# Publicar FERROLAB en Internet (gratis): Supabase + Render

Resultado: una dirección `https://ferrolab-XXXX.onrender.com` que funciona desde cualquier lugar en el
navegador del celular o de la computadora, y en el APK de Android.

**Limitaciones de los planes gratuitos (verifíquelas en las páginas oficiales antes de empezar; cambian):**
- Render gratis: el servidor se **duerme tras ~15 min sin visitas** y la primera visita tarda ~1 minuto en despertar;
  ancho de banda mensual limitado. Render no recomienda su plan gratuito para producción.
- Supabase gratis: el proyecto se **pausa tras ~1 semana sin actividad** (se reactiva desde su panel);
  sin copias de seguridad.
- La base de datos gratuita de Render **caduca a los 30 días**: por eso se usa la de Supabase.

## Paso 1 — GitHub (código)
1. Cree una cuenta en https://github.com y un repositorio **vacío** (por ejemplo `ferrolab`).
2. Suba el contenido de `FERROLAB_vX.zip`, o conecte GitHub a Claude para que lo suba Claude.

## Paso 2 — Supabase (base de datos y acceso de administradores)
1. Cree una cuenta en https://supabase.com → **New project** (región cercana, p. ej. São Paulo). Guarde la contraseña de la base de datos en un lugar seguro.
2. **Connect** → pestaña de cadena de conexión → **Session pooler** (es compatible con IPv4; la conexión «Direct» no funciona desde Render gratis). Copie la URI y sustituya `[YOUR-PASSWORD]`.
3. *(Panel admin, opcional)* **Authentication → Users → Add user** con su correo y una contraseña. Copie su **User UID**.
4. **Project Settings → API**: copie la **Project URL** y la clave **anon/publishable** (es pública).

## Paso 3 — Render (servidor)
1. Cree una cuenta en https://render.com (puede entrar con GitHub) → **New → Blueprint** → elija su repositorio. Render lee `render.yaml`.
2. Rellene las variables que pide (se guardan cifradas en Render, **nunca en GitHub ni en el chat**):

| Variable | Valor |
|---|---|
| `DATABASE_URL` | URI del *Session pooler* de Supabase |
| `ALLOWED_ORIGINS` | la dirección que Render le asigne, p. ej. `https://ferrolab-xxxx.onrender.com` |
| `SUPABASE_URL` | Project URL |
| `SUPABASE_ANON_KEY` | clave anon/publishable |
| `SUPABASE_JWT_ISSUER` | `<Project URL>/auth/v1` |
| `SUPABASE_JWKS_URL` | `<Project URL>/auth/v1/.well-known/jwks.json` |
| `ADMIN_BOOTSTRAP_USER_ID` | su User UID (para entrar al panel) |

3. **Apply / Deploy**. La primera construcción tarda varios minutos (compila la app web). Al arrancar, el servidor crea las tablas y el catálogo automáticamente.
4. Abra la dirección de Render: debe ver FERROLAB con el aviso «Contenido editorial pendiente de revisión».

## Paso 4 — Celulares
- **Navegador (Android y iPhone):** abra la dirección y use «Agregar a pantalla de inicio».
- **APK Android:** en la app, Ajustes → Servidor de FERROLAB → pegue la dirección `https://…onrender.com` → «Guardar y probar». Con esa dirección se puede generar un APK definitivo que ya la traiga configurada y sin HTTP sin cifrar.

## Modo `staging` (piloto público)
El servidor público arranca con `FERROLAB_ENV=staging`: muestra el catálogo marcado como pendiente de revisión,
**prohíbe los tokens de desarrollo** y exige base de datos. Cuando un especialista revise el contenido y publique
la versión `1.0.0` desde el panel, se podrá cambiar a `FERROLAB_ENV=production`, que solo acepta contenido revisado.
