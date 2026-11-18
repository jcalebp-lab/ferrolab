# Publicar FERROLAB en celulares (Android e iPhone)

**Requisito común a todas las rutas:** la API de FERROLAB tiene que estar en Internet con HTTPS.
Hoy solo funciona en una computadora o en una sesión temporal; una app instalada en el celular no puede
hablar con `localhost`. Sin servidor público, cualquier app instalada mostraría «Sin conexión al motor».

## Ruta A — App web instalable (PWA): gratis, Android e iPhone

1. Publicar la API con `SERVE_WEB_APP=true` en un alojamiento con HTTPS (la API entrega también la app).
2. En el celular abrir la dirección pública:
   - **Android (Chrome):** menú ⋮ → «Instalar app» / «Agregar a pantalla principal».
   - **iPhone (Safari):** botón Compartir → «Agregar a pantalla de inicio».
3. Queda un icono FERROLAB como una app. No pasa por tiendas ni requiere cuentas de desarrollador.

## Ruta B — Android APK (instalación directa): gratis

1. Subir este proyecto a un repositorio de GitHub.
2. Pestaña **Actions → «Apps móviles» → Run workflow**, escribiendo la URL pública de la API.
3. Al terminar, descargar el artefacto `ferrolab-android` (contiene `app-release.apk`).
4. En el Android: abrir el APK y permitir «instalar apps de origen desconocido» para ese navegador/gestor.
   Sin clave propia, el APK va firmado con la clave de depuración: sirve para probar, **no** para Google Play.

## Ruta C — Google Play

- Cuenta de **Google Play Console** (pago único; verifique el precio vigente).
- Clave de firma propia (`upload.jks`), guardada fuera de Git, y sus datos como secretos del repositorio:
  `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
- Subir el `app-release.aab` del flujo, ficha de la tienda, capturas, **política de privacidad** y
  cuestionario de clasificación de contenido. Revise también los requisitos vigentes de pruebas cerradas
  para cuentas personales nuevas.
- Elegir el identificador definitivo antes de la primera subida (`applicationId`, hoy `co.ferrolab.ferrolab`): luego no se puede cambiar.

## Ruta D — iPhone por TestFlight o App Store

- **Apple Developer Program** (cuota anual; verifique el precio vigente). Sin él no se puede instalar una app nativa
  propia en iPhones de otras personas.
- Una Mac con Xcode **o** un servicio de compilación en la nube con Mac (el flujo `mobile.yml` ya compila
  iOS sin firma en una Mac de GitHub para comprobar que funciona).
- Certificado de distribución y perfil de aprovisionamiento; subir a App Store Connect → TestFlight.
- Ficha, privacidad («App Privacy»: FERROLAB no recoge datos personales) y revisión de Apple.

## Estado actual (18-11-2026)

| Paso | Estado |
|---|---|
| Nombre «FERROLAB», icono original, permiso de Internet en Android, firma opcional | Hecho |
| Flujo de compilación en la nube (`.github/workflows/mobile.yml`) | Escrito y validado como YAML; **no ejecutado** (no hay repositorio en GitHub) |
| Compilar APK en este entorno | Bloqueado: la red del entorno no permite descargar el Android SDK (`dl.google.com`) |
| Compilar iOS en este entorno | Imposible: requiere macOS |
| Servidor público de la API | Pendiente: decisión y cuenta del propietario |
