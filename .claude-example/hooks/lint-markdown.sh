#!/bin/bash
# PostToolUse hook: runs markdownlint on edited markdown files.
# Receives tool input as JSON on stdin. Exits 2 to block, 0 to allow.
# Requires markdownlint-cli2 (npx handles installation).

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

# Only lint .md files
[[ "$FILE_PATH" != *.md ]] && exit 0

# Skip if file doesn't exist (deleted)
[[ ! -f "$FILE_PATH" ]] && exit 0

# Run markdownlint
OUTPUT=$(npx markdownlint-cli2 "$FILE_PATH" 2>&1)
if [[ $? -eq 0 ]]; then
  exit 0
else
  echo "markdownlint violations in $FILE_PATH:" >&2
  echo "$OUTPUT" >&2
  exit 2
fi
