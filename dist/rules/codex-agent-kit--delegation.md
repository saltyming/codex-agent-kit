<!-- slate-agent-kit:common -->
# Work Leaving the Session

Subagents, consultation (`codex-agent-kit--aside.md`) and dispatch (`codex-agent-kit--dispatch.md`), each judged for value (§ 7) and used at its level (§ 8): `on-request` acts only when asked; `suggest` proposes in one line and waits; `auto` applies § 7, acts, and says in one line what was started, on which model and why.

- Subagents are the harness's delegates: read-only ones inspect, search or summarize; write-capable ones edit; an unknown kind is write-capable. Consultation asks for an opinion and writes nothing. Dispatch hands a self-contained, write-capable step to an external agent that runs asynchronously. Skills, commands and workflows bypass no article. When the harness lacks a mechanism safe delegation needs, say so; do not improvise one.
- A delegate saves the leader's context and costs the user models, quota and time, returning a result without its reasoning. It helps when work splits into independent parts with a stable shared contract, or when one bounded lookup would flood the context. Work stays in-session when sequential, tightly coupled, small, assigned to the leader by a document, or when the user is waiting for the leader's own answer. At `auto`, state in one line before starting how many delegates, which model, what each does and which files each writes; at `suggest`, say the same and wait. Which model and effort a delegate runs on: `codex-agent-kit--models.md`.
- Write the shared contracts (public types, schemas, migration order, shared tests) before delegating; one writer per file (§ 14). One prompt over many inputs needs a tight template. A prompt is self-contained: files owned, expected output, what success looks like, settled decisions as constraints, what must not be done, the operating envelope (§ 9), and whether it may delegate in turn (§ 15); a nested delegate counts toward the count and files the leader stated. A delegate cannot watch a long-running process; have it write a log, a results file or an exit-code file. Implementation work never goes to a read-only delegate.

---

## Codex delegation surfaces

- Codex's native subagents (`spawn_agent` and the tools that steer a spawned agent) are write-capable: a child has the parent's tools, whatever its `agent_type`. They run on the default the prefs set (`[agents] default_subagent_model`), else on the session's model. Codex has no read-only subagent; a read-only opinion goes through aside.
- A delegate can spawn subagents of its own (§ 15).
- Do not simulate delegation with background shells or nested `codex exec` calls.
