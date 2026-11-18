"""Repositorio PostgreSQL: CRUD editorial, revisión, auditoría y publicaciones."""

from __future__ import annotations

import json
from typing import Any

from ferrolab_fse import DatasetSnapshot
from ferrolab_fse.enums import ReviewStatus
from pydantic import BaseModel, ValidationError
from sqlalchemy import Engine, text
from sqlalchemy.engine import Connection
from sqlalchemy.exc import IntegrityError

from .entities import ENTITIES, INSERT_ORDER, Entity


class RepoError(Exception):
    def __init__(self, code: str, message: str, status: int, details: dict | None = None) -> None:
        super().__init__(message)
        self.code = code
        self.message = message
        self.status = status
        self.details = details or {}


def _where(ent: Entity, key: str) -> tuple[str, dict[str, Any]]:
    try:
        flt = ent.key_filter(key)
    except KeyError as exc:
        raise RepoError("not_found", f"Clave inválida para {ent.name}", 404) from exc
    clause = " and ".join(f"{k} = :k_{k}" for k in flt)
    return clause, {f"k_{k}": v for k, v in flt.items()}


class PostgresRepository:
    def __init__(self, engine: Engine) -> None:
        self.engine = engine

    # ------------------------------------------------------------ util
    def ping(self) -> bool:
        with self.engine.connect() as c:
            return c.execute(text("select 1")).scalar() == 1

    @staticmethod
    def _audit(conn: Connection, actor: str | None, action: str, entity: str, key: str, before, after) -> None:
        conn.execute(
            text("insert into audit_log(actor_id, action, entity_type, entity_id, before, after) "
                 "values (:a, :ac, :e, :k, cast(:b as jsonb), cast(:af as jsonb))"),
            {"a": actor, "ac": action, "e": entity, "k": key,
             "b": json.dumps(before) if before is not None else None,
             "af": json.dumps(after) if after is not None else None},
        )

    @staticmethod
    def _row_to_dict(row) -> dict[str, Any]:
        m = row._mapping
        return {
            **m["body"],
            "review_status": m["review_status"],
            "_meta": {
                "revision": m["revision"],
                "updated_at": m["updated_at"].isoformat() if m["updated_at"] else None,
                "updated_by": str(m["updated_by"]) if m["updated_by"] else None,
                "reviewed_by": str(m["reviewed_by"]) if m["reviewed_by"] else None,
                "published_at": m["published_at"].isoformat() if m["published_at"] else None,
            },
        }

    def _validate(self, ent: Entity, data: dict[str, Any], status: str) -> BaseModel:
        clean = {k: v for k, v in data.items() if not k.startswith("_")}
        clean["review_status"] = status
        try:
            return ent.model.model_validate(clean)
        except ValidationError as exc:
            raise RepoError("validation_error", "Datos inválidos", 422,
                            {"errors": json.loads(exc.json(include_url=False, include_context=False))}) from exc

    def _write_columns(self, ent: Entity, obj: BaseModel) -> dict[str, Any]:
        cols = ent.columns(obj)
        body = obj.model_dump(mode="json", exclude={"review_status"})
        cols["body"] = json.dumps(body, ensure_ascii=False)
        return cols

    def _sync_compositions(self, conn: Connection, obj: BaseModel) -> None:
        conn.execute(text("delete from material_compositions where material_id = :m"), {"m": obj.id})
        for c in obj.compositions:  # type: ignore[attr-defined]
            conn.execute(
                text("insert into material_compositions(material_id, element, min_wt_pct, max_wt_pct, nominal_wt_pct, "
                     "evidence_id) values (:m, :e, :mi, :ma, :no, :ev)"),
                {"m": obj.id, "e": c.element, "mi": c.min_wt_pct, "ma": c.max_wt_pct, "no": c.nominal_wt_pct,
                 "ev": c.evidence_id},
            )

    # ------------------------------------------------------------ lecturas
    def list(self, ent: Entity, status: str | None = None, limit: int = 200, offset: int = 0) -> list[dict]:
        q = f"select * from {ent.table}"
        params: dict[str, Any] = {"lim": min(limit, 500), "off": max(offset, 0)}
        if status:
            q += " where review_status = :st"
            params["st"] = status
        q += f" order by {', '.join(ent.key_fields)} limit :lim offset :off"
        with self.engine.connect() as c:
            return [self._row_to_dict(r) for r in c.execute(text(q), params)]

    def get(self, ent: Entity, key: str, conn: Connection | None = None) -> dict:
        clause, params = _where(ent, key)
        sql = text(f"select * from {ent.table} where {clause}")
        if conn is not None:
            row = conn.execute(sql, params).first()
        else:
            with self.engine.connect() as c:
                row = c.execute(sql, params).first()
        if row is None:
            raise RepoError("not_found", f"{ent.name} {key} no existe", 404)
        return self._row_to_dict(row)

    # ------------------------------------------------------------ escrituras
    def create(self, ent: Entity, data: dict[str, Any], actor: str | None) -> dict:
        obj = self._validate(ent, data, ReviewStatus.DRAFT.value)  # siempre nace en borrador
        cols = self._write_columns(ent, obj)
        cols["updated_by"] = actor
        names = ", ".join(cols)
        vals = ", ".join(f"cast(:{k} as jsonb)" if k == "body" else f":{k}" for k in cols)
        try:
            with self.engine.begin() as conn:
                conn.execute(text(f"insert into {ent.table} ({names}) values ({vals})"), cols)
                if ent.name == "materials":
                    self._sync_compositions(conn, obj)
                self._audit(conn, actor, "create", ent.name, ent.key_of(obj), None, obj.model_dump(mode="json"))
        except IntegrityError as exc:
            raise RepoError("integrity_error", "Conflicto de integridad (clave duplicada o referencia inexistente)",
                            409, {"db": str(exc.orig).splitlines()[0]}) from exc
        return self.get(ent, ent.key_of(obj))

    def update(self, ent: Entity, key: str, patch: dict[str, Any], revision: int, actor: str | None) -> dict:
        with self.engine.begin() as conn:
            current = self.get(ent, key, conn)
            if current["_meta"]["revision"] != revision:
                raise RepoError("revision_conflict", "El registro cambió desde que lo abriste; recarga.", 409,
                                {"current_revision": current["_meta"]["revision"]})
            merged = {k: v for k, v in current.items() if not k.startswith("_")}
            merged.update({k: v for k, v in patch.items() if k not in ("review_status",)})
            # Cualquier edición vuelve a borrador: hay que revisar de nuevo (doc 06 §11).
            obj = self._validate(ent, merged, ReviewStatus.DRAFT.value)
            if ent.key_of(obj) != key:
                raise RepoError("validation_error", "No se puede cambiar la clave de un registro", 422)
            cols = self._write_columns(ent, obj)
            sets = ", ".join(f"{k} = cast(:{k} as jsonb)" if k == "body" else f"{k} = :{k}" for k in cols)
            clause, params = _where(ent, key)
            try:
                conn.execute(
                    text(f"update {ent.table} set {sets}, review_status = 'draft', revision = revision + 1, "
                         f"updated_by = :actor, reviewed_by = null, reviewed_at = null where {clause}"),
                    {**cols, **params, "actor": actor},
                )
                if ent.name == "materials":
                    self._sync_compositions(conn, obj)
            except IntegrityError as exc:
                raise RepoError("integrity_error", "Conflicto de integridad", 409,
                                {"db": str(exc.orig).splitlines()[0]}) from exc
            self._audit(conn, actor, "update", ent.name, key, current, obj.model_dump(mode="json"))
        return self.get(ent, key)

    def transition(self, ent: Entity, key: str, to: str, revision: int, actor: str | None,
                   require_distinct_reviewer: bool) -> dict:
        allowed = {"reviewed": {"draft"}, "retired": {"draft", "reviewed", "published"}, "draft": {"reviewed", "retired"}}
        if to not in allowed:
            raise RepoError("validation_error", "La publicación se hace creando una release", 422)
        with self.engine.begin() as conn:
            current = self.get(ent, key, conn)
            if current["_meta"]["revision"] != revision:
                raise RepoError("revision_conflict", "El registro cambió; recarga.", 409)
            if current["review_status"] not in allowed[to]:
                raise RepoError("invalid_state", f"No se puede pasar de {current['review_status']} a {to}", 400)
            if to == "reviewed":
                self._check_reviewable(ent, current)
                if require_distinct_reviewer and current["_meta"]["updated_by"] == actor:
                    raise RepoError("forbidden", "Quien revisa debe ser distinto de quien editó", 403)
            clause, params = _where(ent, key)
            extra = ", reviewed_by = :actor, reviewed_at = now()" if to == "reviewed" else ""
            conn.execute(text(f"update {ent.table} set review_status = :to, revision = revision + 1{extra} where {clause}"),
                         {**params, "to": to, "actor": actor})
            self._audit(conn, actor, f"transition:{to}", ent.name, key, {"review_status": current["review_status"]},
                        {"review_status": to})
        return self.get(ent, key)

    @staticmethod
    def _check_reviewable(ent: Entity, current: dict) -> None:
        """Gates mínimos antes de aceptar una revisión (GATE-C1, licencias)."""
        if ent.name == "evidence" and current.get("value") is not None and not current.get("locator"):
            raise RepoError("validation_error", "Una cifra necesita localizador (página/tabla/figura) para revisarse", 422)
        if ent.name == "micrographs" and not current.get("license_verified"):
            raise RepoError("validation_error", "La micrografía necesita licencia verificada para revisarse", 422)

    # ------------------------------------------------------------ publicaciones
    def load_rows(self, conn: Connection, statuses: set[str]) -> dict[str, list[dict]]:
        out: dict[str, list[dict]] = {}
        for name in INSERT_ORDER:
            ent = ENTITIES[name]
            rows = conn.execute(text(f"select * from {ent.table} where review_status = any(:st)"),
                                {"st": list(statuses)})
            out[ent.snapshot_key] = [{k: v for k, v in self._row_to_dict(r).items() if k != "_meta"} for r in rows]
        return out

    def create_release(self, version: str, snapshot: DatasetSnapshot, actor: str | None, notes: str | None,
                       activate: bool, mark_published: bool) -> dict:
        with self.engine.begin() as conn:
            exists = conn.execute(text("select 1 from dataset_releases where semantic_version = :v"), {"v": version}).first()
            if exists:
                raise RepoError("revision_conflict", f"La versión {version} ya existe", 409)
            if activate:
                conn.execute(text("update dataset_releases set is_active = false where is_active"))
            rid = conn.execute(
                text("insert into dataset_releases(semantic_version, checksum, snapshot, contains_unreviewed_content, "
                     "is_active, created_by, notes) values (:v, :c, cast(:s as jsonb), :u, :a, :by, :n) returning id"),
                {"v": version, "c": snapshot.checksum(), "s": snapshot.canonical_json(),
                 "u": snapshot.contains_unreviewed_content, "a": activate, "by": actor, "n": notes},
            ).scalar_one()
            if mark_published:
                for name in INSERT_ORDER:
                    ent = ENTITIES[name]
                    conn.execute(text(f"update {ent.table} set review_status = 'published', published_at = now(), "
                                      f"revision = revision + 1 where review_status = 'reviewed'"))
            self._audit(conn, actor, "release:create", "dataset_releases", version, None,
                        {"checksum": snapshot.checksum(), "active": activate})
        return self.get_release(str(rid))

    def get_release(self, rid: str) -> dict:
        with self.engine.connect() as c:
            row = c.execute(text("select id, semantic_version, checksum, contains_unreviewed_content, is_active, "
                                 "created_by, created_at, notes from dataset_releases where id = cast(:i as uuid)"),
                            {"i": rid}).first()
        if row is None:
            raise RepoError("not_found", "Release inexistente", 404)
        m = dict(row._mapping)
        m["id"] = str(m["id"])
        m["created_by"] = str(m["created_by"]) if m["created_by"] else None
        m["created_at"] = m["created_at"].isoformat()
        return m

    def list_releases(self) -> list[dict]:
        with self.engine.connect() as c:
            ids = [str(r[0]) for r in c.execute(text("select id from dataset_releases order by created_at desc"))]
        return [self.get_release(i) for i in ids]

    def activate_release(self, rid: str, actor: str | None) -> dict:
        with self.engine.begin() as conn:
            row = conn.execute(text("select semantic_version from dataset_releases where id = cast(:i as uuid)"),
                               {"i": rid}).first()
            if row is None:
                raise RepoError("not_found", "Release inexistente", 404)
            conn.execute(text("update dataset_releases set is_active = false where is_active"))
            conn.execute(text("update dataset_releases set is_active = true where id = cast(:i as uuid)"), {"i": rid})
            self._audit(conn, actor, "release:activate", "dataset_releases", row[0], None, {"active": True})
        return self.get_release(rid)

    def active_snapshot(self) -> tuple[DatasetSnapshot, str] | None:
        with self.engine.connect() as c:
            row = c.execute(text("select snapshot, checksum from dataset_releases where is_active")).first()
        if row is None:
            return None
        snap = DatasetSnapshot.model_validate(row[0])
        if snap.checksum() != row[1]:
            raise RepoError("dependency_unavailable", "Checksum de la release activa no coincide", 503)
        return snap, row[1]

    # ------------------------------------------------------------ admin
    def membership(self, user_id: str) -> dict | None:
        with self.engine.connect() as c:
            row = c.execute(text("select user_id, email, role, status from admin_memberships where user_id = cast(:u as uuid)"),
                            {"u": user_id}).first()
        return dict(row._mapping) if row else None

    def upsert_membership(self, user_id: str, email: str | None, role: str) -> None:
        with self.engine.begin() as conn:
            conn.execute(text("insert into admin_memberships(user_id, email, role) values (cast(:u as uuid), :e, :r) "
                              "on conflict (user_id) do update set role = excluded.role, email = excluded.email, "
                              "status = 'active'"), {"u": user_id, "e": email, "r": role})
            self._audit(conn, None, "membership:upsert", "admin_memberships", user_id, None, {"role": role})

    def audit(self, limit: int = 100) -> list[dict]:
        with self.engine.connect() as c:
            rows = c.execute(text("select id, actor_id, action, entity_type, entity_id, ts from audit_log "
                                  "order by id desc limit :l"), {"l": min(limit, 500)})
            return [{**dict(r._mapping), "actor_id": str(r.actor_id) if r.actor_id else None,
                     "ts": r.ts.isoformat()} for r in rows]

    def counts(self) -> dict[str, dict[str, int]]:
        out: dict[str, dict[str, int]] = {}
        with self.engine.connect() as c:
            for name, ent in ENTITIES.items():
                rows = c.execute(text(f"select review_status, count(*) from {ent.table} group by review_status"))
                out[name] = {r[0]: r[1] for r in rows}
        return out
