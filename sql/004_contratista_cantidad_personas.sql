-- 004_contratista_cantidad_personas.sql
-- Cantidad de personas que manda un contratista a una estación (solo control).
-- Ej.: "Contratista herrero" asignado a Taller de herrería con 3 personas.
-- Vacío (null) = 1. No interviene en costos, horas, cobertura ni traslados a Compras.
-- La tabla ya tiene RLS por sector planificacion: no hace falta tocar políticas.
-- Correr ANTES de publicar el index.html que la usa. Idempotente.

alter table public.planificacion_bloques_personal
  add column if not exists cantidad integer;

alter table public.planificacion_bloques_personal
  drop constraint if exists planificacion_bloques_personal_cantidad_chk;
alter table public.planificacion_bloques_personal
  add constraint planificacion_bloques_personal_cantidad_chk
  check (cantidad is null or cantidad between 1 and 999);

-- Verificación: tiene que devolver una fila con data_type = integer
select column_name, data_type
from information_schema.columns
where table_schema = 'public' and table_name = 'planificacion_bloques_personal' and column_name = 'cantidad';
