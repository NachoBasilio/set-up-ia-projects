---
name: error-handling
description: "Trigger: manejo de errores, error global, error boundary, unhandledrejection, mostrar error, error async. Convenciones para manejar errores locales, globales y flujos async en React + TypeScript."
license: Apache-2.0
metadata:
  author: ignadev
  version: "1.0.0"
  scope:
    - example
  auto_invoke:
    - "manejo de errores"
    - "error global"
    - "error boundary"
    - "error async"
  owner: repo-maintainers
  skill_type: encoded_preference
  risk_level: high
  allowed_tools:
    - read
    - write
    - edit
    - glob
    - grep
    - bash
---

# error-handling

## Activation Contract

Usar al crear o modificar flujos async, capturar errores runtime, mostrar feedback de error o tocar un store global de errores, un error boundary o listeners globales del entrypoint de la app.

No usar para cambios puramente visuales sin interaccion/async ni refactors sin error observable.

## Hard Rules

1. **Separar error local vs global**: validacion o credenciales invalidas van cerca del flujo; runtime, red, 500 e inesperados van al global.
2. **Pages y componentes no reportan directo al global**: lo hacen el entrypoint de la app, el error boundary o los stores de feature en su `catch`.
3. **Nunca `catch {}` vacio**: toda excepcion termina en estado observable o reporte global.
4. **Acciones async con contrato explicito** cuando la UI necesita feedback; no depender solo de side-effects.
5. **Siempre `finally` para loading**: el flag no puede quedar prendido por error.
6. **Mensajes seguros y accionables**: sin stack trace ni payload sensible en UI.
7. **Feedback accesible**: mensajes visibles con `role="alert"`; cierres con `aria-label` claro.
8. **Tests minimos**: exito, loading y error; si hay global, probar que validacion no reporta y error infra si.

## Decision Gates

| Situacion | Canal |
| --- | --- |
| Error corregible por el usuario en ese flujo | inline/local (`error` del store o del form) |
| Validacion de dominio o credenciales invalidas | local, no global |
| Red caida, 500, timeout o error inesperado | store global de errores desde store/App/boundary |
| Error de render | error boundary de la app |
| `window.error` o `unhandledrejection` | listener en el entrypoint de la app |
| La UI necesita saber si la accion fallo | `ActionResult` tipado |

## Execution Steps

1. Clasificar el error antes de escribir codigo: local/domain vs infra/global.
2. En stores async, setear loading antes del `try`, limpiar/setear error local segun corresponda y apagar loading en `finally`.
3. Devolver `ActionResult` si la pagina/form necesita reaccionar al resultado.
4. Reportar al global solo desde los canales permitidos.
5. Mantener mensajes de UI cortos, seguros y verificables por Testing Library.
6. Agregar tests de success/loading/error y del store global cuando aplique.
7. Verificar con lint, tests y typecheck del proyecto si el cambio toca contratos TypeScript.

```ts
export type ActionResult<T = void> =
	| { ok: true; data: T }
	| { ok: true }
	| { ok: false; error: string; kind?: 'validation' | 'domain' | 'infra' };
```

```ts
submit: async values => {
	set({ isLoading: true, error: null });

	try {
		await createItem(values);
		return { ok: true };
	} catch (err) {
		const message = err instanceof Error ? err.message : 'Error inesperado';

		if (isValidationError(err)) {
			set({ error: message });
			return { ok: false, error: message, kind: 'validation' };
		}

		useGlobalErrorStore.getState().reportError({ message, source: 'api' });
		return { ok: false, error: message, kind: 'infra' };
	} finally {
		set({ isLoading: false });
	}
};
```

## Output Contract

Al cerrar un cambio de errores, reportar: clasificacion local/global, contrato async usado, componentes/stores que muestran feedback, tests de error y checks ejecutados.

## References

- `Skills/examples/react-vite-ts/zustand-store/SKILL.md` — async actions con loading y resultados tipados.
- `Skills/examples/react-vite-ts/testing/SKILL.md` — tests de loading/error/global store.
- `Skills/examples/react-vite-ts/README.md` — origen y alcance de estos ejemplos.
