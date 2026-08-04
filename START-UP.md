# START-UP: Protocolo para agentes

Usa este protocolo antes de configurar `AGENTS.md` y `Skills/` en cualquier proyecto.

## Objetivo

Base profesional y GENÉRICA que se adapta al contexto real después del análisis del repo. Criterio anti-ruido: solo reglas de alto valor, cero redundancia.

## Reglas de trabajo

1. **Español claro y profesional** en toda la documentación
2. **"Simple, no fácil"**: evitar atajos frágiles
3. **No inventar**: derivar reglas del código/estructura existente
4. **No romper**: mantener comportamiento actual
5. **Reflejar realidad**: documentación = código real
6. **Validador obligatorio**: linter/análisis para CUALQUIER lenguaje
7. **AGENTS.md minimalista**: específico y verificable, sin duplicar README/docs
8. **Anti-sobre-instrucción**: cada regla debe reducir decisiones, no abrirlas

## Principio anti-ruido

**Evidencia**: más contexto ≠ mejores resultados (arXiv:2602.11988).

Por defecto NO agregar:
- Overview largo si es inferible del repo
- Comandos/políticas ya documentadas
- Procesos completos (referenciar fuente canónica)

SÍ agregar:
- Restricciones de alto impacto: seguridad, contratos, compatibilidad
- Validaciones mínimas obligatorias

**Excepción**: si el repo tiene documentación pobre, ampliar `AGENTS.md` solo con lo mínimo para setup/tests.

## FASE 1: Análisis obligatorio

### Preguntas iniciales (OBLIGATORIO)

Antes de analizar, confirmar con el usuario:
- **Tipo**: web, API, mobile, desktop, librería, monorepo
- **Arquitectura**: capas, hexagonal, clean, modular, feature-first

Si no está claro:
- Proponer hipótesis basada en el repo
- Marcarla como **"suposición a validar"**
- NO cerrar AGENTS/skills sin validación

### Análisis del repo
- Detectar stack, framework, estructura
- Revisar configuración real (package.json, lint, build)
- Buscar documentación existente
- Analizar convenciones de commits (`git log`)
- Identificar patrones críticos

**Salida mínima**:
- Mapa de carpetas clave
- Reglas verificables
- Lista de skills necesarias

## FASE 2: Diseño de AGENTS.md

### Estructura jerárquica
- `AGENTS.md` raíz (reglas globales + tabla skills + auto-invocación)
- `AGENTS.md` por áreas (`src/`, `components/`, etc.) según corresponda
- **Precedencia**: guía más cercana al código manda

### Diseño minimalista
- **Máximo 6 secciones**
- **Máximo 5 reglas obligatorias**
- **Una línea de criterio verificable** (Definition of done)
- **Referencias explícitas** vs duplicar contenido

### Contenido obligatorio
- Alcance
- Reglas específicas  
- Auto-invocar skills
- Checklist obligatorio

### Anti-redundancia checklist
- [ ] Cada regla aporta info no presente en README/docs/skills
- [ ] Sin secciones narrativas sin decisión operativa
- [ ] Sin listas extensas de herramientas sin condición de uso
- [ ] Precedencia definida para resolver contradicciones

## FASE 3: Diseño de skills

### Ubicación obligatoria
`Skills/<nombre>/SKILL.md` con frontmatter + trigger + reglas + checklist + comandos

### Contrato moderno obligatorio

**Estructura**:
- `Skills/<nombre>/` (carpeta por skill)
- `Skills/<nombre>/SKILL.md` (principal)
- `assets/`, `references/`, `scripts/` (opcionales)

**Frontmatter mínimo**:
```yaml
---
name: <skill-name>
description: >
  Qué hace y contexto de activación
license: Apache-2.0
metadata:
  author: <equipo-o-org>
  version: "1.0.0"
  scope: [root]
  auto_invoke:
    - "contexto concreto"
  owner: <responsable>
  skill_type: capability_uplift # capability_uplift|encoded_preference
  review_by: "YYYY-MM-DD" # obligatorio para capability_uplift
  risk_level: low # low|medium|high
  allowed_tools: []
---
```

`name` debe cumplir `^[a-z0-9-]{1,64}$` y `description` debe ser no vacía y ≤1024 caracteres (spec oficial Agent Skills de Anthropic).

El cuerpo de `SKILL.md` (sin frontmatter) debería mantenerse bajo ~5k tokens; lo que pese más va a `references/`, `scripts/` o `assets/` (progressive disclosure).

### Taxonomía OBLIGATORIA

**capability_uplift**:
- Capacidades técnicas temporales
- DEBE tener `review_by` (fecha de revisión)
- RECOMENDADO `sunset_at` (plan de retiro)

**encoded_preference**:
- Preferencias estables de equipo/producto
- NO caduca por mejora de modelo
- Solo cambia si cambia decisión de negocio/equipo

### Reglas de seguridad
- Prod/billing/deploy: requerir modo manual + checklist
- `allowed_tools` mínimo necesario
- No ejecutar scripts no versionados

### Calidad obligatoria
- Casos: happy path, edge, negativo
- Métricas: pass rate, tiempo, tokens
- Re-evaluar en cambios de versión mayor

### Skills de referencia

**skill-creator** (`Skills/skill-creator/SKILL.md`):
- Crear skills reusables con estructura estándar
- Frontmatter completo + reglas + ejemplos + comandos
- Evitar skills triviales o one-off

**skill-sync** (`Skills/skill-sync/SKILL.md`):  
- Sincronizar metadata después de crear/modificar
- Auto-generar tablas en `AGENTS.md`
- Mantener coherencia entre docs

Si el análisis detecta un proyecto React + Vite + TypeScript, usar `Skills/examples/react-vite-ts/` (`scope: [example]`) como punto de partida a adaptar, no a copiar verbatim.

### Compatibilidad legacy
- `Skills/*.md` solo como redirect temporal
- Nueva creación: usar `Skills/<nombre>/SKILL.md`
- Si existen ambas versiones: nueva = fuente de verdad
- Casing correcto: `Skills/` (S mayúscula)

## FASE 4: Verificación

Auditar coherencia entre:
- AGENTS.md ↔ skills ↔ configuración real ↔ comportamiento del código

**Si hay conflicto**: corregir inmediatamente (NO dejar documentación mentirosa)

## FASE 5: Validación técnica

**Mínimo obligatorio**:
- Lint (ruff, golangci-lint, eslint, flake8, etc.)
- Typecheck/build según stack

**Regla dura**: antes de commitear, correr validadores del stack activo. Si no existe linter, definir uno antes de continuar.

## Entrega esperada

- AGENTS.md en español, por capas, sin contradicciones
- Skills profesionales adaptadas al proyecto  
- MIGRACION.md actualizado
- Checklist operativo
- Resumen claro: qué, por qué, dónde
