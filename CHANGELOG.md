# Changelog

## 0.2.0 - 2026-07-03

- **Concat installer**: Codex loads only the single `$CODEX_HOME/AGENTS.md`, so `make install` / `install.sh` now concatenate the manual + all rule files into it (`---` separators); `$CODEX_HOME/rules/` holds reference copies. A pre-existing unmanaged `AGENTS.md` is backed up to `.bak-<timestamp>` first.
- **Codex surface rule** (`codex-agent-kit--codex-surface.md`, rendered from `slate-agent-kit/adapters/codex/surface.md`): loading model, `update_plan` + goal surface bindings, `apply_patch` editing discipline, `rg` / `multi_tool_use.parallel` / `tool_search` / `request_user_input` guidance, Slate MCP registration and env contract.
- **Rules re-rendered from the redesigned Slate corpus**: invariant kernel (INV-*/GATE-* IDs), execution loop, delegation loop with a Codex-surfaces section, consolidated palette gate bindings.
- **Prefs machinery**: `scripts/configure-prefs.sh` + templates generate user-owned `codex-agent-kit--{aside,dispatch}-prefs.md` in `$CODEX_HOME/rules/` (previously dangling references).
- **MCP hookup**: `make install` registers shared `aside`/`dispatch` via slate's `tooling/install-mcp.sh --configure-codex` (`ASIDE_HARNESS=codex`, native rollout transcript reading; `DISPATCH_ROOTS` for containment); `install.sh` shallow-clones slate when no checkout is found; `SKIP_MCP=1` opts out.
- **Signature-guarded uninstall**: only kit-signed files are removed; user-owned (`-custom:` signed) prefs and unrecognized files are preserved.

## 0.1.0 - 2026-07-03

- Initial Codex-specific split from the agent-kit family.
- Installs `AGENTS.md`, Codex rules, and palette skills into `$CODEX_HOME`.
- Rules are rendered from `slate-agent-kit/shared` and keep full scope-integrity, verification, delegation, palette, aside, and dispatch policy.
