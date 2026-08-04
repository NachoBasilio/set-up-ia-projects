---
name: testing
description: "Trigger: crear test, escribir test, agregar tests, test de componente, cobertura. Convenciones para escribir o modificar tests con Vitest y Testing Library."
license: Apache-2.0
metadata:
  author: ignadev
  version: "1.0.0"
  scope:
    - example
  auto_invoke:
    - "crear test"
    - "escribir test"
    - "agregar tests"
    - "test de componente"
  owner: repo-maintainers
  skill_type: encoded_preference
  risk_level: low
  allowed_tools:
    - read
    - write
    - edit
    - glob
    - grep
    - bash
---

# testing

## Activation Contract

Usar al crear o modificar tests de componentes, paginas, stores o API de feature con Vitest + Testing Library.

No usar para configurar Vitest desde cero; eso vive en la configuracion del bundler y el setup global de tests.

## Hard Rules

1. **Tests co-localizados** en `__tests__/` del modulo testeado.
2. **Queries semanticas primero**: `getByRole` / `findByRole` > `getByLabelText` > `getByPlaceholderText` > `getByText` > `getByTestId`.
3. **Testear comportamiento, no implementacion**.
4. **Un `describe` por modulo y un `it` por comportamiento**; el `it` completa "deberia...".
5. **Contexto explicito**: usar `MemoryRouter`, providers o estado inicial cuando el componente lo necesita.
6. **Sin `beforeEach` magico**: si el setup crece, extraer `renderX()` local.
7. **Flujos async con exito, loading y error**: no alcanza con probar el render inicial.
8. **Stores Zustand reseteados entre tests** para evitar estado compartido.

## Decision Gates

| Situacion | Patron |
| --- | --- |
| Interaccion de usuario | `const user = userEvent.setup()` y `await user.click/type(...)` |
| UI aparece despues de async | `await screen.findByRole(...)` |
| Esperar side-effect no renderizado inmediatamente | `await waitFor(() => expect(...))` |
| Componente usa routing | render con `MemoryRouter` |
| Store de feature cambia estado | resetear store antes/despues del test |
| Async con error local | verificar mensaje visible y `role="alert"` |
| Error infra reportado | verificar el store global de errores y que validaciones no reporten global |

## Execution Steps

1. Ubicar el test junto al modulo: `components/<Name>/__tests__`, `pages/<Name>/__tests__`, `stores/__tests__` o `api/__tests__`.
2. Preparar render/helper local solo con el contexto necesario.
3. Mockear APIs del feature con `vi.spyOn` sobre imports relativos.
4. Para async, cubrir success, loading y error; usar `findByRole` o `waitFor` segun el sintoma observable.
5. En stores, resetear estado entre tests con `useStore.setState(initialState, true)` o helper equivalente del propio modulo.
6. Si el flujo reporta infra al global, limpiar/verificar el store global de errores.
7. Ejecutar el comando de test del proyecto antes de cerrar; sumar el linter si el cambio acompaña codigo productivo.

```tsx
it('deberia mostrar error cuando falla la carga', async () => {
	const user = userEvent.setup();
	vi.spyOn(itemsApi, 'fetchItems').mockRejectedValueOnce(new Error('Red caida'));

	render(<ItemListPage />);
	await user.click(screen.getByRole('button', { name: /cargar/i }));

	expect(await screen.findByRole('alert')).toHaveTextContent(/red caida/i);
});
```

## Output Contract

Al cerrar una tarea de tests, reportar: archivos testeados, casos cubiertos, mocks relevantes, si hubo reset de Zustand/global error store y comando ejecutado.

## References

- `Skills/examples/react-vite-ts/react-component/SKILL.md` — estructura esperada de componentes.
- `Skills/examples/react-vite-ts/zustand-store/SKILL.md` — contratos de stores y acciones async.
- `Skills/examples/react-vite-ts/error-handling/SKILL.md` — separacion error local/global.
- `Skills/examples/react-vite-ts/README.md` — origen y alcance de estos ejemplos.
