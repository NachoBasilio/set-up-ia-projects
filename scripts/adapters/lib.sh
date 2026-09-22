#!/usr/bin/env bash
#
# Funciones compartidas por los adaptadores deterministas de referencia
# (scripts/adapters/search_docs.sh, validate.sh, verify.sh).
#
# Contrato: docs/deterministic-adapters.md
# Esta implementacion es minima y especifica de ESTE repo. Los proyectos
# que adopten este framework deben reemplazarla por su adaptador real; el
# contrato es lo obligatorio, no este script.

# shellcheck disable=SC2034  # consumed by the adapters that source this file
ADAPTER_VERSION="0.1.0"

log_info() {
  printf '[INFO] %s\n' "$1" >&2
}

log_warn() {
  printf '[WARN] %s\n' "$1" >&2
}

log_error() {
  printf '[ERROR] %s\n' "$1" >&2
}

# Escapa un string para insertarlo como valor JSON entre comillas dobles.
json_escape() {
  local s="$1"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\t'/\\t}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\n'/\\n}"
  if [[ "$s" == *[[:cntrl:]]* ]]; then
    local out="" i n ch code; n="${#s}"
    for (( i = 0; i < n; i++ )); do
      ch="${s:i:1}"
      [[ "$ch" == [[:cntrl:]] ]] && { printf -v code '%d' "'$ch"; printf -v ch '\\u%04x' "$code"; }
      out+="$ch"
    done
    s="$out"
  fi
  printf '%s' "$s"
}
