---
name: sdlc-ticket
description: Run the per-ticket pipeline for one or more tickets or bug files - worktree, implement (cheap model), clean-context review, commit, merge into sdlc/<feature>. Phase 2 of the 42sdlc flows.
---

Input: ticket IDs or paths (`T-xxx`, `B-xxx`). All tickets must share one `feature`.

**Prepare.** Run `bash scripts/sdlc-worktree.sh feature <feature>` so the main checkout is on `sdlc/<feature>` (commit ticket files there first if they are new). Skip tickets with `status: done`.

**Schedule waves.** Order tickets by `depends_on`. A wave is every ticket whose dependencies are merged. Run each wave in parallel, one pipeline per ticket, and wait for the whole wave to merge before starting the next.

**Pipeline per ticket** (orchestrator = you; subagents cannot spawn subagents):
1. `WT=$(bash scripts/sdlc-worktree.sh start <ID>)`. It creates `.worktrees/<ID>` on `ticket/<ID>-<slug>`, branched from `sdlc/<feature>`.
2. **Implement.** Spawn `sdlc-implementer` (Haiku) with the ID and `WT`. Launch all tickets in the wave in the same message so they run in parallel. `BLOCKED` → mark the ticket `status: blocked`, record why, and continue without it.
3. **Review.** Spawn a fresh `sdlc-reviewer` with the ID, `WT`, and `BASE=sdlc/<feature>`. Never pass it the implementer's reasoning. `CHANGES_REQUESTED` → send the findings to a new `sdlc-implementer` for the same `WT`, then review again. After 2 failed review rounds, mark the ticket `blocked` and report it.
4. **Commit.** Set the ticket `status: done` in `WT`, then run `bash scripts/sdlc-worktree.sh commit <ID> "<type(scope): description>"`, using the implementer's proposed message.
5. **Merge.** Run `bash scripts/sdlc-worktree.sh merge <ID>`. Merge tickets one at a time, in ID order. Exit code 2 means a conflict. Spawn `sdlc-implementer` with: "merge `sdlc/<feature>` into this worktree, resolve the conflicts, rerun ticket-check, commit the merge". Then re-review and merge again.

Without subagent support, perform each role yourself from `.agents/agents/<role>.md`, sequentially, and re-read the diff with fresh eyes before approving.

Never merge `sdlc/<feature>` into `main`, push, or deploy. That is the user's gate.

Done: every non-blocked ticket is merged into `sdlc/<feature>` with `status: done`, its worktree and branch are removed, and blocked tickets are listed with reasons.
