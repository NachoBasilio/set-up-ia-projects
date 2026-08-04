---
name: zustand-store
description: "Trigger: crear store, nuevo store, estado global, zustand, store de. Convenciones para crear y decidir stores de Zustand en un stack React + Vite + TypeScript."
license: Apache-2.0
metadata:
  author: ignadev
  version: "1.0.0"
  scope:
    - example
  auto_invoke:
    - "crear store"
    - "nuevo store"
    - "estado global"
    - "zustand"
  owner: repo-maintainers
  skill_type: encoded_preference
  risk_level: low
  allowed_tools:
    - read
    - write
    - edit
    - glob
    - grep
---

# zustand-store

## Activation Contract

Usar cuando se crea o modifica un store de Zustand, o cuando hay que decidir si un estado vive en `useState`, en un store de feature o en `core/`.

No usar para formularios locales, estado derivado o estado que solo consume un componente. Eso no necesita una fuente de verdad global.

## Hard Rules

1. **Un store por dominio**: no mezclar responsabilidades distintas en un store global unico.
2. **Named export obligatorio**: nunca `export default`.
3. **Interface TypeScript unica** para estado y acciones.
4. **Acciones dentro del `create`**: no funciones sueltas que mutan con `setState`.
5. **Componentes con selectores**: `useStore(state => state.items)`, no `useStore()` entero.
6. **API en `src/features/<feature>/api/`**: el store consume el API; el componente consume el store.
7. **Store publico solo via barrel**: otras capas consumen `@/features/<nombre>`, no el archivo interno del store.

## Decision Gates

| Situacion | Decision |
| --- | --- |
| Lo usa un solo componente | `useState` local |
| Es estado derivado | variable calculada, no store |
| Es formulario | estado local o libreria de forms, no Zustand |
| Dos o mas componentes/paginas comparten lectura/escritura | store de feature |
| Es infraestructura agnostica (errores, theme, toast queue) | store en `src/core/<area>/` |
| Async con feedback al usuario | accion con resultado tipado, `try/catch/finally` y loading |
| Error de infraestructura (red, 500, inesperado) | reportar a un store global de errores (ver `error-handling`) |

## Execution Steps

1. Ubicar el store en `src/features/<feature>/stores/use<Feature>Store.ts` o `src/core/<area>/use<Name>Store.ts`.
2. Definir la interface con estado, flags (`isLoading`, `error`) y acciones.
3. Para acciones sync, mutar con `set(state => ...)` dentro del store.
4. Para acciones async, usar `try/catch/finally`, activar/desactivar loading y devolver un resultado tipado cuando la UI necesite feedback.
5. Separar errores esperables de dominio de errores infra; solo los infra van al canal global.
6. Agregar test co-localizado en `__tests__/` y exportar desde `index.ts` si el store es publico.

```ts
type ActionResult<T = void> =
	| { ok: true; data: T }
	| { ok: true }
	| { ok: false; error: string; kind?: 'validation' | 'domain' | 'infra' };

interface ItemsState {
	items: Item[];
	isLoading: boolean;
	error: string | null;
	load: () => Promise<ActionResult<Item[]>>;
}
```

```ts
import { useGlobalErrorStore } from '@/core/feedback/useGlobalErrorStore';
import { create } from 'zustand';

import { fetchItems } from '../api/items.api';

export const useItemsStore = create<ItemsState>()(set => ({
	items: [],
	isLoading: false,
	error: null,
	load: async () => {
		set({ isLoading: true, error: null });

		try {
			const items = await fetchItems();
			set({ items });
			return { ok: true, data: items };
		} catch (err) {
			const message = err instanceof Error ? err.message : 'Error inesperado';
			set({ error: message });
			useGlobalErrorStore.getState().reportError({ message, source: 'api' });
			return { ok: false, error: message, kind: 'infra' };
		} finally {
			set({ isLoading: false });
		}
	},
}));
```

## Output Contract

Al cerrar una tarea con stores, reportar: ubicacion del store, decision local/global, contrato de acciones async, manejo de errores y tests agregados o actualizados.

## References

- `Skills/examples/react-vite-ts/error-handling/SKILL.md` — contrato de errores locales/globales y `ActionResult`.
- `Skills/examples/react-vite-ts/testing/SKILL.md` — tests de stores, async y reset de estado.
- `Skills/examples/react-vite-ts/README.md` — origen y alcance de estos ejemplos.
