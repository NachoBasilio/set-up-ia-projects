---
name: react-component
description: "Trigger: crear componente, nuevo componente, modificar componente, componente react, pagina nueva. Convenciones para estructurar componentes React en un stack Vite + TypeScript con capas core/features/app."
license: Apache-2.0
metadata:
  author: ignadev
  version: "1.0.0"
  scope:
    - example
  auto_invoke:
    - "crear componente"
    - "nuevo componente"
    - "modificar componente"
    - "componente react"
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

# react-component

## Activation Contract

Usar al crear o modificar componentes, paginas o estructura `.tsx` en un proyecto React + Vite + TypeScript con capas `core/features/app`. Tambien aplica al revisar separacion entre componente presentacional, pagina, form y feature.

No usar para stores (`zustand-store`) ni tests (`testing`), salvo para coordinar la ubicacion esperada.

## Hard Rules

1. **Named export obligatorio**: nunca `export default`.
2. **Un componente por archivo**: archivo y componente comparten nombre.
3. **Carpeta PascalCase por componente** con `<Nombre>.tsx`, `style.css` y `__tests__/`.
4. **Props con `interface`**, sin `any` ni tipos inline improvisados.
5. **Sin logica de negocio en presentacionales**: API, stores y derivados complejos viven en pagina, store o hook.
6. **`style.css` por componente**: sin estilos inline; tokens desde un archivo central de design tokens.
7. **Mobile first obligatorio**: base funcional desde 320px; desktop escala con `min-width`.
8. **Strings repetidos o de dominio en `copy.ts`** cuando necesitan consistencia entre pagina, form y tests.
9. **Imports correctos**: relativos dentro del feature, absolutos hacia `core/`, otros features solo por barrel publico.

## Decision Gates

| Que estas creando | Donde va |
| --- | --- |
| UI base sin dominio (`Button`, `Modal`, `Card`) | `src/core/ui/<Nombre>/` |
| Componente con dominio (`ItemCard`, `OrderRow`) | `src/features/<feature>/components/<Nombre>/` |
| Form de un flujo del feature | `src/features/<feature>/components/<Nombre>Form/` si se reutiliza; dentro de la page si es unico |
| Page de un feature | `src/features/<feature>/pages/<Nombre>/` |
| Page local sin feature dedicado (`Home`, `NotFound`) | `src/app/pages/<Nombre>/` |
| Copy compartida del feature | `src/features/<feature>/copy.ts` |
| Necesita API/store/reglas de negocio | no va en `core/ui/` |

## Execution Steps

1. Decidir capa y carpeta antes de crear archivos.
2. Crear carpeta PascalCase con componente, `style.css` y test co-localizado.
3. Mantener JSX directo en la page hasta que haya reutilizacion real; no extraer componentes "por si acaso".
4. Mover strings repetidos o de dominio a `copy.ts` del feature.
5. Escribir CSS mobile-first: 320px sin overflow horizontal, luego `@media (min-width: ...)`.
6. Validar accesibilidad: roles semanticos, labels visibles o `aria-label`, foco usable y feedback con `role="alert"` cuando aplique.
7. Agregar o ajustar tests con Testing Library.

```tsx
interface Props {
	title: string;
	value: number;
	imageUrl?: string;
}

export function ItemCard({ title, value, imageUrl }: Props) {
	return <article aria-label={title}>{/* ... */}</article>;
}
```

## Output Contract

Al cerrar una tarea de componente, reportar: archivos creados/modificados, capa elegida, decision de copy, accesibilidad relevante, revision mobile-first y tests.

## References

- `AGENTS.md` del proyecto objetivo — arquitectura, named exports y mobile-first.
- `Skills/examples/react-vite-ts/testing/SKILL.md` — ubicacion y estilo de tests.
- `Skills/examples/react-vite-ts/README.md` — origen y alcance de estos ejemplos.
