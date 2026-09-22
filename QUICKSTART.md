# Quickstart (5 minutos)

Aplicá este framework a cualquier proyecto en minutos. Validación local + CI, sin lock-in.

## Antes de tocar NADA (OBLIGATORIO)

### Identidad del repositorio

Lee [`docs/repository-targeting.md`](docs/repository-targeting.md) y verifica:

- [ ] `git rev-parse --show-toplevel` coincide con el repositorio esperado.
- [ ] Inspeccionaste `pwd`, `git status --short --branch`, `git remote -v` y la rama actual.
- [ ] Revisaste el `AGENTS.md` y `README.md` más cercanos.
- [ ] Confirmaste si el cambio es del framework reusable o de una aplicación.
- [ ] Si hay varios destinos plausibles o alguna identidad es ambigua, te detuviste para preguntar.

Confirma explícitamente con tu agente:
- **Tipo de proyecto**: web, API, mobile, desktop, librería, monorepo
- **Arquitectura**: capas, hexagonal, clean, modular, feature-first

⚠️ **Si no está claro**: marca como "suposición a validar", NO cierres setup sin confirmación.

## 1. Copiar base

Luego de confirmar el destino, selecciona el workflow y la skill aplicable. Para tareas con generación o cambios, usa [`docs/programmatic-workflow.md`](docs/programmatic-workflow.md) y [`Skills/programmatic-workflow/SKILL.md`](Skills/programmatic-workflow/SKILL.md): recuperar antes de generar, validar antes de entregar y verificar al final.

En tu proyecto target:
```bash
# Copiar estos archivos/carpetas desde start-up-proyecto/
cp START-UP.md tu-proyecto/
cp AGENTS.md tu-proyecto/  
cp -r Skills/ tu-proyecto/
cp -r scripts/ tu-proyecto/
```

## 2. Configurar agente

**OpenCode/Claude** sobre el proyecto target.

**Prompt recomendado**:
```
Usa START-UP.md como protocolo. Analiza este repo completo, adapta AGENTS.md 
al contexto real y crea skills en formato Skills/<nombre>/SKILL.md.

Contexto del proyecto: [web app, API REST, etc.]
Arquitectura: [capas, hexagonal, etc.]

Mantener reglas verificables y anti-ruido. No inventar comandos.
```

## 3. Taxonomía de skills

Toda skill nueva debe declarar `skill_type`: `capability_uplift` (temporal) o `encoded_preference` (estable). Definición completa y regla de `review_by`: ver `START-UP.md` (FASE 4).

Proyecto React + Vite + TypeScript: partir de `Skills/examples/react-vite-ts/` (`scope: [example]`) y adaptar, no copiar verbatim.

## 4. Validar setup

```bash
# Desde tu proyecto
./scripts/validate-skills.sh --dry-run  # Solo auditoría
./scripts/validate-skills.sh            # Validación completa
```

`validate-skills.sh` es el validador de metadata de skills (estructura y frontmatter): corre una sola vez sobre el setup, y es distinto de la etapa `VALIDATE` del flujo programático por tarea ([`docs/programmatic-workflow.md`](docs/programmatic-workflow.md)), que valida cada artefacto generado.

**Interpretación**:
- ✅ `0`: setup correcto
- ❌ `1`: errores a corregir

## 5. Iterar hasta que funcione

Si falla validación:
1. Revisar errores en output del script
2. Corregir `AGENTS.md` o `Skills/*/SKILL.md`
3. Re-validar

**Errores comunes**:
- Falta `metadata.review_by` en `capability_uplift`
- Falta frontmatter obligatorio
- Referencias a paths que no existen

## Ejemplos de uso

**React app**:
```
Contexto: SPA React con TypeScript, arquitectura por features
Stack: Vite + Vitest + ESLint + Prettier
```

**API Node.js**:
```
Contexto: API REST con Express, arquitectura hexagonal
Stack: Node.js + TypeScript + Jest + Docker
```

**Librería Python**:
```
Contexto: Librería de data science, arquitectura modular
Stack: Python + pytest + ruff + mypy
```

## Referencias

- [README.md](README.md) - Visión general y filosofía
- [START-UP.md](START-UP.md) - Protocolo completo paso a paso
- [MIGRACION.md](MIGRACION.md) - Plan de evolución y mantenimiento
- [docs/agent-skills-guide.md](docs/agent-skills-guide.md) - Formato Agent Skills y arquitectura operativa
- [docs/programmatic-workflow.md](docs/programmatic-workflow.md) - Contrato canónico de siete etapas
- [docs/deterministic-adapters.md](docs/deterministic-adapters.md) - Contratos de los adaptadores deterministas
- [docs/evals-and-telemetry.md](docs/evals-and-telemetry.md) - Cómo medir si una skill mejora resultados reales
- [docs/repository-targeting.md](docs/repository-targeting.md) - Preflight de identidad del repositorio
- `scripts/adapters/` - Implementaciones de referencia de `search_docs`, `validate` y `verify`
