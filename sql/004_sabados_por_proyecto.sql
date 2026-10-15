-- ============================================================================
-- Planificación — 004 · Sábados habilitados por proyecto (La Huella)
-- ============================================================================
-- Correr en el proyecto Supabase del portal (wcpkpwxhqdcdljfwzcmy), SQL Editor.
-- Permite habilitar sábados como días trabajables POR PROYECTO: ninguno, algunos
-- (fechas puntuales) o todos (mientras dure el proyecto). Las horas de esos
-- sábados se computan como EXTRA (con recargo) en el costo/histograma; esto lo
-- maneja la app, acá solo guardamos qué sábados están habilitados.
-- Idempotente.
-- ============================================================================

-- "Todos los sábados mientras dure el proyecto": flag en el proyecto.
alter table public.planificacion_proyectos
  add column if not exists sabados_todos boolean not null default false;

-- Sábados puntuales habilitados (para el modo "algunos").
create table if not exists public.planificacion_proyecto_sabados (
  id          uuid primary key default gen_random_uuid(),
  proyecto_id uuid not null references public.planificacion_proyectos(id) on delete cascade,
  fecha       date not null,
  creado_en   timestamptz not null default now(),
  unique (proyecto_id, fecha)
);
create index if not exists planificacion_proyecto_sabados_proy
  on public.planificacion_proyecto_sabados (proyecto_id);

-- RLS: acceso por sector (igual que el resto de planificación) + lector read-only.
alter table public.planificacion_proyecto_sabados enable row level security;

drop policy if exists planificacion_proyecto_sabados_sector on public.planificacion_proyecto_sabados;
create policy planificacion_proyecto_sabados_sector on public.planificacion_proyecto_sabados
  for all to authenticated
  using (public.tiene_sector('planificacion'))
  with check (public.tiene_sector('planificacion'));

-- "solo visión" no escribe (restrictivas, como en el 063)
drop policy if exists planificacion_proyecto_sabados_solo_editores_ins on public.planificacion_proyecto_sabados;
drop policy if exists planificacion_proyecto_sabados_solo_editores_upd on public.planificacion_proyecto_sabados;
drop policy if exists planificacion_proyecto_sabados_solo_editores_del on public.planificacion_proyecto_sabados;
create policy planificacion_proyecto_sabados_solo_editores_ins on public.planificacion_proyecto_sabados
  as restrictive for insert to authenticated with check (public.puede_editar_sector('planificacion'));
create policy planificacion_proyecto_sabados_solo_editores_upd on public.planificacion_proyecto_sabados
  as restrictive for update to authenticated
  using (public.puede_editar_sector('planificacion')) with check (public.puede_editar_sector('planificacion'));
create policy planificacion_proyecto_sabados_solo_editores_del on public.planificacion_proyecto_sabados
  as restrictive for delete to authenticated using (public.puede_editar_sector('planificacion'));

-- Auditoría (si corriste el 080): registrar cambios de sábados.
drop trigger if exists zz_auditoria on public.planificacion_proyecto_sabados;
do $$ begin
  if to_regproc('public.fn_core_auditoria') is not null then
    execute 'create trigger zz_auditoria after insert or update or delete on public.planificacion_proyecto_sabados for each row execute function public.fn_core_auditoria(''planificacion'')';
  end if;
end $$;
