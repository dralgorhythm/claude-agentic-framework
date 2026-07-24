#!/usr/bin/env bash
# .claude/hooks/gate-lib.sh — shared quality-gate detection library.
#
# Single responsibility (artifacts/plan_framework_hardening.md, unit U5a):
# given a project directory, detect which quality gates apply and emit, per
# detected gate, an INVOCABLE command string plus the short human label the
# pre-commit advisory has always shown. Detection lives here once; each
# caller decides what to DO with a gate — pre-commit-verification.sh (U5b)
# and task-quality-gate.sh (U5c) both run GATE_COMMANDS under a per-gate
# timeout on their respective trigger events (open/closed — plan's Design
# Principles). This lib also centralizes the one bit of machinery both gate
# *enforcers* need identically — portable timeout-binary resolution — in
# gate_lib_timeout_bin (U5c: moved out of pre-commit-verification.sh, the
# same justified-DRY pattern this file's own U5a extraction set).
#
# Usage:
#   # shellcheck source=gate-lib.sh
#   source ".../gate-lib.sh"
#   gate_lib_detect "$PROJECT_DIR"
#   # then read the parallel arrays it populates:
#   #   GATE_LABELS[i]    human label, unchanged wording, e.g. "lint(pnpm)"
#   #   GATE_COMMANDS[i]  invocable command, e.g. "pnpm run lint"
#   bin=$(gate_lib_timeout_bin)  # "timeout", "gtimeout", or "" (run unbounded)
#
# Adapting: add a stack by appending one `if [ -f "$dir/<manifest>" ]` block
# with its own `_gate_add` calls — never by editing an existing block.
#
# Sourced, not executed directly — deliberately does not `set -u` itself
# (that would silently change the sourcing script's shell options too).
# Every variable below is defensively initialized so this stays correct
# under a caller's own `set -u` regardless.

GATE_LABELS=()
GATE_COMMANDS=()

_gate_add() { # $1=label $2=command
  GATE_LABELS+=("$1")
  GATE_COMMANDS+=("$2")
}

# gate_lib_detect DIR — populate GATE_LABELS/GATE_COMMANDS for DIR.
# Re-runnable: resets both arrays on every call.
gate_lib_detect() {
  local dir="${1:?gate_lib_detect: project dir required}"
  GATE_LABELS=()
  GATE_COMMANDS=()

  # TypeScript/JavaScript (pnpm preferred per tech strategy)
  if [ -f "$dir/package.json" ]; then
    local pkg_mgr
    if [ -f "$dir/pnpm-lock.yaml" ]; then
      pkg_mgr="pnpm"
    elif [ -f "$dir/package-lock.json" ]; then
      pkg_mgr="npm"
    else
      pkg_mgr="pnpm"
    fi

    if grep -q '"lint"' "$dir/package.json" 2>/dev/null; then
      _gate_add "lint($pkg_mgr)" "$pkg_mgr run lint"
    fi
    if grep -q '"test"' "$dir/package.json" 2>/dev/null; then
      _gate_add "test($pkg_mgr)" "$pkg_mgr test"
    fi
    if grep -q '"typecheck\|"tsc\|"type-check"' "$dir/package.json" 2>/dev/null; then
      _gate_add "typecheck($pkg_mgr)" "$pkg_mgr run typecheck"
    fi

    # Biome (preferred per tech strategy) — its own invocable check,
    # independent of whether a package.json "lint" script also exists.
    if [ -f "$dir/biome.json" ] || [ -f "$dir/biome.jsonc" ]; then
      _gate_add "biome" "$pkg_mgr exec biome check ."
    fi
  fi

  # Python (uv preferred per tech strategy)
  if [ -f "$dir/pyproject.toml" ]; then
    local py_run
    if command -v uv >/dev/null 2>&1; then
      py_run="uv run"
    else
      py_run="python -m"
    fi

    if grep -q "ruff" "$dir/pyproject.toml" 2>/dev/null; then
      _gate_add "ruff" "$py_run ruff check ."
    fi
    if grep -q "pytest" "$dir/pyproject.toml" 2>/dev/null; then
      _gate_add "pytest" "$py_run pytest"
    fi
    if grep -q "mypy" "$dir/pyproject.toml" 2>/dev/null; then
      _gate_add "mypy" "$py_run mypy ."
    fi
  fi

  # Go
  if [ -f "$dir/go.mod" ]; then
    _gate_add "go-test" "go test ./..."
    _gate_add "go-vet" "go vet ./..."

    if command -v golangci-lint >/dev/null 2>&1 || [ -f "$dir/.golangci.yml" ]; then
      _gate_add "golangci-lint" "golangci-lint run"
    fi
  fi

  # Rust
  if [ -f "$dir/Cargo.toml" ]; then
    _gate_add "cargo-test" "cargo test"
    _gate_add "cargo-clippy" "cargo clippy"
    _gate_add "cargo-fmt" "cargo fmt --check"
  fi
}

# gate_lib_timeout_bin — echo the portable per-gate timeout binary to use, or
# an empty string if neither exists (unit U5c). `timeout` is GNU coreutils:
# present on Linux/CI, absent on stock macOS (Homebrew installs it as
# `gtimeout`). A caller that gets "" back should run its gate command
# unbounded rather than fail the whole hook — bounded worse, never broken.
# Shared verbatim by pre-commit-verification.sh (U5b) and task-quality-gate.sh
# (U5c) so the resolution logic — and any future third case — lives once.
gate_lib_timeout_bin() {
  if command -v timeout >/dev/null 2>&1; then
    printf 'timeout'
  elif command -v gtimeout >/dev/null 2>&1; then
    printf 'gtimeout'
  else
    printf ''
  fi
}
