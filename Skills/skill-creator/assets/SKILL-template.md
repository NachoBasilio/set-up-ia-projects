---
name: <skill-name>
description: >
  <Que hace esta skill>.
  Trigger: <Cuando debe activarse automaticamente>.
license: Apache-2.0
metadata:
  author: <equipo-o-org>
  version: "1.0.0"
  scope:
    - root
  auto_invoke:
    - "<accion o contexto>"
  owner: <responsable>
  skill_type: capability_uplift
  review_by: "YYYY-MM-DD"
  sunset_at: null
  risk_level: low
  allowed_tools: []
---

<!-- Restricciones de name/description y presupuesto de tokens: ver START-UP.md (FASE 3) -->

# <skill-name>

## Cuando usar

- <caso 1>
- <caso 2>

## Explicacion para usuarios nuevos

Esta skill es de tipo `<capability_uplift|encoded_preference>`.
Explica brevemente por que ese tipo aplica y si debe caducar o mantenerse.

## Cuando NO usar

- <caso fuera de alcance>

## Reglas criticas

- <regla 1>
- <regla 2>

## Checklist rapido

- [ ] <control 1>
- [ ] <control 2>

## Comandos

```bash
# Reemplaza este bloque por comandos reales y verificables del repo objetivo.
# Ejemplo minimo:
# ./scripts/validate-skills.sh --dry-run
# ./scripts/validate-skills.sh
```
