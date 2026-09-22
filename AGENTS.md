# AGENTS.md

Guia minima para agentes que trabajen en este repo.

## Objetivo

Evitar ruido: este archivo define solo reglas operativas no obvias.

## Fuente de verdad (orden de precedencia)

1. Solicitud explicita del usuario.
2. Este `AGENTS.md` (reglas minimas y verificables).
3. [`docs/repository-targeting.md`](docs/repository-targeting.md), [`docs/programmatic-workflow.md`](docs/programmatic-workflow.md) y [`docs/deterministic-adapters.md`](docs/deterministic-adapters.md) (gates obligatorios antes de leer, cambiar o entregar).
4. `README.md` (vision y flujo general).
5. `START-UP.md`, `MIGRACION.md` y `Skills/*/SKILL.md` (proceso detallado y referencias).

Si dos fuentes se contradicen, gana la de mayor precedencia.

## Reglas obligatorias

1. No duplicar contenido: si una regla ya existe en `README.md`, `START-UP.md` o `Skills/*/SKILL.md`, referenciarla en lugar de reescribirla.
2. No inventar comandos: usar solo comandos realmente disponibles en el repo o declararlos como "pendientes de definir".
3. Mantener cambios auditables: cada cambio debe explicar que se hizo, por que y en que archivo.
4. Preservar coherencia: documentacion y contenido deben reflejar el estado real del repo.
5. Antes de leer o modificar un repositorio, aplicar [`docs/repository-targeting.md`](docs/repository-targeting.md) y detenerse ante cualquier destino ambiguo.
6. Para tareas con generación o cambios, seguir [`docs/programmatic-workflow.md`](docs/programmatic-workflow.md) y usar [`Skills/programmatic-workflow/SKILL.md`](Skills/programmatic-workflow/SKILL.md); no entregar sin validación y verificación.

## Flujo minimo para cambios de documentacion

1. Leer `README.md` y `START-UP.md` para detectar reglas ya existentes.
2. Aplicar el preflight de [`docs/repository-targeting.md`](docs/repository-targeting.md).
3. Cambiar solo lo necesario para resolver la solicitud actual.
4. Eliminar redundancias evidentes en lugar de sumar texto nuevo.
5. Cerrar con un resumen corto de cambios por archivo y checks ejecutados.

## Definition of done

- No hay texto repetido entre `AGENTS.md`, `README.md`, `START-UP.md` y `Skills/*/SKILL.md`.
- Todas las reglas del archivo son accionables y verificables.
- El archivo se mantiene breve y enfocado en decisiones operativas.

## Compatibilidad legacy

- Los archivos `Skills/*.md` se mantienen solo como compatibilidad temporal.
- Toda skill nueva o actualizada usa `Skills/<nombre>/SKILL.md`.
