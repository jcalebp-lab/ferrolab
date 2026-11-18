#!/usr/bin/env bash
# Arranca FERROLAB en local: API (puerto 8000) + web compilada (puerto 8080).
# Requisitos: uv, Flutter y (opcional) PostgreSQL con .env configurado.
set -euo pipefail
cd "$(dirname "$0")/.."
uv sync --quiet
if [ ! -d apps/flutter_client/build/web ]; then
  (cd apps/flutter_client && flutter build web --release --no-web-resources-cdn \
     --dart-define=API_BASE_URL="${API_BASE_URL:-http://localhost:8000}")
fi
uv run uvicorn app.main:app --app-dir services/api --host 127.0.0.1 --port 8000 &
API_PID=$!
(cd apps/flutter_client/build/web && python3 -m http.server 8080 --bind 127.0.0.1) &
WEB_PID=$!
trap 'kill $API_PID $WEB_PID 2>/dev/null' EXIT
echo ""
echo "FERROLAB listo:  abra http://localhost:8080   (API: http://localhost:8000/docs)"
echo "Pulse Ctrl+C para detener."
wait
