# planificacion-taller — Contexto del proyecto

App de **Planificación de taller** de 4housing: planificación, personal, stock, flota,
mantenimiento e informes. Parte del portal unificado. Trabaja por **sede** (La Huella / Neuquén).

## Stack

- **Frontend:** un solo `index.html` (HTML/CSS/JS vanilla). Acceso con supabase-js
  (`sb.from('planificacion_...')`). Ojo: la pantalla de login tiene un logo base64 gigante
  (editar con Python por líneas, no sed).
- **Hosting:** GitHub Pages, org `4housing`, repo `planificacion-taller`. URL: https://4housing.github.io/planificacion-taller/
- **Backend:** Supabase unificado → proyecto `wcpkpwxhqdcdljfwzcmy` (wcpk). Login Microsoft (Azure).

## Datos y acceso

- Tablas con prefijo **`planificacion_`**. Ojo colisión histórica ya resuelta:
  `planificacion` → `planificacion_bloques`, `planificacion_personal` → `planificacion_bloques_personal`,
  y `personal` → `planificacion_personal`. Hay 3 tablas con id IDENTITY (actividad_log,
  linea_base_historial, proyectos_snapshot).
- RLS por sector `planificacion`. Flag por sector **`ve_sueldos`** (jsonb en perfiles_sector)
  para ver montos de sueldos.
- Informes son **sede-aware** (filtran por SEDE); Neuquén tiene su propio detalle
  (persona_real/ausente/horas/trailer).

## Reglas de trabajo — NO NEGOCIABLES

> **Criterio, no candado.** Estas reglas son el default. Se pueden saltar si el dueño
> de la decisión (Pablo) lo resuelve explícitamente — pero Claude debe **advertir ANTES**,
> con claridad, que la acción incumple tal regla y qué riesgo tiene, y esperar el OK.
> Claude nunca rompe una regla por su cuenta ni en silencio.

1. **No romper lo que ya funciona.** Preferí agregar antes que modificar; `grep` de los
   usos antes de tocar código compartido; probá lo que tocaste, no solo lo que agregaste.
2. **SQL nunca se ejecuta solo.** Se entrega como `.sql` y lo corre una persona a mano en Supabase.
3. **Orden de deploy:** primero el SQL (si agrega tablas/columnas), después el HTML.
4. **RLS siempre `authenticated`, nunca `anon`** + compuerta de sector (`tiene_sector('...')`).
5. **Secretos nunca en `index.html`** (público). anon/publishable es pública; tokens/service keys no.
6. **Validá el JS con `node --check`** antes de terminar.
7. **Cambios incrementales y aditivos:** una feature por PR, chico y reversible.
8. **Decisiones estructurales se cierran antes de codear.**
9. **Git:** `git pull` antes (lo edita también Ignacio); ramas por feature + PR o coordinar;
   commits chicos, en español; tras `stash pop`/merge chequeá marcadores de conflicto antes de commitear.
10. **Prefijos de tabla por sector:** `planificacion_` acá; resto `fhcomercial_`, `labocomercial_`,
    `diseno_`, `compras_`, `eerr_`, `logistica_`. `core_` reservado.
11. **Datos de negocio nunca al repo público** (dumps `.sql` gitignoreados).
12. **Diagnosticar con evidencia** (`grep`/`diff`), no adivinar. Reportar con fidelidad.

## Cómo entregar
- HTML/JS: archivo completo, validado con `node --check`. SQL: archivo `.sql` aparte, corrido a mano.
