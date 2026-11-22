-- ============================================================================
-- Planificación — 005 · Despegar feriados duplicados
-- ============================================================================
-- Correr en el proyecto Supabase del portal (wcpkpwxhqdcdljfwzcmy), SQL Editor.
--
-- Síntoma: cada feriado quedó cargado DOS veces (misma fecha y nombre). Hoy no
-- rompe nada si las dos copias coinciden, pero es una trampa: esFeriado() trata
-- el día como feriado NO laborable si CUALQUIER copia tiene se_trabaja=false. O
-- sea, si una copia dice "sí se trabaja" y la otra "no", gana el "no".
--
-- Esta migración:
--   1) Consolida el flag: si ALGUNA copia del grupo (fecha, nombre) tiene
--      se_trabaja=true, deja a todas en true (no perdemos un "sí" al borrar).
--   2) Borra las copias sobrantes, conservando una sola fila por (fecha, nombre)
--      (la de menor id).
-- Idempotente: si no hay duplicados, no hace nada.
-- ============================================================================

-- 0) VISTA PREVIA (opcional) — qué grupos están duplicados. Corré esto solo para mirar.
--    select fecha, nombre, count(*) as copias, bool_or(se_trabaja) as alguna_trabaja
--    from public.planificacion_feriados
--    group by fecha, nombre
--    having count(*) > 1
--    order by fecha;

begin;

-- 1) Consolidar se_trabaja dentro de cada grupo (fecha, nombre):
--    si alguna copia estaba en true, todas quedan en true.
update public.planificacion_feriados f
set se_trabaja = sub.alg
from (
  select fecha, nombre, bool_or(se_trabaja) as alg
  from public.planificacion_feriados
  group by fecha, nombre
) sub
where f.fecha = sub.fecha
  and f.nombre = sub.nombre
  and f.se_trabaja is distinct from sub.alg;

-- 2) Borrar duplicados: conservar la fila de menor id por (fecha, nombre).
delete from public.planificacion_feriados a
where exists (
  select 1
  from public.planificacion_feriados b
  where b.fecha = a.fecha
    and b.nombre = a.nombre
    and b.id < a.id
);

commit;

-- 3) VERIFICACIÓN — no deberían quedar grupos con más de una fila.
--    select fecha, nombre, count(*) as copias
--    from public.planificacion_feriados
--    group by fecha, nombre
--    having count(*) > 1
--    order by fecha;

-- 4) (Opcional, recomendado) Evitar que vuelva a pasar: índice único por fecha+nombre.
--    Si ya corriste los pasos 1-2 y la verificación da 0 filas, podés blindar:
--    create unique index if not exists planificacion_feriados_fecha_nombre_uq
--      on public.planificacion_feriados (fecha, nombre);
