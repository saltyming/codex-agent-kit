# codex-agent-kit

`codex-agent-kit` is the Codex harness member of the Slate Agent Kit family. It installs a Codex-focused `AGENTS.md`, detailed rules, and palette skills into `$CODEX_HOME` (default `~/.codex`).

The common rule source lives in [`slate-agent-kit`](https://github.com/saltyming/slate-agent-kit). This repo keeps the Codex-rendered form: Codex task tracking surfaces, Codex delegation constraints, formal Korean communication, no-scope-reduction rules, palette, and the shared `aside` / `dispatch` policy documents.

## What's Inside

- `AGENTS.md` — Codex operating manual rendered from Slate common rules.
- `codex-rules/` — task execution, delegation, palette, git workflow, framework conventions, aside, and dispatch policy.
- `codex-skills/palette-*` — pull-only palette helper skills.
- `install.sh` / `install.ps1` — user-scope installer for `$CODEX_HOME`.

`codex-agent-kit` does not vendor the shared Rust MCP source. `aside` and `dispatch` live in `slate-agent-kit/shared/mcp-servers` so all harnesses use the same implementation.

## Installation

macOS / Linux:

```sh
curl -fsSL https://raw.githubusercontent.com/saltyming/codex-agent-kit/main/install.sh | sh
```

Windows PowerShell:

```powershell
irm https://raw.githubusercontent.com/saltyming/codex-agent-kit/main/install.ps1 | iex
```

From a clone:

```sh
make install
make validate
make uninstall
```

Environment:

- `CODEX_HOME` — install root, default `~/.codex`.
- `CUSTOM_RULES_DIR` — optional directory of additional `*.md` rules appended to `AGENTS.md`.
- `SKIP_PROMPT=1` — suppress custom-rules prompt in `install.sh`.

## Relationship To Slate

This repo is intentionally a harness-specific rendered kit. To change shared behavior, edit `slate-agent-kit/shared` and render the Codex adapter; do not hand-summarize rules here.

## License

[MIT](LICENSE.md) © 2026 Hamin Sung.
