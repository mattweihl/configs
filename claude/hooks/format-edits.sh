#!/bin/sh
# Formats the file that Claude Code just wrote.
#
# Wired to PostToolUse (Edit|Write|NotebookEdit) in claude/settings.json.
#
# Why this exists: nvim formats on save through conform.nvim, but Claude edits
# files directly and never goes through nvim. Without this hook, every file the
# agent touches skips prettier/ruff, and the next human save produces a diff
# full of unrelated reformatting.
#
# The formatter list mirrors nvim/lua/plugins/format.lua. Keep the two in step.
#
# Claude Code passes the hook payload as JSON on stdin and sets no per-tool
# environment variables. The path lives at .tool_response.filePath, with
# .tool_input.file_path / .tool_input.notebook_path as fallbacks -- this is the
# pattern Claude Code's own hook docs use. One tool call means one file, so
# there is no list to split and paths containing spaces are safe.

set -u

command -v jq >/dev/null 2>&1 || exit 0

path="$(jq -r '
  .tool_response.filePath
  // .tool_input.file_path
  // .tool_input.notebook_path
  // empty
' 2>/dev/null)"

[ -n "$path" ] || exit 0
[ -f "$path" ] || exit 0

# Neither prettier nor ruff is installed globally on this machine: conform.nvim
# finds them because Mason prepends its bin/ to nvim's PATH. A hook gets no such
# help, so resolve the same binaries by hand -- project-local first, so a repo
# pinning its own prettier version wins over whatever Mason happens to hold.
MASON_BIN="$HOME/.local/share/nvim/mason/bin"

find_up() {
  # find_up <start-file> <relative-path>  -> prints first match walking upward.
  # Stops at the repository root. Without that boundary a single ~/.prettierrc
  # would make every repo on the machine look like it had opted in.
  # Always called in a subshell, so the loop variable stays out of the caller.
  dir="$(CDPATH= cd -- "$(dirname -- "$1")" && pwd -P)" || return 1
  while :; do
    [ -e "$dir/$2" ] && { printf '%s\n' "$dir/$2"; return 0; }
    [ -e "$dir/.git" ] && return 1
    [ "$dir" = "/" ] && return 1
    dir="$(dirname -- "$dir")"
  done
}

resolve_formatter() {
  # resolve_formatter <file> <bin-name>
  local_found="$(find_up "$1" "node_modules/.bin/$2")"
  [ -n "$local_found" ] && { printf '%s\n' "$local_found"; return 0; }
  [ -x "$MASON_BIN/$2" ] && { printf '%s\n' "$MASON_BIN/$2"; return 0; }
  command -v "$2" 2>/dev/null && return 0
  return 1
}

# Run a formatter only when the project opts into it. A repo with no prettier
# config does not want its files reformatted because a hook fired -- that turns
# one intentional edit into a whole-file diff.
has_config() {
  for name in $2; do
    [ -n "$(find_up "$1" "$name")" ] && return 0
  done
  return 1
}

# Rewrites a file through a formatter that only speaks stdin/stdout. Writes to a
# temp file first: redirecting straight onto the input truncates it before the
# formatter reads a byte, and a formatter that errors would leave the file empty.
format_via_stdin() {
  # format_via_stdin <file> <bin> [args...]
  target="$1"
  shift
  tmp="$(mktemp)" || return 1
  if "$@" <"$target" >"$tmp" 2>/dev/null && [ -s "$tmp" ]; then
    cat "$tmp" >"$target"
  fi
  rm -f "$tmp"
}

PRETTIER_CONFIGS='.prettierrc .prettierrc.json .prettierrc.yml .prettierrc.yaml .prettierrc.js .prettierrc.cjs .prettierrc.mjs .prettierrc.toml prettier.config.js prettier.config.cjs prettier.config.mjs'
PYTHON_CONFIGS='pyproject.toml ruff.toml .ruff.toml setup.cfg'

case "$path" in
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.css|*.scss|*.html|*.json|*.jsonc|*.md|*.yml|*.yaml)
    has_config "$path" "$PRETTIER_CONFIGS" || exit 0
    bin="$(resolve_formatter "$path" prettier)" || exit 0
    "$bin" --write --log-level warn "$path" >/dev/null 2>&1
    ;;
  *.py)
    has_config "$path" "$PYTHON_CONFIGS" || exit 0
    bin="$(resolve_formatter "$path" ruff)" || exit 0
    "$bin" format --quiet "$path" >/dev/null 2>&1
    ;;
  *.tf|*.tfvars)
    # `terraform fmt <file>` is rejected -- the positional argument is a
    # directory. conform's terraform_fmt formatter pipes through stdin instead,
    # and `-` is the documented spelling for that. No config gate: HCL has one
    # canonical style and `terraform fmt` is it.
    command -v terraform >/dev/null 2>&1 || exit 0
    format_via_stdin "$path" terraform fmt -no-color -
    ;;
esac

# Always succeed. A missing formatter, or one that chokes on a file the agent is
# midway through writing, must not fail the tool call that triggered it.
exit 0
