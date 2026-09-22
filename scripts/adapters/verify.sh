#!/usr/bin/env bash
#
# Adaptador de referencia: verify
# Contrato: docs/deterministic-adapters.md
#
# Implementacion minima para ESTE repo: vuelve a correr validate.sh de forma
# independiente y agrega evidencia de `git diff --stat` y `git status
# --porcelain`. Los proyectos que adopten este framework deben reemplazar
# este script por su adaptador real; el contrato es lo obligatorio, no esta
# implementacion.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/adapters/lib.sh
source "$SCRIPT_DIR/lib.sh"

ROOT_DIR="${ADAPTERS_ROOT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
VALIDATE_SCRIPT="$SCRIPT_DIR/validate.sh"

FORMAT="json"
INPUT=""

print_help() {
  cat <<'EOF'
Uso: verify.sh [--input <path>] [--format json]

Vuelve a correr validate.sh sobre <path> (default: raiz del repo) de forma
independiente y agrega `git diff --stat` y `git status --porcelain` como
evidencia final. Salida JSON por stdout (contrato:
docs/deterministic-adapters.md). El diagnostico legible para humanos va por
stderr.

Opciones:
  --input <path>   Directorio a verificar (default: raiz del repo).
  --format json    Formato de salida (solo 'json', default).
  --help           Muestra esta ayuda y termina.

Codigos de salida: 0 ok, 1 invalido (validate.sh fallo), 2 uso invalido,
3 adaptador bloqueado (falta git), 4 error de infraestructura.
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

if [[ -z "$INPUT" ]]; then
  INPUT="$ROOT_DIR"
fi

if [[ ! -d "$INPUT" ]]; then
  log_error "--input no es un directorio: $INPUT"
  exit 2
fi

INPUT="$(cd "$INPUT" && pwd)"

if ! command -v git >/dev/null 2>&1; then
  log_error "git no esta disponible"
  printf '{"status": "blocked", "adapter": "verify", "adapter_version": "%s", "items": [], "errors": [{"code": "DEPENDENCY_MISSING", "message": "git no esta disponible"}], "warnings": [], "truncated": false, "reproducible": true, "metadata": {"input": "%s", "git_evidence": "unavailable"}}\n' \
    "$ADAPTER_VERSION" "$(json_escape "$INPUT")"
  exit 3
fi

log_info "Re-ejecutando validate.sh de forma independiente sobre $INPUT"

set +e
validate_output="$("$VALIDATE_SCRIPT" --input "$INPUT")"
validate_status=$?
worktree_out="$(git -C "$INPUT" rev-parse --is-inside-work-tree 2>&1)"; worktree_rc=$?
diff_stat="$(git -C "$INPUT" diff --stat 2>&1)"; diff_rc=$?
changed_files_raw="$(git -C "$INPUT" status --porcelain 2>&1)"; status_rc=$?
set -e

git_evidence="collected"; git_error=""
if [[ "$worktree_rc" -ne 0 || "$diff_rc" -ne 0 || "$status_rc" -ne 0 ]]; then
  git_evidence="unavailable"; git_error="$worktree_out"; [[ "$worktree_rc" -eq 0 ]] && git_error=""
  [[ -z "$git_error" && "$diff_rc" -ne 0 ]] && git_error="$diff_stat"
  [[ -z "$git_error" && "$status_rc" -ne 0 ]] && git_error="$changed_files_raw"
  diff_stat=""; changed_files_raw=""
fi

changed_files_json=""
if [[ -n "$changed_files_raw" ]]; then
  while IFS= read -r cf_line; do
    [[ -z "$cf_line" ]] && continue
    cf_path="${cf_line:3}"
    entry="\"$(json_escape "$cf_path")\""
    if [[ -z "$changed_files_json" ]]; then
      changed_files_json="$entry"
    else
      changed_files_json="$changed_files_json, $entry"
    fi
  done <<< "$changed_files_raw"
fi

adapter_failure=0; [[ "$validate_status" -eq 2 || "$validate_status" -eq 4 || -z "$validate_output" ]] && adapter_failure=1
validate_result_json="null"; warnings_json=""
if [[ -n "$validate_output" && "${validate_output:0:1}" == "{" ]]; then
  validate_result_json="$validate_output"
elif [[ "$adapter_failure" -eq 0 ]]; then
  warnings_json="{\"code\": \"VALIDATE_OUTPUT_NOT_JSON\", \"message\": \"validate.sh no produjo JSON valido por stdout\"}"
fi
status="ok"; exit_code=0; errors_json=""
if [[ "$adapter_failure" -eq 1 ]]; then
  status="error"; exit_code=4
  errors_json="{\"code\": \"VALIDATE_ADAPTER_FAILURE\", \"message\": \"$(json_escape "validate.sh fallo (exit $validate_status) sin salida utilizable")\"}"
elif [[ "$git_evidence" == "unavailable" ]]; then
  status="blocked"; exit_code=3
  errors_json="{\"code\": \"GIT_EVIDENCE_UNAVAILABLE\", \"message\": \"$(json_escape "$git_error")\"}"
elif [[ "$validate_status" -ne 0 ]]; then
  status="invalid"; exit_code=1
  errors_json="{\"code\": \"VALIDATE_FAILED\", \"message\": \"validate.sh reporto errores (exit $validate_status)\", \"hint\": \"Ver validate_result en metadata\"}"
fi

printf '{"status": "%s", "adapter": "verify", "adapter_version": "%s", "items": [], "errors": [%s], "warnings": [%s], "truncated": false, "reproducible": true, "metadata": {"input": "%s", "validate_exit_code": %s, "validate_result": %s, "git_evidence": "%s", "git_diff_stat": "%s", "changed_files": [%s]}}\n' \
  "$status" "$ADAPTER_VERSION" "$errors_json" "$warnings_json" "$(json_escape "$INPUT")" "$validate_status" "$validate_result_json" "$git_evidence" "$(json_escape "$diff_stat")" "$changed_files_json"

exit "$exit_code"
