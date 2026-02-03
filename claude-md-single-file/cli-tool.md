# CLAUDE.md (CLI Tool)

A single-file context for a command-line tool. CLI projects have distinct context needs: argument parsing, output formatting, exit codes, and cross-platform behavior.

---

````markdown
# CLAUDE.md

## What This Tool Does

[One paragraph. What problem it solves, who uses it, how it's distributed (npm, homebrew, binary, etc.).]

## Tech Stack

- **Language:** [e.g., TypeScript, Rust, Go, Python]
- **Arg Parsing:** [e.g., commander, clap, cobra, argparse]
- **Output:** [Plain text, JSON, table formatting library]
- **Distribution:** [npm package, compiled binary, pip install]

## Project Structure

```text
tool/
├── src/
│   ├── cli.ts            # Entry point, arg parsing
│   ├── commands/          # One file per subcommand
│   ├── lib/               # Core logic (testable, no I/O assumptions)
│   ├── output/            # Formatting and display
│   └── config/            # Config file loading, defaults
├── tests/
│   ├── unit/              # Lib and command logic
│   └── integration/       # Full CLI invocation tests
├── bin/                   # Compiled/linked entry points
└── docs/                  # Man pages or usage docs
```

## Commands

```bash
[dev/watch command]
[test command]
[build command]
[link locally for testing]
```

## CLI Design Conventions

### Subcommand Structure

- [Top-level commands and what they do]
- [How flags/options are organized -- global vs. per-command]
- [Help text conventions]

### Output

- [Default output: human-readable text]
- [Machine-readable flag: --json, --format=json, etc.]
- [Verbosity: -v, -vv, --quiet]
- [Color: respect NO_COLOR env var, --no-color flag]

### Exit Codes

| Code | Meaning |
| ---- | ------- |
| 0 | Success |
| 1 | General error |
| 2 | Usage/argument error |
| [n] | [Domain-specific meaning] |

### Config

- [Config file location and format -- ~/.toolrc, .tool.json in project root, etc.]
- [Precedence: CLI flags > env vars > config file > defaults]
- [How to document new config options]

## Architecture

### Separation of Concerns

- **CLI layer** (`cli.ts`, `commands/`): Arg parsing, I/O, exit codes. Thin as possible.
- **Core logic** (`lib/`): Pure functions, no I/O, no process.exit(). All business logic lives here.
- **Output layer** (`output/`): Formatting for human and machine consumption.

This separation means core logic is testable without invoking the CLI binary, and output can be swapped without touching business logic.

### Error Handling

- Core logic throws typed errors with error codes
- CLI layer catches errors and maps them to exit codes + user-facing messages
- Never call `process.exit()` from core logic
- Unexpected errors: print stack trace only with -v flag

## Testing

- **Unit tests** exercise core logic directly (no subprocess spawning)
- **Integration tests** invoke the actual CLI binary and assert on stdout, stderr, and exit code
- Integration tests use a fixture directory with sample inputs
- Tests must pass on [target platforms -- macOS, Linux, Windows if applicable]

## Do NOT

- [Print to stdout from core logic -- return values, let the CLI layer handle output]
- [Use interactive prompts without checking if stdin is a TTY]
- [Break backward compatibility on flags/subcommands without a deprecation cycle]
- [Hardcode paths -- respect XDG conventions or platform-appropriate config dirs]
- [Swallow errors silently -- always surface them with an appropriate exit code]
````

---

## Notes

**The core logic / CLI layer separation is the most important pattern.** Without it, you end up with untestable code, mixed I/O, and functions that call `process.exit()` from three layers deep. This separation is worth enforcing in context.

**Exit codes and output formatting are CLI-specific concerns that general context files miss.** An AI generating a new subcommand needs to know that `--json` output is expected, that exit code 2 means argument error, and that `NO_COLOR` should be respected. These aren't obvious defaults.

**Cross-platform considerations belong in the Do NOT section.** If you've burned time debugging a path separator issue on Windows, or a config file that assumed `~/.config/` exists, document it.
