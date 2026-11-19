-- FERROLAB 0002 — fija search_path de las funciones de disparadores (aviso de seguridad de Supabase 0011).
alter function public.fl_touch_updated_at() set search_path = '';
alter function public.fl_release_immutable() set search_path = '';
alter function public.fl_audit_append_only() set search_path = '';
