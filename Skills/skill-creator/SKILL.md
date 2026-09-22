---
name: skill-creator
description: >
  Crea skills nuevas en formato moderno para este repo. Usar cuando se pida
  crear una skill, migrar una skill legacy o estandarizar estructura
  Skills/<nombre>/SKILL.md con metadata valida y enfoque anti-ruido.
license: Apache-2.0
metadata:
  author: ignadev
  version: "2.0.0"
  scope:
    - root
  auto_invoke:
    - "crear skill"
    - "nueva skill"
    - "migrar skill"
    - "skill template"
  owner: repo-maintainers
  skill_type: encoded_preference
  risk_level: medium
  allowed_tools:
    - read
    - glob
    - apply_patch
---

# skill-creator

## Cuando usar

- Crear una skill reusable para el proyecto.
- Migrar `Skills/*.md` a `Skills/<nombre>/SKILL.md`.
- Estandarizar metadata y estructura para auto-activacion.

## Cuando NO usar

- Tareas one-off o triviales.
- Casos donde ya existe una skill equivalente.

## Contrato de salida obligatorio

1. Carpeta `Skills/<skill-name>/`.
2. Archivo `Skills/<skill-name>/SKILL.md` con frontmatter completo.
3. Recursos opcionales (`assets/`, `references/`, `scripts/`) solo si aportan valor real.
4. Actualizacion de referencias en `README.md`, `AGENTS.md` o `START-UP.md` cuando aplique.
5. Explicacion breve en espanol para usuarios nuevos: que resuelve la skill y por que su tipo importa.

## Frontmatter minimo obligatorio

```yaml
---
name: <skill-name>
description: >
  Que hace + contexto concreto de activacion.
license: Apache-2.0
metadata:
  author: <equipo-o-org>
  version: "1.0.0"
  scope: [root]
  auto_invoke:
    - "accion o contexto"
  owner: <responsable>
  skill_type: capability_uplift # capability_uplift|encoded_preference
  review_by: "YYYY-MM-DD" # obligatorio en capability_uplift
  sunset_at: null # opcional, recomendado en capability_uplift
  risk_level: low # low|medium|high
  allowed_tools: []
---
```

Restricciones de `name`/`description` y presupuesto de tokens del cuerpo: ver `START-UP.md` (FASE 4).

## Tipos de skill (obligatorio)

- `capability_uplift`: agrega capacidad tecnica temporal; puede caducar cuando el modelo mejora.
- `encoded_preference`: fija preferencias estables de equipo/producto; no caduca por mejoras del modelo.

Regla dura:

- Si `skill_type` es `capability_uplift`, exigir `review_by` y recomendar `sunset_at`.
- Si `skill_type` es `encoded_preference`, `review_by` es opcional y solo aplica cuando cambia la preferencia del negocio/equipo.

## Reglas criticas

- Descripcion concreta: prohibido "helps with coding" o similares.
- Minimo contexto util: no meter narrativa larga sin reglas accionables.
- Si hay riesgo alto (deploy/prod/billing), exigir modo manual y checklist.
- Mantener compatibilidad legacy sin duplicar contenido funcional.

## Checklist rapido

- [ ] No existe skill equivalente activa.
- [ ] El nombre sigue naming consistente (kebab-case).
- [ ] Frontmatter completo y valido.
- [ ] `skill_type` definido correctamente.
- [ ] Si es `capability_uplift`, tiene `review_by`.
- [ ] Hay criterios de uso/no uso.
- [ ] La skill no contradice `START-UP.md`.
- [ ] Se actualizaron referencias del repo.

## Recursos

- Template base: `Skills/skill-creator/assets/SKILL-template.md`
