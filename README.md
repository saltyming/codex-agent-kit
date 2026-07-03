# codex-agent-kit

`codex-agent-kit` is the Codex harness member of the Slate Agent Kit family. It installs a Codex-focused `AGENTS.md`, detailed rules, and palette skills into `$CODEX_HOME` (default `~/.codex`).

The common rule source lives in [`slate-agent-kit`](https://github.com/saltyming/slate-agent-kit). This repo keeps the Codex-rendered form: Codex task tracking surfaces, Codex delegation constraints, formal Korean communication, no-scope-reduction rules, palette, and the shared `aside` / `dispatch` policy documents.

## What's Inside

- `AGENTS.md` — Codex operating manual (invariant kernel) rendered from Slate common rules.
- `codex-rules/` — the Codex surface binding (`--codex-surface.md`: `update_plan`, goal surface, `apply_patch`, `tool_search`, `multi_tool_use.parallel`, Slate MCP), task execution, delegation, palette, git workflow, framework conventions, aside, and dispatch policy.
- `codex-skills/palette-*` — pull-only palette helper skills.
- `scripts/` — prefs generator (`configure-prefs.sh` + templates) producing `$CODEX_HOME/rules/codex-agent-kit--{aside,dispatch}-prefs.md`.
- `install.sh` / `install.ps1` — user-scope installer for `$CODEX_HOME`.

**Loading model:** Codex auto-loads only the single user-scope `$CODEX_HOME/AGENTS.md`, so the installer **concatenates** `AGENTS.md` + every rule file (with `---` separators) into that file. The copies in `$CODEX_HOME/rules/` are reference material; the prefs files there are read on demand and survive reinstall/uninstall (user-owned signature). A pre-existing `AGENTS.md` not managed by this kit is backed up to `AGENTS.md.bak-<timestamp>` before being replaced.

`codex-agent-kit` does not vendor the shared Rust MCP source. `aside` and `dispatch` live in `slate-agent-kit/shared/mcp-servers` so all harnesses use the same implementation; `make install` registers them via `codex mcp add` through slate's `tooling/install-mcp.sh` (a slate checkout is discovered via `SLATE_AGENT_KIT_DIR` / sibling / parent, or shallow-cloned by `install.sh`). Pass `DISPATCH_ROOTS=/abs/workspace` to set dispatch's containment roots at registration.

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
- `SKIP_PROMPT=1` — suppress interactive prompts (custom rules, prefs) in `install.sh`.
- `SKIP_MCP=1` — install rules/skills only; skip MCP build + `codex mcp add`.
- `SLATE_AGENT_KIT_DIR` — explicit slate checkout for MCP registration.
- `DISPATCH_ROOTS` — colon-separated workspace roots for dispatch containment.
- `ASIDE_*` / `DISPATCH_*` — non-interactive prefs values (see `scripts/configure-prefs.sh`).

## Relationship To Slate

This repo is intentionally a harness-specific rendered kit. To change shared behavior, edit `slate-agent-kit/shared` and render the Codex adapter; do not hand-summarize rules here.

## License

[MIT](LICENSE.md) © 2026 Hamin Sung.
