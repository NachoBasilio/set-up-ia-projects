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

<!-- Restricciones de name/description y presupuesto de tokens: ver START-UP.md (FASE 4) -->

# <skill-name>

## Controlador

Aplicar `docs/programmatic-workflow.md` y el preflight de `docs/repository-targeting.md`
antes de leer o modificar el repositorio.

1. **DISCOVER:** resolver repositorio, alcance y skill aplicable.
2. **RETRIEVE:** ejecutar `scripts/adapters/search_docs.sh` o el adaptador real declarado por el proyecto antes de generar cuando la tarea dependa de contexto externo o del proyecto. Si no existe adaptador, declarar el bloqueo.
3. **PLAN:** separar hechos, supuestos verificables, cambios y aceptación.
4. **GENERATE:** adaptar al stack real; no inventar APIs, schemas, comandos ni archivos.
5. **VALIDATE:** ejecutar `scripts/adapters/validate.sh` o el adaptador real declarado por el proyecto antes de mostrar o entregar el resultado.
6. **REPAIR:** corregir solo errores observables, con un máximo de 3 intentos salvo que el proyecto defina otro `N`.
7. **VERIFY:** ejecutar `scripts/adapters/verify.sh` o el adaptador real declarado por el proyecto de forma final e independiente y revisar evidencia.

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
