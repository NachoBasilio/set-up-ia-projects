# Plantilla de `SKILL.md`

Copiar y adaptar; no asumir que los adaptadores existen. Mantener el cuerpo compacto y mover conocimiento largo a `references/`.

```markdown
---
name: <kebab-case>
description: >
  Usar esta skill cuando [señales positivas concretas]. Activarla también
  cuando [variación relevante]. No usarla para [señales negativas].
license: Apache-2.0
metadata:
  author: <equipo>
  version: "1.0.0"
  scope: [root]
  auto_invoke:
    - "señal concreta"
  owner: <responsable>
  skill_type: capability_uplift
  review_by: "YYYY-MM-DD"
  risk_level: low
  allowed_tools: []
---

# <Nombre>

## Controlador

Aplicar [`docs/programmatic-workflow.md`](../../docs/programmatic-workflow.md)
y ejecutar el preflight de [`docs/repository-targeting.md`](../../docs/repository-targeting.md)
antes de leer o modificar el repositorio.

1. **DISCOVER:** resolver repositorio, alcance y skill aplicable.
2. **RETRIEVE:** ejecutar `scripts/search_docs` antes de generar cuando la tarea dependa de contexto externo o del proyecto. Si no existe adaptador, declarar el bloqueo.
3. **PLAN:** separar hechos, supuestos verificables, cambios y aceptación.
4. **GENERATE:** adaptar al stack real; no inventar APIs, schemas, comandos ni archivos.
5. **VALIDATE:** ejecutar `scripts/validate` antes de mostrar o entregar el resultado.
6. **REPAIR:** corregir solo errores observables, con un máximo de 3 intentos salvo que el proyecto defina otro `N`.
7. **VERIFY:** ejecutar `scripts/verify` de forma final e independiente y revisar evidencia.

## Contrato de salida

Entregar únicamente resultado validado y verificado, con archivos cambiados,
checks ejecutados, errores restantes y limitaciones declaradas. Si una etapa
queda bloqueada, informar la causa y no completar los huecos con invenciones.

## Recursos

- Conocimiento extenso: `references/`.
- Entradas de salida: `assets/`.
- Adaptadores del proyecto: `scripts/search_docs.*`, `scripts/validate.*`, `scripts/verify.*`.
- Casos representativos: `evals/`.
```

Para una skill estable, cambiar `skill_type` a `encoded_preference` y quitar `review_by` si no aplica. La descripción es el router: debe decir cuándo activar y cuándo no activar.
