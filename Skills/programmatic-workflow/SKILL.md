---
name: programmatic-workflow
description: >
  Aplicar el flujo programático DISCOVER, RETRIEVE, PLAN, GENERATE, VALIDATE,
  REPAIR y VERIFY a tareas de cualquier proyecto. Usar cuando se pida generar,
  modificar, documentar o validar un artefacto con evidencia y controles.
  No usar como sustituto de adaptadores específicos ni para inventar APIs,
  comandos, schemas o hechos que el repositorio no confirma.
license: Apache-2.0
metadata:
  author: ignadev
  version: "1.0.0"
  scope:
    - root
  auto_invoke:
    - "flujo programático"
    - "generar con validación"
    - "modificar con evidencia"
    - "reparación acotada"
  owner: repo-maintainers
  skill_type: encoded_preference
  risk_level: medium
  allowed_tools:
    - read
    - glob
    - grep
    - apply_patch
---

# Flujo programático

## Propósito

Convertir cada tarea en un flujo observable y acotado. Esta skill es un controlador, no una enciclopedia: el conocimiento específico permanece en el repositorio y sus adaptadores.

## Control de ejecución

1. **DISCOVER:** ejecutar el preflight de [`docs/repository-targeting.md`](../../docs/repository-targeting.md), resolver el repositorio objetivo y seleccionar skills por nombre + `description`.
2. **RETRIEVE:** leer [`docs/programmatic-workflow.md`](../../docs/programmatic-workflow.md) y [`docs/deterministic-adapters.md`](../../docs/deterministic-adapters.md); ejecutar `scripts/search_docs` si existe y aplica. Si falta, declarar `blocked` y no inventar contexto.
3. **PLAN:** separar hechos recuperados, supuestos a validar, cambios y criterios de aceptación.
4. **GENERATE:** razonar y generar adaptado al stack real. No asumir React, Node, Shopify ni proveedor alguno.
5. **VALIDATE:** ejecutar `scripts/validate` o el validador real declarado por el proyecto antes de presentar o entregar cualquier resultado.
6. **REPAIR:** corregir únicamente errores estructurados y repetir validación como máximo 3 veces, salvo límite explícito del proyecto. Detenerse ante bloqueo o error no reparable.
7. **VERIFY:** ejecutar `scripts/verify` de forma final e independiente, revisar diff y reportar evidencia, limitaciones y archivos cambiados.

## No invención

No inventar APIs, schemas, comandos, archivos, fuentes ni resultados de tests. Un adaptador ausente es una limitación declarada, no una invitación a completar con conocimiento del modelo. Nunca entregar código sin validación, reintentar infinitamente ni ocultar errores.

## Contrato de salida

Responder con resultado verificado, checks ejecutados, estado de validación, intentos de reparación, limitaciones y `skill_resolution: paths-injected`. Si no se puede verificar, decirlo claramente y no presentar el candidato como terminado.
