---
name: naming
description: "Trigger: nombrar variables, naming, nombres de variables, escribir codigo, revisar codigo. Convenciones para nombrar variables, funciones, tipos y helpers en TypeScript/React."
license: Apache-2.0
metadata:
  author: ignadev
  version: "1.0.0"
  scope:
    - example
  auto_invoke:
    - "nombrar variables"
    - "naming"
    - "nombres de variables"
  owner: repo-maintainers
  skill_type: encoded_preference
  risk_level: low
  allowed_tools:
    - read
    - edit
    - grep
---

# naming

## Activation Contract

Usar al escribir, modificar o revisar codigo TypeScript/React. Aplica a variables, parametros, funciones, tipos, interfaces, stores, handlers y helpers.

No usar para copy visible al usuario; eso vive en `copy.ts` o en la skill especifica del flujo.

## Hard Rules

1. **Prohibidas variables de una sola letra**: no usar `p`, `e`, `i`, `x`, `r`, `s`, `d` ni similares.
2. **Excepcion minima**: se permite una sola letra unicamente en callbacks matematicos triviales o indices ultra-locales donde el significado sea universal y no afecte legibilidad. Si hay duda, NO es excepcion.
3. **Nombres por concepto, no por tipo tecnico**: preferir `item`, `category`, `response`, `validationError` antes que `obj`, `data`, `value` cuando el dominio es conocido.
4. **Handlers describen intencion**: `handleSubmit`, `handleDeleteItem`, `goToEdit`, no `handleClick` si hay mas de una accion posible.
5. **Booleans con pregunta clara**: `isLoading`, `hasError`, `canSubmit`, `shouldRetry`.
6. **Colecciones en plural**: `items`, `categories`, `fieldErrors`; elemento iterado con nombre completo: `item`, `category`, `fieldError`.
7. **Sin abreviaturas cripticas**: no `cfg`, `res`, `err`, `tmp`, salvo APIs externas ya nombradas asi y con scope minimo.

## Decision Gates

| Caso | Nombre correcto |
| --- | --- |
| `.map(x => ...)` | `.map(item => ...)` |
| `catch (e)` | `catch (error)` |
| `const res = await fetch(...)` | `const response = await fetch(...)` |
| `const d = validate(...)` | `const validation = validate(...)` |
| `items.map(i => ...)` con dominio conocido | `items.map(item => ...)` |

## Execution Steps

1. Antes de editar, identificar el concepto de dominio detras de cada dato.
2. Nombrar primero por intencion; recien despues optimizar longitud si sigue siendo claro.
3. Al revisar codigo, buscar callbacks y `catch` con variables de una letra.
4. Reemplazar nombres genericos cuando el archivo ya revela el dominio.
5. Si un nombre largo se repite demasiado, extraer helper con nombre claro en vez de abreviar.

## Output Contract

Al cerrar una tarea de codigo, reportar si se ajustaron nombres relevantes o si no aplicaba. Si se deja una excepcion de una letra, justificarla explicitamente.

## References

- `AGENTS.md` del proyecto objetivo — filosofia de codigo sin magia y decisiones con por que tecnico.
- `Skills/examples/react-vite-ts/README.md` — origen y alcance de estos ejemplos.
