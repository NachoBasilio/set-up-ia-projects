#!/usr/bin/env bash
#
# Tests para los adaptadores de referencia en scripts/adapters/*.sh.
# Contrato validado: docs/deterministic-adapters.md

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADAPTERS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/scripts/adapters"
SEARCH_DOCS_SCRIPT="$ADAPTERS_DIR/search_docs.sh"
VALIDATE_SCRIPT="$ADAPTERS_DIR/validate.sh"
VERIFY_SCRIPT="$ADAPTERS_DIR/verify.sh"

TESTS_RUN=0
TESTS_FAILED=0

assert_contains() {
  local file="$1"
  local expected="$2"
  if ! grep -Fq "$expected" "$file"; then
    printf '[FAIL] No se encontro texto esperado: %s\n' "$expected"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_not_contains() {
  local file="$1"
  local expected="$2"
  if grep -Fq "$expected" "$file"; then
    printf '[FAIL] Se encontro texto inesperado: %s\n' "$expected"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_status() {
  local actual="$1"
  local expected="$2"
  if [[ "$actual" -ne "$expected" ]]; then
    printf '[FAIL] Status esperado=%s actual=%s\n' "$expected" "$actual"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

assert_json_valid() {
  local file="$1"
  if command -v python3 >/dev/null 2>&1; then
    python3 -c 'import json,sys; json.load(sys.stdin)' < "$file" >/dev/null 2>&1 || { printf '[FAIL] JSON invalido en %s\n' "$file"; TESTS_FAILED=$((TESTS_FAILED + 1)); }
  elif command -v node >/dev/null 2>&1; then
    node -e 'JSON.parse(require("fs").readFileSync(0,"utf8"))' < "$file" >/dev/null 2>&1 || { printf '[FAIL] JSON invalido en %s\n' "$file"; TESTS_FAILED=$((TESTS_FAILED + 1)); }
  else
    printf '[WARN] Sin python3 ni node: se omite validacion JSON de %s\n' "$file" >&2
  fi
}

run_script() {
  local script="$1"
  local output_file="$2"
  shift 2

  set +e
  "$script" "$@" > "$output_file" 2>"$output_file.stderr"
  local status=$?
  set -e

  printf '%s' "$status"
}

# Fixture minima y valida: repo con AGENTS/README/START-UP/MIGRACION, una
# skill moderna valida y un redirect legacy. Sin links relativos rotos.
create_valid_repo() {
  local repo_dir="$1"

  mkdir -p "$repo_dir/Skills/skill-uno"

  cat > "$repo_dir/AGENTS.md" <<'EOF'
# AGENTS

Ver [README](README.md) y [START-UP](START-UP.md).
EOF

  cat > "$repo_dir/README.md" <<'EOF'
# README

capability_uplift
encoded_preference

Ver [AGENTS](AGENTS.md).
EOF

  cat > "$repo_dir/START-UP.md" <<'EOF'
# START-UP
EOF

  cat > "$repo_dir/MIGRACION.md" <<'EOF'
# MIGRACION
EOF

  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<'EOF'
---
name: skill-uno
description: skill uno de prueba con contenido unico PalabraUnica12345
license: Apache-2.0
metadata:
  author: qa
  version: "1.0.0"
  scope:
    - root
  auto_invoke:
    - "run uno"
  owner: core
  skill_type: encoded_preference
  risk_level: low
  allowed_tools: []
---

# skill uno
EOF
}

create_git_fixture() {
  local repo_dir="$1"
  git -C "$repo_dir" -c init.defaultBranch=main init -q
  git -C "$repo_dir" -c user.email=test@example.com -c user.name=test add -A
  git -C "$repo_dir" -c user.email=test@example.com -c user.name=test -c commit.gpgsign=false commit -q -m fixture
}

# --- search_docs.sh ---

test_search_docs_help() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local out
  out="$(mktemp -d)/out.log"
  local status
  status="$(run_script "$SEARCH_DOCS_SCRIPT" "$out" --help)"
  assert_status "$status" 0
  assert_contains "$out" 'Uso: search_docs.sh'
}

test_search_docs_unknown_flag() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local out
  out="$(mktemp -d)/out.log"
  local status
  status="$(run_script "$SEARCH_DOCS_SCRIPT" "$out" --nope)"
  assert_status "$status" 2
}

test_search_docs_valid_run() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  create_valid_repo "$repo_dir"
  local out="$repo_dir/out.log"

  local status
  status="$(ADAPTERS_ROOT_DIR="$repo_dir" run_script "$SEARCH_DOCS_SCRIPT" "$out" --query PalabraUnica12345)"

  assert_status "$status" 0
  assert_contains "$out" '"adapter": "search_docs"'
  assert_contains "$out" '"status": "ok"'
  assert_contains "$out" 'PalabraUnica12345'
  assert_json_valid "$out"

  rm -rf "$repo_dir"
}

test_search_docs_no_matches() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  create_valid_repo "$repo_dir"
  local out="$repo_dir/out.log"

  local status
  status="$(ADAPTERS_ROOT_DIR="$repo_dir" run_script "$SEARCH_DOCS_SCRIPT" "$out" --query NoExisteEstoEnNingunLado999)"

  assert_status "$status" 0
  assert_contains "$out" '"items": []'

  rm -rf "$repo_dir"
}

test_search_docs_control_byte_in_content() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir; repo_dir="$(mktemp -d)"
  create_valid_repo "$repo_dir"
  printf 'ControlByteMarker9988\x01fin\n' > "$repo_dir/control.md"
  local out="$repo_dir/out.log"
  local status; status="$(ADAPTERS_ROOT_DIR="$repo_dir" run_script "$SEARCH_DOCS_SCRIPT" "$out" --query ControlByteMarker9988)"
  assert_status "$status" 0
  assert_json_valid "$out"
  rm -rf "$repo_dir"
}

# --- validate.sh ---

test_validate_help() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local out
  out="$(mktemp -d)/out.log"
  local status
  status="$(run_script "$VALIDATE_SCRIPT" "$out" --help)"
  assert_status "$status" 0
  assert_contains "$out" 'Uso: validate.sh'
}

test_validate_unknown_flag() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local out
  out="$(mktemp -d)/out.log"
  local status
  status="$(run_script "$VALIDATE_SCRIPT" "$out" --nope)"
  assert_status "$status" 2
}

test_validate_valid_run() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  create_valid_repo "$repo_dir"
  local out="$repo_dir/out.log"

  local status
  status="$(run_script "$VALIDATE_SCRIPT" "$out" --input "$repo_dir")"

  assert_status "$status" 0
  assert_contains "$out" '"adapter": "validate"'
  assert_contains "$out" '"status": "ok"'
  assert_json_valid "$out"

  rm -rf "$repo_dir"
}

test_validate_dead_link() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  mkdir -p "$repo_dir"

  cat > "$repo_dir/broken.md" <<'EOF'
# Broken

[enlace roto](missing/target.md)
EOF

  local out="$repo_dir/out.log"
  local status
  status="$(run_script "$VALIDATE_SCRIPT" "$out" --input "$repo_dir")"

  assert_status "$status" 1
  assert_contains "$out" 'LINK_TARGET_MISSING'
  assert_json_valid "$out"

  rm -rf "$repo_dir"
}

test_validate_skills_validation_failed() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir; repo_dir="$(mktemp -d)"
  mkdir -p "$repo_dir/Skills/bad-skill"
  printf 'frontmatter invalido sin ---\n' > "$repo_dir/Skills/bad-skill/SKILL.md"
  local out="$repo_dir/out.log"
  local status; status="$(run_script "$VALIDATE_SCRIPT" "$out" --input "$repo_dir")"
  assert_status "$status" 1
  assert_contains "$out" '"status": "invalid"'
  assert_contains "$out" 'SKILLS_VALIDATION_FAILED'
  assert_not_contains "$out" '"skills_validator_exit": 0'
  rm -rf "$repo_dir"
}

test_validate_skills_validator_missing() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir; repo_dir="$(mktemp -d)"
  local out="$repo_dir/out.log"
  local status; status="$(SKILLS_VALIDATOR="$repo_dir/nope.sh" run_script "$VALIDATE_SCRIPT" "$out" --input "$repo_dir")"
  assert_status "$status" 3
  assert_contains "$out" '"status": "blocked"'
  assert_contains "$out" 'DEPENDENCY_MISSING'
  assert_contains "$out" '"skills_validator_exit": null'
  rm -rf "$repo_dir"
}

# --- verify.sh ---

test_verify_help() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local out
  out="$(mktemp -d)/out.log"
  local status
  status="$(run_script "$VERIFY_SCRIPT" "$out" --help)"
  assert_status "$status" 0
  assert_contains "$out" 'Uso: verify.sh'
}

test_verify_unknown_flag() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local out
  out="$(mktemp -d)/out.log"
  local status
  status="$(run_script "$VERIFY_SCRIPT" "$out" --nope)"
  assert_status "$status" 2
}

test_verify_valid_run() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  create_valid_repo "$repo_dir"
  local out="$repo_dir/out.log"

  local status
  status="$(run_script "$VERIFY_SCRIPT" "$out" --input "$repo_dir")"

  assert_status "$status" 3
  assert_contains "$out" '"adapter": "verify"'
  assert_contains "$out" '"status": "blocked"'
  assert_contains "$out" 'GIT_EVIDENCE_UNAVAILABLE'
  assert_json_valid "$out"

  rm -rf "$repo_dir"
}

test_verify_git_evidence_collected() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir; repo_dir="$(mktemp -d)"
  create_valid_repo "$repo_dir"
  create_git_fixture "$repo_dir"
  local out="$repo_dir/out.log"
  local status; status="$(run_script "$VERIFY_SCRIPT" "$out" --input "$repo_dir")"
  assert_status "$status" 0
  assert_contains "$out" '"status": "ok"'
  assert_contains "$out" '"git_evidence": "collected"'
  rm -rf "$repo_dir"
}

test_verify_git_invalid_link() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir; repo_dir="$(mktemp -d)"
  printf '[roto](missing/target.md)\n' > "$repo_dir/broken.md"
  create_git_fixture "$repo_dir"
  local out="$repo_dir/out.log"
  local status; status="$(run_script "$VERIFY_SCRIPT" "$out" --input "$repo_dir")"
  assert_status "$status" 1
  assert_contains "$out" '"status": "invalid"'
  assert_contains "$out" 'VALIDATE_FAILED'
  assert_contains "$out" 'LINK_TARGET_MISSING'
  rm -rf "$repo_dir"
}

main() {
  test_search_docs_help
  test_search_docs_unknown_flag
  test_search_docs_valid_run
  test_search_docs_no_matches
  test_search_docs_control_byte_in_content
  test_validate_help
  test_validate_unknown_flag
  test_validate_valid_run
  test_validate_dead_link
  test_validate_skills_validation_failed
  test_validate_skills_validator_missing
  test_verify_help
  test_verify_unknown_flag
  test_verify_valid_run
  test_verify_git_evidence_collected
  test_verify_git_invalid_link

  if [[ "$TESTS_FAILED" -gt 0 ]]; then
    printf '\nResultado: %s test(s), %s fallo(s)\n' "$TESTS_RUN" "$TESTS_FAILED"
    exit 1
  fi

  printf 'Resultado: %s test(s), 0 fallo(s)\n' "$TESTS_RUN"
}

main "$@"
