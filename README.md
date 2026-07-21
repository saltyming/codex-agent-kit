# codex-agent-kit

A battle-tested operating manual (`AGENTS.md`) for the **OpenAI Codex CLI**, plus the two **shared** Slate MCP servers — `aside` (cross-family second opinions) and `dispatch` (asynchronous hierarchical delegation to codex / opencode / claude backends) — whose source lives in [`slate-agent-kit`](https://github.com/saltyming/slate-agent-kit)`/shared/mcp-servers` and is built + registered from there. It also ships **palette** — a rules-plus-skills *product-intent outer loop* that wraps the per-task workflow with a durable, cross-session backlog and a slice → build → review cadence (opt in per project via the `palette-init` skill).

Its rules render from the **same shared source** as the Claude and Kimi kits, then bind to Codex's native surfaces (planning, editing, delegation). To change shared behavior, edit `slate-agent-kit/shared` and re-render — never hand-summarize here.

> **Honest caveat.** These rules reduce common failure modes but don't eliminate them — treat the kit as a strong prior, not a guarantee. The pattern that still recurs and needs manual correction is **silent scope reduction** (splitting or deferring requested work despite the invariants). Review completion reports critically and name the miss when you see it.

## What's Inside

### AGENTS.md — the operating manual

Codex auto-loads a single user-scope `$CODEX_HOME/AGENTS.md`, so the installer **concatenates** the invariant kernel + every rule file (with `---` separators) into it. The kernel states each rule once with a stable ID, then references the ID everywhere else:

| Invariant | What it enforces |
|---|---|
| **Scope integrity** (`INV-SCOPE-*`) | Ship the entire requested scope; no silent stubs, TODOs, or "A now, B later" splits; scope is user-owned — never unilaterally expanded or shrunk. |
| **Verification** (`INV-VERIFY-*`) | Run the test / execute the code before claiming completion; report failures faithfully, never fake a green result. |
| **Durable implementation** (`INV-QUALITY-1`) | Write for the declared operating envelope (every platform, input class, and caller the code claims to support); fix causes, not symptoms. |
| **State safety** (`INV-STATE-*`) | No model-initiated rollback; "undo" reverses this session's edits, not repo state; user-owned uncommitted changes are inviolate. |
| **Delegation gates** (`GATE-DELEGATE` / `GATE-DISPATCH`) | Write-capable delegation is surfaced and approved before it runs. |

These bind to Codex via `codex-rules/codex-agent-kit--codex-surface.md`: multi-step work is tracked with **`update_plan` + the goal surface** (Codex's planning tools, in place of Claude's workslate); edits go through **`apply_patch`**; search uses **`tool_search`**; parallel reads use **`multi_tool_use.parallel`**. Detailed rules live in `codex-rules/` (task execution, delegation, palette, git workflow, framework conventions, aside, dispatch) and are folded into the one `AGENTS.md`.

### palette — product-intent outer loop (rules + skills, no server)

A durable, cross-session planning layer that wraps the per-task workflow. Where the rest of the kit is *within-task* (understand → plan → execute, then it evaporates), palette adds the *outer* loop: a backlog of product intent → slice a thin phase with you → hand a story's acceptance criteria to the normal build workflow → review and re-plan on completion.

- **Opt-in per project, then always-on.** The `palette-init` skill scaffolds a `_palette/` directory; its mere presence turns palette on. No `_palette/`, no palette.
- **Advisory, never authoritative.** The backlog / phase / story artifacts *propose* scope; your existing approval gate *authorizes*. A two-way scope firewall keeps palette from shrinking requested work or deferring unmet acceptance criteria.
- **RST artifacts, robust subset**, plus four **pull-only** skills (`palette-spec` / `palette-ux` / `palette-ui` / `palette-rules`) for tech-spec / UX / design / project-rules depth on demand.

`_palette/` is a personal planning record — **not committed** by default. Methodology inspired by [mano](https://github.com/ceceppa/mano) (MIT © 2026 ceceppa).

### aside MCP server

Second opinions via locally-installed CLIs. Codex has no built-in advisor, so `aside` is the second-opinion surface — a perspective from a different model family or a local CLI: `aside_codex` (OpenAI), `aside_copilot` (GitHub), `aside_claude` (Anthropic).

- **Transcript auto-forwarded, redacted** — `text` passes through verbatim; `tool_use` / `tool_result` / `thinking` become placeholders. 100 KB cap; pass `include_transcript=false` for decontextualised questions.
- **Read-only, non-interactive** — each backend can read files and grep the workspace itself, but cannot edit files or run shells.
- **Preference-driven policy** — `configure-prefs.sh` generates `codex-agent-kit--aside-prefs.md` (preferred backend, default models, reasoning effort, and a `conservative` / `preference-only` / `proactive` auto-call policy) with an interactive overwrite prompt and injection-safe substitution.
- **Cost-aware** — every call uses your third-party API quota, so the rules cap it to one focused question per call.

Install the CLIs separately (`aside` only wraps them): [codex](https://github.com/openai/codex), [copilot](https://docs.github.com/copilot/how-tos/copilot-cli), and [Claude Code](https://claude.com/claude-code). `aside_list` reports which are present.

### dispatch MCP server

Asynchronous **hierarchical delegation** — hand an execution step to an external coding agent (codex, opencode, or claude) running headless and **write-capable**. Where `aside` seeks a read-only opinion, `dispatch` entrusts execution; the run continues in the background and you poll for the result.

- **Async submit → poll → cancel** — `dispatch_submit` returns a task id immediately and runs the backend detached; `dispatch_status` / `dispatch_list` track it, `dispatch_logs` shows the curated timeline, `dispatch_cancel` stops a run or a whole `plan_id`.
- **Watch + steer** — `dispatch_logs` shows a curated live timeline; `dispatch_steer` interrupts and resumes the *same* backend session with a new instruction, preserving context + files it already wrote.
- **Server-enforced guards** — `working_dir` must canonicalize within the project tree (widen with `DISPATCH_EXTRA_ROOTS`); `danger-full-access` is blocked unless `DISPATCH_ALLOW_DANGER=1`; one active run per directory.
- **Execution policy + approval gate** — `configure-prefs.sh` generates `codex-agent-kit--dispatch-prefs.md` with a `conservative` / `preference-only` / `proactive` policy plus an approval mode; `ask` confirms working_dir + step scope before the first submit, `auto` pre-authorizes within server guards.

Requires a backend CLI: [codex](https://github.com/openai/codex), [OpenCode](https://opencode.ai/docs/cli/), and/or [Claude Code](https://claude.com/claude-code). `dispatch_backends` reports which are installed.

## Installation

**macOS / Linux**

```sh
curl -fsSL https://raw.githubusercontent.com/saltyming/codex-agent-kit/main/install.sh | sh
# uninstall (removes only kit-signed files; your prefs are kept):
curl -fsSL https://raw.githubusercontent.com/saltyming/codex-agent-kit/main/install.sh | sh -s -- --uninstall
```

**Windows (PowerShell)** — registers the shared MCP servers natively (downloads the prebuilt `.zip` binaries + `codex mcp add`) and generates prefs:

```powershell
irm https://raw.githubusercontent.com/saltyming/codex-agent-kit/main/install.ps1 | iex
```

**From a clone:**

```sh
make install      # concatenate AGENTS.md + rules + skills, register MCP, configure prefs
make configure    # re-run the aside + dispatch preference prompts
make validate     # sanity-check the rendered kit
make uninstall    # remove kit-signed files (user-owned prefs kept)
```

**Loading model:** Codex auto-loads only `$CODEX_HOME/AGENTS.md`, so the installer concatenates `AGENTS.md` + every rule (with `---` separators) into it. The copies in `$CODEX_HOME/rules/` are reference material; the prefs files there are read on demand and survive reinstall/uninstall (user-owned signature). A pre-existing unmanaged `AGENTS.md` is backed up to `AGENTS.md.bak-<timestamp>` first.

`aside` / `dispatch` are not vendored here — they live in `slate-agent-kit/shared/mcp-servers` so every harness uses the same build. On macOS/Linux the installer registers them via `codex mcp add` through slate's `tooling/install-mcp.sh` (a slate checkout is found via `SLATE_AGENT_KIT_DIR` / sibling / parent, or shallow-cloned). On Windows `install.ps1` does it natively.

**Environment:**

- `CODEX_HOME` — install root, default `~/.codex`.
- `CUSTOM_RULES_DIR` — optional directory of additional `*.md` rules appended to `AGENTS.md`.
- `SKIP_PROMPT=1` — suppress interactive prompts (custom rules, prefs).
- `SKIP_MCP=1` — install rules/skills only; skip MCP build + registration.
- `SLATE_AGENT_KIT_DIR` — explicit slate checkout for MCP registration.
- `DISPATCH_ROOTS` — workspace roots for dispatch containment.
- `ASIDE_*` / `DISPATCH_*` — non-interactive prefs values.

## Relationship To Slate

This repo is a harness-specific **rendered** kit. To change shared behavior, edit `slate-agent-kit/shared` and render the Codex adapter; do not hand-summarize rules here.

## License

[MIT](LICENSE.md) © 2026 Hamin Sung.
