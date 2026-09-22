#!/usr/bin/env bash
#
# Adaptador de referencia: validate
# Contrato: docs/deterministic-adapters.md
#
# Implementacion minima para ESTE repo: corre scripts/validate-skills.sh
# (modo completo) y un chequeo de links relativos de Markdown. Los proyectos
# que adopten este framework deben reemplazar este script por su adaptador
# real; el contrato es lo obligatorio, no esta implementacion.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/adapters/lib.sh
source "$SCRIPT_DIR/lib.sh"

ROOT_DIR="${ADAPTERS_ROOT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
VALIDATOR_SCRIPT="${SKILLS_VALIDATOR:-$SCRIPT_DIR/../validate-skills.sh}"

FORMAT="json"
INPUT=""
ATTEMPT=1

print_help() {
  cat <<'EOF'
Uso: validate.sh [--input <path>] [--attempt <n>] [--format json]

Corre scripts/validate-skills.sh (modo completo, sin --dry-run) y un chequeo
de links relativos de Markdown sobre <path> (default: raiz del repo). Salida
JSON por stdout (contrato: docs/deterministic-adapters.md). El diagnostico
legible para humanos va por stderr.

Opciones:
  --input <path>    Directorio a validar (default: raiz del repo).
  --attempt <n>     Numero de intento de REPAIR, solo informativo (default: 1).
  --format json     Formato de salida (solo 'json', default).
  --help            Muestra esta ayuda y termina.

Codigos de salida: 0 ok, 1 invalido (hay errores), 2 uso invalido,
3 adaptador bloqueado, 4 error de infraestructura.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      print_help
      exit 0
      ;;
    --format)
      if [[ $# -lt 2 ]]; then
        log_error "Falta valor para --format"
        exit 2
      fi
      FORMAT="$2"
      shift 2
      ;;
    --input)
      if [[ $# -lt 2 ]]; then
        log_error "Falta valor para --input"
        exit 2
      fi
      INPUT="$2"
      shift 2
      ;;
    --attempt)
      if [[ $# -lt 2 ]]; then
        log_error "Falta valor para --attempt"
        exit 2
      fi
      ATTEMPT="$2"
      shift 2
      ;;
    *)
      log_error "Flag desconocida: $1"
      exit 2
      ;;
  esac
done

if [[ "$FORMAT" != "json" ]]; then
  log_error "Formato no soportado: '$FORMAT' (solo 'json')"
  exit 2
fi

if ! [[ "$ATTEMPT" =~ ^[0-9]+$ ]] || [[ "$ATTEMPT" -lt 1 ]]; then
  log_error "--attempt debe ser un entero positivo"
  exit 2
fi

if [[ -z "$INPUT" ]]; then
  INPUT="$ROOT_DIR"
fi

if [[ ! -d "$INPUT" ]]; then
  log_error "--input no es un directorio: $INPUT"
  exit 2
fi

INPUT="$(cd "$INPUT" && pwd)"

errors_json=""
error_count=0

add_error() {
  local code="$1" message="$2" path="${3:-}"
  local obj
  obj="{\"code\": \"$(json_escape "$code")\", \"message\": \"$(json_escape "$message")\""
  if [[ -n "$path" ]]; then
    obj="$obj, \"path\": \"$(json_escape "$path")\""
  fi
  obj="$obj}"
  if [[ -z "$errors_json" ]]; then
    errors_json="$obj"
  else
    errors_json="$errors_json, $obj"
  fi
  error_count=$((error_count + 1))
}

# 1) scripts/validate-skills.sh en modo completo (no --dry-run)
log_info "Ejecutando scripts/validate-skills.sh sobre $INPUT"
skills_status=0
skills_validator_exit_json="0"; dependency_missing=0
if [[ -x "$VALIDATOR_SCRIPT" ]]; then
  set +e
  skills_output="$(VALIDATE_SKILLS_ROOT_DIR="$INPUT" "$VALIDATOR_SCRIPT")"
  skills_status=$?
  set -e
  skills_validator_exit_json="$skills_status"
  if [[ "$skills_status" -ne 0 ]]; then
    log_error "scripts/validate-skills.sh fallo (exit $skills_status):"
    printf '%s\n' "$skills_output" >&2
    add_error "SKILLS_VALIDATION_FAILED" "scripts/validate-skills.sh reporto errores (exit $skills_status); ver stderr"
  fi
else
  log_error "No se encontro scripts/validate-skills.sh en $VALIDATOR_SCRIPT"
  add_error "DEPENDENCY_MISSING" "scripts/validate-skills.sh no esta disponible" "$VALIDATOR_SCRIPT"
  dependency_missing=1; skills_validator_exit_json="null"
fi

# 2) chequeo de links relativos de Markdown ([texto](ruta/relativa.md#ancla))
log_info "Revisando links relativos de Markdown en $INPUT"

LINK_REGEX='\[[^]]*\]\(([^)]+)\)'

extract_links_from_line() {
  local line="$1"
  local remaining="$line"
  while [[ "$remaining" =~ $LINK_REGEX ]]; do
    printf '%s\n' "${BASH_REMATCH[1]}"
    remaining="${remaining#*"${BASH_REMATCH[0]}"}"
  done
}

while IFS= read -r md_file; do
  [[ -z "$md_file" ]] && continue
  file_dir="$(dirname "$md_file")"
  line_num=0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line_num=$((line_num + 1))
    while IFS= read -r link; do
      [[ -z "$link" ]] && continue
      case "$link" in
        http://*|https://*|mailto:*|'#'*)
          continue
          ;;
      esac
      target="${link%%#*}"
      [[ -z "$target" ]] && continue
      case "$target" in
        *.md) ;;
        *) continue ;;
      esac
      resolved="$file_dir/$target"
      if [[ ! -f "$resolved" ]]; then
        rel_file="${md_file#"$INPUT"/}"
        add_error "LINK_TARGET_MISSING" "Link roto a '$target'" "$rel_file:$line_num"
      fi
    done < <(extract_links_from_line "$line")
  done < "$md_file"
done < <(find "$INPUT" \
  \( -type d \( -name .git -o -name node_modules -o -name vendor -o -name dist -o -name build -o -name .atl \) -prune \) -o \
  \( -type f -name '*.md' -print \) | sort)

status="ok"
exit_code=0
if [[ "$dependency_missing" -eq 1 ]]; then
  status="blocked"; exit_code=3
elif [[ "$error_count" -gt 0 ]]; then
  status="invalid"
  exit_code=1
fi

printf '{"status": "%s", "adapter": "validate", "adapter_version": "%s", "items": [], "errors": [%s], "warnings": [], "truncated": false, "reproducible": true, "metadata": {"input": "%s", "repair_attempt": %s, "skills_validator_exit": %s}}\n' \
  "$status" "$ADAPTER_VERSION" "$errors_json" "$(json_escape "$INPUT")" "$ATTEMPT" "$skills_validator_exit_json"

exit "$exit_code"
