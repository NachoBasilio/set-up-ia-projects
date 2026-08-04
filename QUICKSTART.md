# Quickstart (5 minutos)

Aplicá este framework a cualquier proyecto en minutos. Validación local + CI, sin lock-in.

## Antes de tocar NADA (OBLIGATORIO)

Confirma explícitamente con tu agente:
- **Tipo de proyecto**: web, API, mobile, desktop, librería, monorepo
- **Arquitectura**: capas, hexagonal, clean, modular, feature-first

⚠️ **Si no está claro**: marca como "suposición a validar", NO cierres setup sin confirmación.

## 1. Copiar base

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

## 3. Skills con taxonomía correcta

Toda skill nueva debe declarar:

**Temporal** (`capability_uplift`):
```yaml
skill_type: capability_uplift
review_by: "2026-06-01"  # OBLIGATORIO
```

**Estable** (`encoded_preference`):
```yaml  
skill_type: encoded_preference
# review_by opcional
```

**Regla**: si es `capability_uplift`, SIEMPRE incluir `review_by`.

Proyecto React + Vite + TypeScript: partir de `Skills/examples/react-vite-ts/` (`scope: [example]`) y adaptar, no copiar verbatim.

## 4. Validar setup

```bash
# Desde tu proyecto
./scripts/validate-skills.sh --dry-run  # Solo auditoría
./scripts/validate-skills.sh            # Validación completa
```

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
