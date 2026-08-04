# Ejemplos: React + Vite + TypeScript

Skills anonimizadas y generalizadas, destiladas de proyectos productivos reales (React + Vite + TypeScript, arquitectura `core/features/app`). Usalas como punto de partida cuando FASE 3 de `START-UP.md` (Analisis obligatorio) detecta un proyecto frontend con este stack.

`metadata.scope: [example]` las marca como plantillas, no como skills activas de este repo (`scope: [root]`).

## Contenido

- `react-component/` — estructura de componentes, capas y mobile-first.
- `zustand-store/` — cuando usar Zustand y contrato de acciones async.
- `naming/` — convenciones de nombres en TypeScript/React.
- `error-handling/` — separacion de errores locales vs globales.
- `testing/` — Vitest + Testing Library, queries semanticas y async.

## Como usarlas

1. Copia la carpeta de la skill relevante a `Skills/<nombre>/SKILL.md` del proyecto objetivo.
2. Ajusta rutas, nombres de dominio y convenciones al proyecto real (no copiar verbatim).
3. Corre `./scripts/validate-skills.sh` para confirmar que el frontmatter sigue siendo valido despues de adaptarla.
