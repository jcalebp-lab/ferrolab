"""Exporta los contratos compartidos (fuente única de verdad: Python/Pydantic).

* packages/contracts/openapi.json  — OpenAPI generado por FastAPI.
* packages/contracts/enums.json    — vocabulario canónico.
* apps/flutter_client/lib/shared/models/contract_enums.g.dart — enums para Flutter.

Uso: uv run python scripts/gen_contracts.py   (las pruebas fallan si quedan desincronizados)
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "services" / "api"))

from app.core.config import Settings  # noqa: E402
from app.main import create_app  # noqa: E402
from fastapi.testclient import TestClient  # noqa: E402
from ferrolab_fse.enums import ALL_ENUMS  # noqa: E402


def _camel(s: str) -> str:
    head, *rest = s.split("_")
    return head + "".join(w.capitalize() for w in rest)


def dart_enums() -> str:
    lines = ["// GENERADO por scripts/gen_contracts.py — no editar a mano.", "// ignore_for_file: constant_identifier_names", ""]
    for name, enum in ALL_ENUMS.items():
        cls = "".join(w.capitalize() for w in name.split("_"))
        values = list(enum)
        lines.append(f"enum {cls} {{")
        for v in values:
            ident = _camel(v.value)
            if ident in ("default", "none"):
                ident += "Value"
            lines.append(f"  {ident}('{v.value}'),")
        lines[-1] = lines[-1][:-1] + ";"
        lines += ["", f"  const {cls}(this.wire);", "  final String wire;", "",
                  f"  static {cls}? fromWire(String? w) {{",
                  f"    for (final v in {cls}.values) {{", "      if (v.wire == w) return v;", "    }",
                  "    return null;", "  }", "}", ""]
    return "\n".join(lines)


def build() -> dict[str, str]:
    app = create_app(Settings(_env_file=None, ferrolab_env="test"))
    openapi = TestClient(app).get("/openapi.json").json()
    enums = {k: [v.value for v in e] for k, e in ALL_ENUMS.items()}
    return {
        "packages/contracts/openapi.json": json.dumps(openapi, indent=2, ensure_ascii=False, sort_keys=True) + "\n",
        "packages/contracts/enums.json": json.dumps(enums, indent=2) + "\n",
        "apps/flutter_client/lib/shared/models/contract_enums.g.dart": dart_enums(),
    }


if __name__ == "__main__":
    for rel, content in build().items():
        p = ROOT / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_text(content, encoding="utf-8")
        print("escrito", rel)
