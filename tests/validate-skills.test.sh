#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VALIDATOR_SCRIPT="$(cd "$SCRIPT_DIR/.." && pwd)/scripts/validate-skills.sh"

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

create_base_repo() {
  local repo_dir="$1"

  mkdir -p "$repo_dir/Skills/skill-uno" "$repo_dir/Skills/skill-dos"

  cat > "$repo_dir/AGENTS.md" <<'EOF'
# AGENTS
EOF

  cat > "$repo_dir/README.md" <<'EOF'
# README

capability_uplift
encoded_preference
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
description: skill uno
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

  cat > "$repo_dir/Skills/skill-dos/SKILL.md" <<'EOF'
---
name: skill-dos
description: skill dos
license: Apache-2.0
metadata:
  author: qa
  version: "1.0.0"
  scope:
    - root
  auto_invoke:
    - "run dos"
  owner: core
  skill_type: capability_uplift
  review_by: "2030-01-01"
  risk_level: low
  allowed_tools: []
---

# skill dos
EOF

  cat > "$repo_dir/Skills/skill-uno.md" <<'EOF'
# Legacy redirect: skill-uno

Fuente de verdad actual:

- `Skills/skill-uno/SKILL.md`
EOF
}

run_validator() {
  local repo_dir="$1"
  local output_file="$2"
  shift 2

  set +e
  VALIDATE_SKILLS_ROOT_DIR="$repo_dir" "$VALIDATOR_SCRIPT" "$@" > "$output_file" 2>&1
  local status=$?
  set -e

  printf '%s' "$status"
}

test_happy_path() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 0
  assert_contains "$output_file" 'Resumen: 0 error(es), 0 warning(s)'

  rm -rf "$repo_dir"
}

test_missing_frontmatter_start_delimiter() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"
  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<'EOF'
name: skill-uno
description: sin delimitador inicial
---
EOF

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 1
  assert_contains "$output_file" 'falta frontmatter YAML inicial (debe empezar con ---)'

  rm -rf "$repo_dir"
}

test_missing_frontmatter_closing_delimiter() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"
  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<'EOF'
---
name: skill-uno
description: sin cierre
license: Apache-2.0
metadata:
  author: qa
EOF

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 1
  assert_contains "$output_file" 'frontmatter YAML corrupto o sin cierre ---'

  rm -rf "$repo_dir"
}

test_body_metadata_does_not_bypass_frontmatter_validation() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"
  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<'EOF'
---
name: skill-uno
description: falta skill_type en frontmatter
license: Apache-2.0
metadata:
  author: qa
  version: "1.0.0"
  scope:
    - root
  auto_invoke:
    - "run uno"
  owner: core
  risk_level: low
  allowed_tools: []
---

# Body

skill_type: encoded_preference
EOF

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 1
  assert_contains "$output_file" 'falta metadata.skill_type'
  assert_contains "$output_file" 'skill_type invalido ()'

  rm -rf "$repo_dir"
}

test_excluded_directories_are_not_scanned() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"
  mkdir -p "$repo_dir/node_modules/pkg" "$repo_dir/.git/hooks" "$repo_dir/dist/docs"

  cat > "$repo_dir/node_modules/pkg/README.md" <<'EOF'
skills/rompe-si-se-escanea
EOF

  cat > "$repo_dir/.git/hooks/README.md" <<'EOF'
skills/rompe-si-se-escanea
EOF

  cat > "$repo_dir/dist/docs/README.md" <<'EOF'
skills/rompe-si-se-escanea
EOF

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 0
  assert_not_contains "$output_file" 'contiene referencia en minuscula a skills/'

  rm -rf "$repo_dir"
}

test_dry_run_reports_errors_but_exits_zero() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"
  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<'EOF'
---
name: skill-uno
description: falta metadata.skill_type a proposito
license: Apache-2.0
metadata:
  author: qa
  version: "1.0.0"
  scope:
    - root
  auto_invoke:
    - "run uno"
  owner: core
  risk_level: low
  allowed_tools: []
---

# skill uno
EOF

  local status
  status="$(run_validator "$repo_dir" "$output_file" --dry-run)"

  assert_status "$status" 0
  assert_contains "$output_file" 'falta metadata.skill_type'
  assert_contains "$output_file" 'error(es)'

  rm -rf "$repo_dir"
}

test_normal_mode_still_blocks_on_errors() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"
  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<'EOF'
---
name: skill-uno
description: falta metadata.skill_type a proposito
license: Apache-2.0
metadata:
  author: qa
  version: "1.0.0"
  scope:
    - root
  auto_invoke:
    - "run uno"
  owner: core
  risk_level: low
  allowed_tools: []
---

# skill uno
EOF

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 1
  assert_contains "$output_file" 'falta metadata.skill_type'

  rm -rf "$repo_dir"
}

test_invalid_name_format() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"
  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<'EOF'
---
name: Skill_Uno_Invalido
description: nombre con formato invalido
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

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 1
  assert_contains "$output_file" 'name '\''Skill_Uno_Invalido'\'' invalido'

  rm -rf "$repo_dir"
}

test_oversized_description() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"

  local long_description
  long_description="$(printf 'a%.0s' $(seq 1 1030))"

  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<EOF
---
name: skill-uno
description: $long_description
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

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 1
  assert_contains "$output_file" 'excede 1024 caracteres'

  rm -rf "$repo_dir"
}

test_valid_name_and_boundary_description_pass() {
  TESTS_RUN=$((TESTS_RUN + 1))
  local repo_dir
  repo_dir="$(mktemp -d)"
  local output_file="$repo_dir/out.log"

  create_base_repo "$repo_dir"

  local boundary_description
  boundary_description="$(printf 'a%.0s' $(seq 1 1024))"

  cat > "$repo_dir/Skills/skill-uno/SKILL.md" <<EOF
---
name: skill-uno-v2
description: $boundary_description
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

  local status
  status="$(run_validator "$repo_dir" "$output_file")"

  assert_status "$status" 0
  assert_not_contains "$output_file" 'invalido'
  assert_not_contains "$output_file" 'excede 1024 caracteres'

  rm -rf "$repo_dir"
}

main() {
  test_happy_path
  test_missing_frontmatter_start_delimiter
  test_missing_frontmatter_closing_delimiter
  test_body_metadata_does_not_bypass_frontmatter_validation
  test_excluded_directories_are_not_scanned
  test_dry_run_reports_errors_but_exits_zero
  test_normal_mode_still_blocks_on_errors
  test_invalid_name_format
  test_oversized_description
  test_valid_name_and_boundary_description_pass

  if [[ "$TESTS_FAILED" -gt 0 ]]; then
    printf '\nResultado: %s test(s), %s fallo(s)\n' "$TESTS_RUN" "$TESTS_FAILED"
    exit 1
  fi

  printf 'Resultado: %s test(s), 0 fallo(s)\n' "$TESTS_RUN"
}

main "$@"
