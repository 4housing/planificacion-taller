-- 006_agenda_tareas.sql
-- Agenda de Base Neuquén (tareas con vencimiento asignables al equipo + Leandro Chinni).
-- Correr en el SQL editor de Supabase. No lo ejecuta Claude (sin acceso de escritura a la base).
-- ADITIVO: tabla nueva, no toca nada existente. Primero el SQL, después el deploy del HTML.
-- RLS: mismo patrón que 004_sabados_por_proyecto (sector 'planificacion' para ver,
-- 'puede_editar_sector' para escribir). Nunca políticas para anon.

create table if not exists public.planificacion_agenda_tareas (
  id          uuid primary key default gen_random_uuid(),
  sede        text not null default 'neuquen',
  titulo      text not null,
  detalle     text,
  fecha       date not null,
  hora        text,                 -- 'HH:MM' opcional
  asignado_a  text,                 -- nombre libre (personal de Neuquén o "Leandro Chinni")
  estado      text not null default 'pendiente' check (estado in ('pendiente','hecha')),
  prioridad   text not null default 'media' check (prioridad in ('alta','media','baja')),
  creado_por  text,                 -- email del usuario que la creó
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create index if not exists idx_agenda_tareas_sede_fecha
  on public.planificacion_agenda_tareas (sede, fecha);

alter table public.planificacion_agenda_tareas enable row level security;

-- Visibilidad: cualquier usuario del sector planificación.
drop policy if exists planificacion_agenda_tareas_sector on public.planificacion_agenda_tareas;
create policy planificacion_agenda_tareas_sector on public.planificacion_agenda_tareas
  for all to authenticated
  using (public.tiene_sector('planificacion'))
  with check (public.tiene_sector('planificacion'));

-- Edición (insert/update/delete): solo quienes pueden editar el sector planificación.
drop policy if exists planificacion_agenda_tareas_solo_editores_ins on public.planificacion_agenda_tareas;
create policy planificacion_agenda_tareas_solo_editores_ins on public.planificacion_agenda_tareas
  as restrictive for insert to authenticated
  with check (public.puede_editar_sector('planificacion'));

drop policy if exists planificacion_agenda_tareas_solo_editores_upd on public.planificacion_agenda_tareas;
create policy planificacion_agenda_tareas_solo_editores_upd on public.planificacion_agenda_tareas
  as restrictive for update to authenticated
  using (public.puede_editar_sector('planificacion'))
  with check (public.puede_editar_sector('planificacion'));

drop policy if exists planificacion_agenda_tareas_solo_editores_del on public.planificacion_agenda_tareas;
create policy planificacion_agenda_tareas_solo_editores_del on public.planificacion_agenda_tareas
  as restrictive for delete to authenticated
  using (public.puede_editar_sector('planificacion'));
