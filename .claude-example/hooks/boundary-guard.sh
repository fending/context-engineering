#!/bin/bash
# PreToolUse hook: blocks edits to files protected by AGENTS.md boundary rules.
# Walks the full directory ancestry to compound rules from all cascading levels.
# Receives tool input as JSON on stdin. Exits 2 to block, 0 to allow.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path (not a file operation)
[[ -z "$FILE_PATH" ]] && exit 0

# Resolve to absolute path if relative
if [[ "$FILE_PATH" != /* ]]; then
  FILE_PATH="$(pwd)/$FILE_PATH"
fi

# Collect all AGENTS.md files from target directory up to filesystem root.
# Deepest first so block messages cite the most specific source.
collect_agents_md() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    [[ -f "$dir/AGENTS.md" ]] && echo "$dir/AGENTS.md"
    dir=$(dirname "$dir")
  done
}

AGENTS_FILES=$(collect_agents_md "$(dirname "$FILE_PATH")")

# No AGENTS.md found anywhere -- nothing to enforce
[[ -z "$AGENTS_FILES" ]] && exit 0

# Extract boundary rules from a single AGENTS.md.
# Checks "Do NOT", "Boundaries", and "Restrictions" headings and combines all.
extract_rules() {
  local file="$1"
  for heading in "Do NOT" "Boundaries" "Restrictions"; do
    sed -n "/^## ${heading}/,/^## /{/^## ${heading}/d;/^## /d;p;}" "$file"
  done
}

# Check rules from every ancestor AGENTS.md against the target file.
# Each file's rules are matched relative to its own directory.
while IFS= read -r agents_file; do
  [[ -z "$agents_file" ]] && continue

  BOUNDARY_RULES=$(extract_rules "$agents_file")
  [[ -z "$BOUNDARY_RULES" ]] && continue

  AGENTS_DIR=$(dirname "$agents_file")
  REL_PATH="${FILE_PATH#$AGENTS_DIR/}"

  while IFS= read -r rule; do
    [[ -z "$rule" ]] && continue
    [[ "$rule" != -* ]] && continue

    rule_text="${rule#- }"

    # Extract patterns: backtick-fenced paths first (reliable), then
    # fall back to path-shaped tokens in plain text (best-effort).
    patterns=$(echo "$rule_text" | grep -oE '`[^`]+`' | tr -d '`')
    if [[ -z "$patterns" ]]; then
      patterns=$(echo "$rule_text" | grep -oE '\.[a-zA-Z0-9]+|[a-zA-Z0-9_./-]+/[a-zA-Z0-9_./-]*' | sed 's/\/$//')
    fi

    while IFS= read -r pattern; do
      [[ -z "$pattern" ]] && continue
      if [[ "$REL_PATH" == *"$pattern"* ]]; then
        echo "Blocked by boundary rule:" >&2
        echo "  Rule: $rule_text" >&2
        echo "  File: $REL_PATH" >&2
        echo "  Source: $agents_file" >&2
        echo "" >&2
        echo "Use /scope-check to review boundaries before starting." >&2
        exit 2
      fi
    done <<< "$patterns"

  done <<< "$BOUNDARY_RULES"

done <<< "$AGENTS_FILES"

exit 0
