-- FERROLAB 0004 — Tratamiento «bonificado» (temple + revenido alto), decisión D-38.
-- La lista cerrada de tratamientos de 0001 se amplía; el reemplazo de ASTM A48 clase 30 por GG25 (EN-GJL-250) no
-- necesita cambios de esquema: db_setup retira (nunca borra) los registros semilla que ya no existen.
alter table treatments drop constraint if exists treatments_id_check;
alter table treatments add constraint treatments_id_check
  check (id in ('quench','temper','anneal','normalize','austemper','martemper','quench_temper'));
