# Cómo ejecutar FERROLAB (guía para principiantes)

Esta guía asume que **no sabes programar**. Cada bloque gris es un comando: cópialo, pégalo en una terminal y pulsa Enter.

> El `README.md` de esta carpeta es el Bluebook original (la especificación). Este archivo explica cómo poner en marcha el software.

## 1. Qué hay en la carpeta

| Carpeta | Qué es |
|---|---|
| `apps/flutter_client/` | La aplicación que ven los estudiantes (y el panel de administración). |
| `services/api/` | El servidor (API) que valida y responde a la aplicación. |
| `packages/fse/` | El motor científico: decide qué se puede concluir y con qué evidencia. |
| `database/` | Estructura de la base de datos, reglas de seguridad y catálogo inicial. |
| `tests/` | Pruebas automáticas. |
| `docs/` | Los 15 documentos del Bluebook + `DECISIONS.md` (decisiones) + `PROGRESO.md` (estado). |

## 2. Instalar las herramientas (una sola vez)

1. **Git**: https://git-scm.com/downloads
2. **uv** (gestiona Python automáticamente): https://docs.astral.sh/uv/getting-started/installation/
3. **Flutter** (versión estable 3.50 o posterior): https://docs.flutter.dev/get-started/install — elige tu sistema y sigue la sección *Web*.
4. **Google Chrome** (para ver la app).
5. *(Opcional, para el panel de administración)* **PostgreSQL 16**: https://www.postgresql.org/download/

Para comprobar que quedaron instaladas:

```bash
uv --version
```

```bash
flutter --version
```

## 3. Modo rápido: solo la app de estudiantes (sin base de datos)

Abre una terminal **dentro de la carpeta FERROLAB** y ejecuta:

```bash
uv sync
```

```bash
uv run uvicorn app.main:app --app-dir services/api --port 8000
```

Deja esa terminal abierta. Abre **otra** terminal en la misma carpeta:

```bash
cd apps/flutter_client
```

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000
```

Se abrirá Chrome con FERROLAB. Sin base de datos la app funciona con el catálogo inicial (marcado «pendiente de revisión») y el panel de administración aparece como no disponible.

Para detener: pulsa `Ctrl + C` en cada terminal.

## 4. Modo completo: con base de datos y panel de administración

1. Crea una base de datos vacía en PostgreSQL llamada `ferrolab_dev` con un usuario y contraseña propios.
2. Copia `.env.example` como `.env` y rellena `DATABASE_URL` con tus datos, por ejemplo `postgresql://usuario:contraseña@localhost:5432/ferrolab_dev`. Para desarrollo pon también `ADMIN_DEV_LOGIN=true` y un `SUPABASE_JWT_SECRET` inventado y largo. **Nunca compartas el archivo `.env`.**
3. Si usas PostgreSQL local (no Supabase), crea una vez los roles que Supabase trae de serie (con un usuario administrador de PostgreSQL):

```bash
psql -d ferrolab_dev -f database/policies/0000_local_roles.sql
```

4. Crea las tablas, el catálogo y tu usuario administrador (el identificador es un ejemplo; puedes usar ese):

```bash
uv run python scripts/db_setup.py --admin-user 00000000-0000-4000-8000-0000000000aa --role admin
```

5. Arranca todo con un solo comando (compila la web la primera vez, tarda ~1 minuto):

```bash
./scripts/dev_start.sh
```

6. Abre http://localhost:8080 en Chrome. Para el panel: **Ajustes → Panel de administración**. Genera tu token de desarrollo en otra terminal y pégalo en el campo «Token de desarrollo»:

```bash
uv run python scripts/dev_admin_token.py --user 00000000-0000-4000-8000-0000000000aa
```

La documentación interactiva de la API está en http://localhost:8000/docs.

## 5. Cómo se publica contenido científico (flujo del panel)

1. **Registros** → elige el tipo (materiales, evidencia, protocolos…) → edita → **Guardar borrador**.
2. Una persona con formación metalúrgica comprueba fuente, localizador, unidades y dominio → **Marcar como revisado**. *No lo marques si no se hizo esa revisión.*
3. **Publicaciones** → escribe una versión (por ejemplo `1.0.0`) → **Comprobar publicación** (muestra qué falta) → **Publicar versión**.
4. Si algo sale mal, en la lista de publicaciones pulsa **Activar** sobre la versión anterior (reversión).

Una cifra (por ejemplo una dureza) solo aparecerá a los estudiantes si: hay evidencia publicada con fuente y localizador, el protocolo está publicado con todas sus etapas documentadas, la pareja material–tratamiento tiene `quantitative_outputs_enabled=true` y la temperatura/tiempo del estudiante caen dentro del dominio de esa evidencia.

## 6. Ejecutar las pruebas

```bash
uv run pytest tests
```

Las pruebas de base de datos se activan con `TEST_DATABASE_URL` apuntando a una base **desechable** (se borra su contenido). Para todo de una vez (Python, Flutter y, si la app está arrancada, navegador):

```bash
./scripts/run_all_tests.sh
```

## 7. Tutor de IA (opcional, apagado)

Funciona sin IA con explicaciones editoriales. Para activarlo necesitas una clave de API propia **con presupuesto**: en `.env` pon `AI_ENABLED=true`, `AI_PROVIDER=anthropic`, `AI_API_KEY=...` y un límite diario `AI_DAILY_REQUEST_BUDGET` (por ejemplo 50). La clave vive solo en el servidor.

## 8. Publicar en Internet (pendiente)

Se necesita: (a) un proyecto Supabase (base de datos y autenticación de administradores), (b) un alojamiento para la API en Python (Supabase no lo ofrece) y (c) un alojamiento estático para la carpeta `apps/flutter_client/build/web`. Revisa precios y límites vigentes antes de elegir; nada de esto está contratado ni configurado todavía.
