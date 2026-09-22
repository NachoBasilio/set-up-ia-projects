# Protocolo de identificación del repositorio

Este es el contrato operativo del framework para evitar aplicar un flujo reutilizable al repositorio equivocado. Es independiente del proyecto, del stack y del proveedor Git.

## Preflight obligatorio

Antes de cualquier lectura, escritura o mutación:

1. Identifica la raíz canónica:
   ```bash
   git rev-parse --show-toplevel
   pwd
   git status --short --branch
   git remote -v
   git branch --show-current
   ```
2. Inspecciona el `AGENTS.md` y el `README.md` más cercanos a esa raíz. Si existen instrucciones en subdirectorios relevantes, léelas antes de tocar esos archivos.
3. Registra la evidencia: ruta absoluta, rama, estado, remotes y objetivo solicitado.

Si hay varios repositorios o worktrees plausibles, o el destino solicitado es ambiguo, **detente y pregunta**. Nunca infieras el destino solo por el `cwd` actual.

## Distinguir el tipo de trabajo

Separa explícitamente:

- **Trabajo del framework o flujo reusable**: cambia reglas, protocolos, plantillas, documentación o skills que deben poder aplicarse a muchos proyectos. El destino correcto es el repositorio que mantiene ese framework.
- **Trabajo específico de una aplicación**: cambia código, configuración, documentación de negocio o reglas propias de un producto. El destino correcto es el repositorio de esa aplicación.

La solicitud, el contenido que se va a cambiar y la identidad del repositorio deben coincidir. Si el cambio menciona un flujo reusable pero el repositorio contiene una aplicación concreta —o al revés—, pausa y confirma antes de continuar.

## Remotes y ramas

Antes de modificar un remote o una rama, compara la identidad esperada del repositorio con la salida observada de `git remote -v`, la raíz, el historial y las instrucciones cercanas. No ejecutes ciegamente:

```bash
git remote add origin <URL>
```

Si `origin` ya existe, inspecciónalo y decide si debe conservarse, corregirse o dejarse intacto. `<URL>` es un marcador de posición: reemplázalo solo con un destino confirmado; nunca uses una URL universal.

### Configuración segura de ramas

Suposición: el usuario autorizó preparar y publicar las ramas en el repositorio ya verificado, y `origin` apunta al destino confirmado.

```bash
# Evidencia previa: confirma <COMMIT_BASE> y el repositorio antes de ejecutar.
git switch -c main <COMMIT_BASE>
git switch -c dev main
git push -u origin main
git push -u origin dev
git ls-remote --heads origin main dev
git show-ref --verify refs/heads/main
git show-ref --verify refs/heads/dev
```

Si las ramas ya existen, no las recrees: compara sus commits y confirma la acción requerida. `main` debe ser la base y `dev` debe crearse desde exactamente el mismo commit cuando así se solicite. Verifica los refs locales y remotos después.

Los force pushes son excepcionales. Solo se permite `--force-with-lease` con autorización explícita y con el ref remoto esperado conocido y registrado. Nunca uses `--force` como atajo.

## Recuperación ante un cambio en el repositorio equivocado

1. **Detén** toda escritura, push y cambio adicional.
2. Conserva la evidencia sin sobrescribir trabajo:
   ```bash
   git status --short --branch
   git log --oneline --decorate -n 10
   git reflog --date=local -n 20
   git remote -v
   ```
3. Identifica qué rama, commit, remote y archivos fueron afectados.
4. Preserva el trabajo del usuario (`git diff`, `git diff --staged` o una copia/commit temporal acordado); no borres ni resetees cambios sin autorización.
5. Restaura la rama y el remote local solo con una referencia conocida y verificada. Si hace falta recuperar un ref remoto, usa el procedimiento aprobado y la autorización correspondiente.
6. Repite el preflight completo y repara **por separado** el repositorio intencionado. No mezcles la recuperación con el cambio correcto.

## Evidencia y condiciones de parada

El trabajo puede continuar solo cuando existe evidencia de:

- raíz canónica y `cwd` inspeccionados;
- repositorio, remote y rama comparados con el destino esperado;
- instrucciones `AGENTS.md`/`README.md` relevantes revisadas;
- tipo de trabajo clasificado como reusable o específico de aplicación;
- autorización explícita para cada mutación remota, de rama o force push;
- verificación posterior de estado y refs.

Detente y pregunta si falta cualquiera de esas evidencias, si hay más de un destino plausible, si `origin` no coincide, si la rama base es incierta, si aparecen cambios de usuario no explicados o si una operación destructiva sería necesaria.

## Referencia rápida

```bash
# Suposición: ya estás en el repositorio candidato y aún no modificaste nada.
ROOT="$(git rev-parse --show-toplevel)"
printf 'root=%s\npwd=%s\nbranch=%s\n' "$ROOT" "$PWD" "$(git branch --show-current)"
git status --short --branch
git remote -v
```

Estos comandos producen evidencia; no sustituyen la confirmación del destino ni autorizan mutaciones.
