# Contratos de adaptadores deterministas

`search_docs`, `validate` y `verify` son nombres de contrato, no implementaciones universales. Cada repositorio provee o declara sus propios adaptadores y comandos reales.

## Contrato común

- **Entrada:** argumentos explícitos, por ejemplo `--query`, `--input`, `--attempt` y `--format json`.
- **Salida:** JSON acotado por stdout; diagnóstico humano breve por stderr.
- **Códigos:** `0` éxito; `1` resultado negativo verificable; `2` uso o entrada inválida; `3` adaptador bloqueado/no disponible; `4` error de infraestructura reproducible.
- **Errores:** objetos con `code`, `message`, `path` opcional y `hint` opcional; no volcar trazas ni secretos por defecto.
- **Reproducibilidad:** misma entrada, snapshot/configuración declarada y versión producen el mismo resultado o explican la diferencia.
- **Límites:** acotar tiempo, bytes, número de resultados y profundidad de errores; declarar truncamiento.
- **Seguridad:** no aceptar secretos en argumentos o salida; leer credenciales solo mediante mecanismos del proyecto y redactarlas.

## Formato JSON genérico

```json
{
  "status": "ok",
  "adapter": "search_docs",
  "adapter_version": "project-defined",
  "items": [],
  "errors": [],
  "warnings": [],
  "truncated": false,
  "reproducible": true,
  "metadata": {"source": "project-docs"}
}
```

`status` puede ser `ok`, `invalid`, `blocked` o `error`. `items` cambia según el adaptador, pero los campos de control permanecen.

## `search_docs`

Busca documentación, código, schemas o configuración autorizada para el caso. Debe devolver cada resultado con origen, ruta o identificador, fragmento acotado y versión/snapshot cuando exista. No debe presentar conocimiento general del modelo como fuente.

Ejemplos de adaptadores posibles: índice local de Markdown, consulta a una API interna aprobada, `git` sobre un commit fijado o un buscador de schemas. Ninguno es obligatorio ni universal.

## `validate`

Comprueba el candidato contra contratos objetivos: parseo, schema, formato, lint, tests o reglas de seguridad disponibles. Debe distinguir errores reparables de bloqueos y devolver rutas precisas. No modifica el candidato salvo que el contrato del proyecto documente una transformación explícita.

## `verify`

Comprueba el resultado final de forma independiente: ejecuta checks de aceptación, revisa el diff y confirma que las fuentes y limitaciones están declaradas. Debe evitar confiar únicamente en una marca producida por `validate` o por el LLM.

Un stack puede implementar estos contratos con shell, Python, Go, un runner CI u otra tecnología. Elegir según el repositorio; no prescribir React, Node, Shopify ni otro proveedor.
