# Changelog

## 0.4.4 - 2026-07-08

- **aside**: prompt hardened against leading-question anchoring bias — a leading/loaded question from the leader (e.g. "I fixed the race condition by adding a mutex — confirm this is correct") let the backend rubber-stamp the framing instead of independently checking the premise. `ROLE_FRAMING` now frames the backend's role as an independent second opinion; a new `INDEPENDENCE_REMINDER` is appended as the prompt's final section (after the question, not just folded into the top) so it isn't diluted by a large context/transcript block and lands with maximum salience right before the backend generates its answer. Guards against overcorrection — the backend still answers plainly when the premise holds and answers simple factual questions directly. New `compose_prompt` unit tests cover section ordering, the no-context/no-transcript case, and continuation-join substring checks on the new multi-line literals (none existed before).
- **rules**: `codex-agent-kit--aside.md` gets a new "Question framing" section instructing the leader to phrase `question`/`context` as an assessment to verify, not a conclusion to confirm.

## 0.4.3 - 2026-07-06

- **dispatch**: poll responses no longer re-echo the whole submitted spec on every call. `dispatch_status` is compact by default — the accepted `spec`, rendered `prompt`, and `argv` move behind a new `include_spec` param (default false); terminal `result`/`error` still return. `dispatch_logs` / `dispatch_wait` collapse the backend's initial prompt echo (and opencode's duplicate `[opencode]` re-echo) to a one-line placeholder for fresh submits, matched by canonical content vs the stored prompt so a steered task's new instruction stays visible; bare `</think>` markers are dropped. Verified for codex/opencode/claude via synthetic fixtures.

## 0.4.2 - 2026-07-06

- **dispatch**: `dispatch_steer` now inherits the steered task's `allow_concurrent` by default and accepts an explicit override — fixes the case where a task in a directory with other concurrent runs could not be steered (`dir_busy` with no bypass; `allow_concurrent=false` re-enforces the guard). `allow_concurrent` is persisted on the task row via an additive, backward-compatible SQLite column (old DBs backfill to false).

## 0.4.1 - 2026-07-05

- **aside/dispatch recursion guard (security fix)**: closes a fork-bomb vector where a backend spawned by `aside`/`dispatch` — while still having them registered as MCP servers — could re-invoke them and spawn another backend without bound.
- **aside**: backends now carry no MCP server — codex is spawned with `exec --ignore-user-config` (auth still resolves from the codex home), alongside claude `--safe-mode` and copilot's read-only whitelist; plus a defense-in-depth `ASIDE_REENTRY_DEPTH` marker.
- **dispatch**: blocks dispatch→dispatch via a `DISPATCH_REENTRY_DEPTH` env marker (claude/opencode forward their env to MCP children) plus, for codex (which does not), `-c mcp_servers.dispatch.enabled=false`. `aside` stays reachable, so dispatch→aside is still allowed; new `reentrant` error code.

## 0.4.0 - 2026-07-05

- **aside**: new `aside_claude` backend; the server emits MCP `notifications/progress` on long calls so Codex's per-tool-call timeout resets instead of aborting.
- **Windows (`install.ps1`)**: now registers the shared `aside` / `dispatch` MCP servers natively (downloads the prebuilt `.zip` binaries + `codex mcp add`) and generates prefs — previously punted to POSIX; `--uninstall` skill removal reads the line-6 signature (`head -8`).
- **Prefs**: the shared `configure-prefs.sh` is now interactive-first, injection-safe, and prompts every knob; a `configure-prefs.ps1` Windows twin joins it.
- **README**: full rewrite to parity with the Claude kit — invariant kernel, palette, aside, dispatch, adapted to Codex's surfaces.

## 0.3.0 - 2026-07-03

- **INV-QUALITY-1 — durable implementation** (rules-only release): new kernel invariant — every change must hold across the code's *declared operating envelope* (platforms, harnesses, input classes, callers, derived from repo evidence: docs, CI matrix, public APIs, tests, existing callers), not merely the case that triggered the work; fix causes, not symptoms; tests assert the contract, not the authoring machine's incidental representation. Woven into the execution loop (pre-coding envelope evidence, durability check, completion checklist), delegation prompt rules, and the dispatch spec-writing rule.
- **Codex surface — Editing**: a small patch is a *diff-size* discipline, not a *design-horizon* one; the minimal diff that fixes the cause across the envelope is right, the smaller diff that silences today's symptom on today's machine is not.

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
