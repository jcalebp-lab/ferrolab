# Imagen única de FERROLAB: compila la app web (Flutter) y la sirve junto a la API (FastAPI).
# Render la construye desde el repositorio (render.yaml). No contiene secretos: se pasan como
# variables de entorno en el panel del proveedor.

# buildpack-deps ya incluye curl, git, xz y unzip (sin apt-get).
FROM buildpack-deps:bookworm AS web
ARG FLUTTER_VERSION=3.50.0
# (Solo pruebas detrás de un proxy con CA propia) --secret id=extra_ca,src=ca.crt. En Render no se usa.
RUN --mount=type=secret,id=extra_ca,required=false \
    if [ -f /run/secrets/extra_ca ]; then cp /run/secrets/extra_ca /usr/local/share/ca-certificates/extra.crt \
    && (update-ca-certificates >/dev/null 2>&1 || cat /run/secrets/extra_ca >> /etc/ssl/certs/ca-certificates.crt); fi
RUN curl -fsSL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
       | tar -xJ -C /opt \
    && git config --global --add safe.directory /opt/flutter
ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --no-analytics --enable-web >/dev/null && flutter precache --web
WORKDIR /src/apps/flutter_client
COPY apps/flutter_client/ ./
RUN flutter pub get && flutter build web --release --no-web-resources-cdn --no-wasm-dry-run

FROM python:3.13-slim AS app
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy
COPY --from=ghcr.io/astral-sh/uv:0.11.32 /uv /usr/local/bin/uv
# (Solo pruebas detrás de un proxy con CA propia) --secret id=extra_ca,src=ca.crt. En Render no se usa.
RUN --mount=type=secret,id=extra_ca,required=false \
    if [ -f /run/secrets/extra_ca ]; then cp /run/secrets/extra_ca /usr/local/share/ca-certificates/extra.crt \
    && (update-ca-certificates >/dev/null 2>&1 || cat /run/secrets/extra_ca >> /etc/ssl/certs/ca-certificates.crt); fi
WORKDIR /srv
COPY pyproject.toml uv.lock ./
COPY packages ./packages
COPY services ./services
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
RUN uv sync --frozen --no-dev
COPY database ./database
COPY scripts ./scripts
COPY --from=web /src/apps/flutter_client/build/web ./apps/flutter_client/build/web
RUN useradd --system --uid 10001 ferrolab && chown -R ferrolab /srv
USER ferrolab
ENV FERROLAB_ENV=staging SERVE_WEB_APP=true PORT=8000 PATH="/srv/.venv/bin:${PATH}"
EXPOSE 8000
HEALTHCHECK --interval=30s --timeout=5s CMD python -c "import urllib.request,os;urllib.request.urlopen(f'http://127.0.0.1:{os.environ[\"PORT\"]}/api/v1/health/live')"
# 1) migraciones + catálogo (idempotente)  2) servidor. --proxy-headers: la IP real del
# visitante llega del proxy de Render (necesario para los límites por IP).
CMD ["sh", "-c", "python scripts/db_setup.py && exec uvicorn app.main:app --app-dir services/api --host 0.0.0.0 --port ${PORT} --proxy-headers --forwarded-allow-ips='*'"]
