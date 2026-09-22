# Agent Skills y arquitectura operativa

Este framework usa el formato abierto **Agent Skills** como envoltorio portable, pero agrega un contrato operativo más estricto para que una skill no dependa de memoria implícita del modelo.

## Dos capas que no deben confundirse

### Formato abierto Agent Skills

Una skill es una carpeta con un `SKILL.md` y, opcionalmente, recursos como `scripts/`, `references/` y `assets/`. El agente recibe primero el nombre y `description`, carga el cuerpo cuando la skill se activa y consulta recursos bajo demanda. Esta divulgación progresiva evita cargar una enciclopedia en cada tarea.

El formato no define hooks de Shopify, telemetría, MCP, un proveedor concreto ni nombres universales para scripts.

### Arquitectura operativa de este framework

Inspirada en el patrón programático de Shopify descrito en la investigación suministrada, la skill funciona como un controlador:

```text
USER PROMPT
  → descubrimiento de skills (nombre + descripción)
  → SKILL.md controlador
  → recuperación/búsqueda determinista
  → razonamiento/generación del LLM
  → validación determinista
  → reparación acotada
  → verificación final
  → respuesta, telemetría y evals
```

El contrato completo está en [`programmatic-workflow.md`](programmatic-workflow.md). El preflight de identidad del repositorio está en [`repository-targeting.md`](repository-targeting.md) y ocurre antes de leer o cambiar archivos.

## Responsabilidades

| Componente | Responsabilidad | No debe hacer |
|---|---|---|
| `description` | Enrutar la activación con señales positivas y negativas | Contener el manual completo |
| `SKILL.md` | Orquestar etapas, límites, entradas, salidas y criterios de parada | Inventar comandos, APIs o hechos |
| LLM | Interpretar intención, adaptar el plan al repositorio y generar propuestas | Ser la única fuente de recuperación o validación |
| Scripts deterministas | Buscar contexto, validar schemas/sintaxis/tests, aplicar transformaciones repetibles y exponer errores estructurados | Ocultar decisiones no reproducibles o secretos |

Una limitación del adaptador se declara como bloqueo o alcance no soportado. Nunca se rellena con hechos inventados.

## Layout portable recomendado

```text
Skills/<nombre>/
├── SKILL.md
├── scripts/
│   ├── search_docs.*
│   ├── validate.*
│   └── verify.*
├── references/
├── assets/
└── evals/
```

Este layout es una convención de este framework, no un requisito universal del formato Agent Skills. Los scripts son **adaptadores del proyecto**: deben descubrir los comandos y fuentes reales del repositorio, no asumir una implementación universal de `search_docs`.

## Qué es portable y qué depende del cliente

**Portable:** frontmatter compatible, controlador `SKILL.md`, etapas del flujo, contratos de adaptadores, reglas de no invención, errores estructurados y criterios de verificación.

**Específico del cliente o proveedor:** hooks de activación, formato de telemetría, integración MCP, metadata adicional, ejecución aislada de scripts, almacenamiento de evals y presentación de resultados. Debe documentarse como integración, nunca como parte del estándar abierto.

## Relación con la taxonomía existente

`capability_uplift` y `encoded_preference` siguen describiendo el ciclo de vida de una skill. La arquitectura programática describe **cómo se ejecuta**; la taxonomía describe **qué tipo de conocimiento o preferencia contiene**. Son dimensiones complementarias.
