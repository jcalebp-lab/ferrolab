"""Configuración por variables de entorno (nunca valores secretos en el código)."""

from __future__ import annotations

from functools import lru_cache
from pathlib import Path
from typing import Annotated, Literal

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, NoDecode, SettingsConfigDict

REPO_ROOT = Path(__file__).resolve().parents[4]


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    ferrolab_env: Literal["development", "test", "production"] = "development"
    # Sin DATABASE_URL la API sirve el snapshot del archivo seed (modo degradado, sin admin).
    database_url: SecretStr | None = None
    snapshot_file: Path = REPO_ROOT / "database" / "seeds" / "catalog_seed.json"
    allowed_origins: Annotated[list[str], NoDecode] = Field(default_factory=lambda: ["http://localhost:8080", "http://127.0.0.1:8080"])

    # Autenticación de administración (Supabase Auth): JWKS (claves asimétricas) o
    # secreto HS256 heredado. Ambos solo en el servidor.
    supabase_url: str | None = None
    supabase_anon_key: str | None = None  # clave pública/publishable: se puede enviar al panel
    supabase_jwt_issuer: str | None = None
    supabase_jwt_audience: str = "authenticated"
    supabase_jwt_secret: SecretStr | None = None
    supabase_jwks_url: str | None = None
    admin_dev_login: bool = False  # solo development: habilita tokens de desarrollo
    require_distinct_reviewer: bool = False

    # Límites de abuso (en memoria; un solo proceso).
    rate_limit_per_minute: int = 60
    simulation_rate_limit_per_minute: int = 30
    tutor_rate_limit_per_minute: int = 6
    max_body_bytes: int = 32_768

    # Tutor IA: apagado por defecto (doc 11 §7).
    ai_enabled: bool = False
    ai_provider: Literal["none", "anthropic"] = "none"
    ai_api_key: SecretStr | None = None
    ai_model: str = "claude-opus-5-5"
    ai_daily_request_budget: int = 0
    ai_timeout_s: float = 20.0

    log_level: str = "INFO"
    expose_docs: bool = True

    @field_validator("allowed_origins", mode="before")
    @classmethod
    def _split(cls, v):
        if isinstance(v, str):
            return [o.strip() for o in v.split(",") if o.strip()]
        return v

    @property
    def is_production(self) -> bool:
        return self.ferrolab_env == "production"

    @property
    def dev_login_allowed(self) -> bool:
        return self.admin_dev_login and not self.is_production


@lru_cache
def get_settings() -> Settings:
    return Settings()
