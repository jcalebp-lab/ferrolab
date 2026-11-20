-- FERROLAB 0005 — Categoría «research» en el conocimiento: fichas de artículos científicos de acceso libre
-- verificados, con su cita (decisión D-39).
alter table knowledge_entries drop constraint if exists knowledge_entries_category_check;
alter table knowledge_entries add constraint knowledge_entries_category_check
  check (category in ('glossary','concept','faq','research'));
