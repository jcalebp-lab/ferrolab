#!/usr/bin/env bash
# Ejecuta todas las pruebas automatizadas. Las de base de datos requieren TEST_DATABASE_URL
# (una base DESECHABLE: se borra su esquema). Las E2E requieren API en :8000 y web en :8080.
set -euo pipefail
cd "$(dirname "$0")/.."
echo "== Python: lint ==";            uv run ruff check .
echo "== Python: pruebas ==";         uv run pytest tests
echo "== Contratos sincronizados ==";  uv run python scripts/build_catalog_seed.py >/dev/null && git diff --exit-code database/seeds packages/contracts
echo "== Flutter: análisis ==";       (cd apps/flutter_client && flutter analyze)
echo "== Flutter: pruebas ==";        (cd apps/flutter_client && flutter test)
if curl -sf http://127.0.0.1:8080 >/dev/null && curl -sf http://127.0.0.1:8000/api/v1/health/live >/dev/null; then
  echo "== E2E navegador ==";         node tests/e2e/student_flow.mjs
else
  echo "== E2E omitidas: arranque antes scripts/dev_start.sh =="
fi
