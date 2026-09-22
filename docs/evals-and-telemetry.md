# Evals y telemetría

Las evals miden si el flujo mejora resultados reales; la telemetría explica dónde funciona o se bloquea. Ninguna sustituye la corrección técnica ni la revisión del resultado.

## Comparación mínima

1. Crear prompts representativos: happy path, caso límite, entrada inválida y falta de adaptador.
2. Ejecutar una línea base sin la skill.
3. Ejecutar los mismos prompts con la skill y sus adaptadores.
4. Evaluar aserciones observables: repositorio correcto, recuperación antes de generación, validación antes de entrega, reparación acotada, no invención y verificación final.
5. Comparar pass rate, tiempo y tokens, incluyendo fallos y bloqueos declarados.

La línea base no debe recibir instrucciones ocultas de la skill. Registrar versión del prompt, repositorio/snapshot, configuración y límites.

## Señales útiles

- **Activación:** skill considerada y activada/no activada, con razón disponible para el cliente.
- **Recuperación:** adaptador, consulta, fuentes, cantidad, truncamiento y duración.
- **Validación:** adapter, comando, estado, códigos, número de errores y duración.
- **Reparación:** intentos usados, errores resueltos y motivo de parada.
- **Resultado:** verificación, pass rate, tiempo total y tokens.

Redactar secretos, limitar cardinalidad y no registrar prompts sensibles sin autorización. Una telemetría perfecta no convierte una respuesta no verificada en correcta.

## Ejemplo mínimo de `evals/evals.json`

```json
{
  "skill_name": "programmatic-workflow",
  "evals": [
    {
      "id": "retrieve-before-generate",
      "prompt": "Adapta este cambio al repositorio y entrega solo después de validar.",
      "assertions": [
        "Ejecuta o declara el adaptador de retrieval antes de generar",
        "Incluye resultado de validación y verificación",
        "No inventa comandos ausentes"
      ]
    }
  ]
}
```
