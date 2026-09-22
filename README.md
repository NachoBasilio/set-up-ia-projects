# Start-up con IA que no sea un desastre

Framework para que agentes trabajen en tu proyecto sin romper todo. La IA entiende tu contexto antes de proponer cambios, valida que funciona, y no te genera código que "anda" pero es imposible de mantener.

## Quickstart (5 minutos)

Antes de elegir setup o skill, aplica el [preflight de repositorio](docs/repository-targeting.md). Después sigue el [flujo programático canónico](docs/programmatic-workflow.md): `DISCOVER → RETRIEVE → PLAN → GENERATE → VALIDATE → REPAIR → VERIFY`.

1. Copia `START-UP.md`, `AGENTS.md`, `Skills/` y `scripts/` a tu proyecto
2. Ejecuta: `./scripts/validate-skills.sh --dry-run`
3. Usa tu agente con: *"Usa START-UP.md como protocolo, analiza el repo y configura AGENTS/Skills para este contexto"*

Ver [QUICKSTART.md](QUICKSTART.md) para detalles.

## Estructura del framework

- **[START-UP.md](START-UP.md)** → Protocolo completo por fases para configurar cualquier proyecto
- **[AGENTS.md](AGENTS.md)** → Reglas mínimas y verificables para agentes (anti-ruido)
- **Skills/<nombre>/SKILL.md** → Templates con dos tipos. Definición completa y reglas de ciclo de vida: `START-UP.md` (FASE 4).
  - `capability_uplift`: capacidad técnica temporal.
  - `encoded_preference`: preferencia de equipo estable.
  - `Skills/examples/react-vite-ts/` → ejemplos concretos para stack React + Vite + TypeScript (`scope: [example]`, para adaptar, no copiar)
- **[MIGRACION.md](MIGRACION.md)** → Plan de migración y mantenimiento
- **[docs/repository-targeting.md](docs/repository-targeting.md)** → Protocolo canónico para identificar el repositorio correcto antes de cualquier cambio
- **[docs/agent-skills-guide.md](docs/agent-skills-guide.md)** → Diferencia entre el formato Agent Skills y este controlador operativo
- **[docs/programmatic-workflow.md](docs/programmatic-workflow.md)** → Contrato de siete etapas
- **[docs/deterministic-adapters.md](docs/deterministic-adapters.md)** → Contratos de los adaptadores deterministas (`search_docs`, `validate`, `verify`)
- **[docs/evals-and-telemetry.md](docs/evals-and-telemetry.md)** → Cómo medir si una skill mejora resultados reales
- **[Skills/programmatic-workflow/SKILL.md](Skills/programmatic-workflow/SKILL.md)** → Skill reusable para aplicar el flujo
- **scripts/validate-skills.sh** → Validador de metadata de skills (estructura y frontmatter); distinto de la etapa VALIDATE por tarea del flujo programático
- **scripts/adapters/** → Implementaciones de referencia de los adaptadores deterministas de este repo

## Regla fundamental

No importa tu stack (React, Go, Python, lo que sea):

- **Linter configurado** y ejecutándose automáticamente
- **Validación antes de commit** (el script ya lo hace)
- **Tests que realmente validen algo**

Sin esto, cualquier IA genera código que "funciona" en su máquina pero explota en producción.

## Filosofía

Framework genérico a propósito. No te dice "usa React + TypeScript + Tailwind" porque la IA debe adaptarse a TU stack, TU arquitectura, TU forma de trabajar.

He visto demasiados proyectos donde el agente propone "mejores prácticas" que no tienen nada que ver con lo que ya funciona. Este approach **fuerza a la IA a entender primero, proponer después**.

## Créditos

Creado por **Ignacio Nicolas Basilio Buracco (Ignadev)** basado en años de QA Automation y conceptos de [Gentleman Programming](https://www.youtube.com/@gentlemanprogramming).

- Web: [ignadev.com](https://ignadev.com/)
- GitHub: [@NachoBasilio](https://github.com/NachoBasilio)

---

*Si esto te sirvió, mandá un PR. Si algo no funciona, abrí un issue.*
