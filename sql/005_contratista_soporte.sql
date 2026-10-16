-- 005_contratista_soporte.sql
-- Agrega el contratista "Contratista Soporte" al plantel de La Huella.
-- Es un recurso tercerizado (tipo Contratista): Nico lo asigna en Planificación.
-- Idempotente: si ya existe (mismo nombre + sede), no lo duplica.

insert into public.planificacion_personal (nombre, tipo, costo_hora, sede)
select 'Contratista Soporte', 'Contratista', 0, 'la_huella'
where not exists (
  select 1 from public.planificacion_personal
  where nombre = 'Contratista Soporte'
    and sede = 'la_huella'
);
