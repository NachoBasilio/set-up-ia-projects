#!/usr/bin/env bash
#
# Adaptador de referencia: search_docs
# Contrato: docs/deterministic-adapters.md
#
# Implementacion minima para ESTE repo: busca con `rg` sobre los archivos
# *.md de la raiz del repositorio. Los proyectos que adopten este framework
# deben reemplazar este script por su adaptador real (indice, API interna,
# etc.); el contrato es lo obligatorio, no esta implementacion.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/adapters/lib.sh
source "$SCRIPT_DIR/lib.sh"

ROOT_DIR="${ADAPTERS_ROOT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"

FORMAT="json"
QUERY=""
MAX_RESULTS=20

print_help() {
  cat <<'EOF'
Uso: search_docs.sh --query <texto> [--format json] [--max-results <n>]

Busca <texto> con `rg` sobre los archivos *.md de la raiz del repositorio y
devuelve resultados en JSON por stdout (contrato: docs/deterministic-adapters.md).
El diagnostico legible para humanos va por stderr.

Opciones:
  --query <texto>      Texto a buscar (obligatorio).
  --format json        Formato de salida (solo 'json', default).
  --max-results <n>    Maximo de resultados a devolver (default: 20).
  --help               Muestra esta ayuda y termina.

Codigos de salida: 0 ok, 1 resultado invalido, 2 uso invalido,
3 adaptador bloqueado (falta rg), 4 error de infraestructura.
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
    --query)
      if [[ $# -lt 2 ]]; then
        log_error "Falta valor para --query"
        exit 2
      fi
      QUERY="$2"
      shift 2
      ;;
    --max-results)
      if [[ $# -lt 2 ]]; then
        log_error "Falta valor para --max-results"
        exit 2
      fi
      MAX_RESULTS="$2"
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

if [[ -z "$QUERY" ]]; then
  log_error "--query es obligatorio"
  exit 2
fi

if ! [[ "$MAX_RESULTS" =~ ^[0-9]+$ ]] || [[ "$MAX_RESULTS" -lt 1 ]]; then
  log_error "--max-results debe ser un entero positivo"
  exit 2
fi

if ! command -v rg >/dev/null 2>&1; then
  log_error "rg (ripgrep) no esta disponible"
  printf '{"status": "blocked", "adapter": "search_docs", "adapter_version": "%s", "items": [], "errors": [{"code": "DEPENDENCY_MISSING", "message": "rg (ripgrep) no esta disponible"}], "warnings": [], "truncated": false, "reproducible": true, "metadata": {"root": "%s"}}\n' \
    "$ADAPTER_VERSION" "$(json_escape "$ROOT_DIR")"
  exit 3
fi

log_info "Buscando '$QUERY' en *.md bajo $ROOT_DIR"

set +e
matches="$(cd "$ROOT_DIR" && rg -n --no-heading --glob '*.md' -- "$QUERY" .)"
rg_status=$?
set -e

if [[ "$rg_status" -gt 1 ]]; then
  log_error "rg finalizo con codigo $rg_status"
  printf '{"status": "error", "adapter": "search_docs", "adapter_version": "%s", "items": [], "errors": [{"code": "SEARCH_FAILED", "message": "rg finalizo con codigo %s"}], "warnings": [], "truncated": false, "reproducible": true, "metadata": {"root": "%s"}}\n' \
    "$ADAPTER_VERSION" "$rg_status" "$(json_escape "$ROOT_DIR")"
  exit 4
fi

total=0
truncated="false"
items_json=""

if [[ -n "$matches" ]]; then
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    total=$((total + 1))
    if [[ "$total" -gt "$MAX_RESULTS" ]]; then
      truncated="true"
      break
    fi

    rest="$line"
    path="${rest%%:*}"
    rest="${rest#*:}"
    lineno="${rest%%:*}"
    content="${rest#*:}"
    path="${path#./}"

    snippet="$content"
    shopt -s extglob
    snippet="${snippet##+([[:space:]])}"
    shopt -u extglob
    if [[ "${#snippet}" -gt 200 ]]; then
      snippet="${snippet:0:200}"
    fi

    item="{\"path\": \"$(json_escape "$path")\", \"line\": $lineno, \"snippet\": \"$(json_escape "$snippet")\"}"
    if [[ -z "$items_json" ]]; then
      items_json="$item"
    else
      items_json="$items_json, $item"
    fi
  done <<< "$matches"
fi

printf '{"status": "ok", "adapter": "search_docs", "adapter_version": "%s", "items": [%s], "errors": [], "warnings": [], "truncated": %s, "reproducible": true, "metadata": {"root": "%s", "query": "%s", "max_results": %s}}\n' \
  "$ADAPTER_VERSION" "$items_json" "$truncated" "$(json_escape "$ROOT_DIR")" "$(json_escape "$QUERY")" "$MAX_RESULTS"
