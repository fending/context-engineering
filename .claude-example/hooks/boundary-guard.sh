#!/bin/bash
# PreToolUse hook: blocks edits to files protected by AGENTS.md boundary rules.
# Receives tool input as JSON on stdin. Exits 2 to block, 0 to allow.

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Skip if no file path (not a file operation)
[[ -z "$FILE_PATH" ]] && exit 0

# Resolve to absolute path if relative
if [[ "$FILE_PATH" != /* ]]; then
  FILE_PATH="$(pwd)/$FILE_PATH"
fi

# Walk up directory tree to find nearest AGENTS.md
find_agents_md() {
  local dir="$1"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/AGENTS.md" ]]; then
      echo "$dir/AGENTS.md"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  return 1
}

AGENTS_FILE=$(find_agents_md "$(dirname "$FILE_PATH")")

# No AGENTS.md found -- nothing to enforce
[[ -z "$AGENTS_FILE" ]] && exit 0

# Extract "Do NOT" section content (lines between "## Do NOT" and next heading or EOF)
BOUNDARY_RULES=$(sed -n '/^## Do NOT/,/^## /{/^## Do NOT/d;/^## /d;p;}' "$AGENTS_FILE")

# If no "Do NOT" section, also check for "## Boundaries" section
if [[ -z "$BOUNDARY_RULES" ]]; then
  BOUNDARY_RULES=$(sed -n '/^## Boundaries/,/^## /{/^## Boundaries/d;/^## /d;p;}' "$AGENTS_FILE")
fi

# No boundary rules found
[[ -z "$BOUNDARY_RULES" ]] && exit 0

# Get the relative path from the AGENTS.md location for pattern matching
AGENTS_DIR=$(dirname "$AGENTS_FILE")
REL_PATH="${FILE_PATH#$AGENTS_DIR/}"

# Check each boundary rule for path-like patterns
while IFS= read -r rule; do
  # Skip empty lines and non-list items
  [[ -z "$rule" ]] && continue
  [[ "$rule" != -* ]] && continue

  # Strip leading "- " for matching
  rule_text="${rule#- }"

  # Look for file/directory references in the rule
  # Match common patterns: paths, extensions, directory names
  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    if [[ "$REL_PATH" == *"$pattern"* ]]; then
      echo "Blocked by AGENTS.md boundary rule:" >&2
      echo "  Rule: $rule_text" >&2
      echo "  File: $REL_PATH" >&2
      echo "  Source: $AGENTS_FILE" >&2
      echo "" >&2
      echo "Use /scope-check to review boundaries before starting." >&2
      exit 2
    fi
  done < <(echo "$rule_text" | grep -oE '[a-zA-Z0-9_/-]+\.[a-zA-Z]+|[a-zA-Z0-9_-]+/' | sed 's/\/$//')

done <<< "$BOUNDARY_RULES"

exit 0
