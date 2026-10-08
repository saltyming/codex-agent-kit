<!-- slate-agent-kit:common -->
# Model and Effort Choice

Which model and effort a subagent, a dispatch step or a consultation runs on, where the user, the prefs (§ 8) or the call has not fixed it. The table covers this harness's own models only: a dispatch step or a consultation on another vendor's backend runs on the model its prefs name, else on that backend's default. The table places the models by the vendor's own statements; a figure compares tiers on one vendor page and ranks no vendor against another.

- Choose by the shape of the work. Scoped work, whose shape is given (a named fix, a search, a mechanical edit across any number of files, a review against a checklist), runs on the cheapest tier the table lists for that kind of work, at the tier's starting effort; in the kit's own runs higher effort on such work bought time and cost, not results. Work that needs design reasoning (implementing an RFC, a change whose shape the delegate must work out) runs at high; xhigh and max only where a check shows a gain.
- A lower tier is neither a lower effort nor a smaller task: the delegate gets the same scope, the same self-contained prompt and the same verification it would get on the top model (§ 15), and never runs below its listed starting effort. The leader confirms that a check a lower tier reports was run.
- A delegate on scoped work names its model through the harness's per-call or default setting, where the harness has one, instead of inheriting the session's; an inherited top model bills every delegate's reading at the top rate.
- Parallel workers on a lower tier cut wall time when the work splits into many independent pieces; they cut cost only on routine pieces or on work too large for one context. One dependent chain stays with one model.

## Codex models (as of 2026-10-08, codex-cli 0.161.0 catalog)

| Model | Tier | Use for | Start effort |
|---|---|---|---|
| `gpt-6-astra` | frontier | the hardest end-to-end work | low; raise when depth matters |
| `gpt-6.1-sol` | default | complex coding and agentic work, RFC implementation | medium; high when design-bound |
| `gpt-6-luna` | fast | clear, repeatable, narrowly scoped work; fast scans | high |

- `gpt-6-sol` and the `gpt-5.x` models are previous generations. `ultra` effort runs subagents of its own and counts as delegation.
- The vendor gives Luna to "clear, repeatable, or high-volume work" and 6.1 Sol to work that "needs planning, tool use, validation, and follow-through".
