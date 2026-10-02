---
name: 42sdlc-fast
description: 42 Forge, single pass. From an idea, task, or existing ticket (docs/features/...) to spec, tickets, parallel worktree implementation with clean-context review, and one real verification. Reports DONE, or files bug tickets and stops.
disable-model-invocation: true
argument-hint: "<idea | T-001 [T-002 ...] | ticket path | feature name>"
---

Input (`$ARGUMENTS`): free-text idea/task, OR ticket/bug IDs or paths under `docs/features/` or `docs/bugs/`, OR a feature name to resume. Overview and diagrams: `docs/forge.md`.

1. **Intake.** Classify the input.
   - Idea/task/statement → run `.agents/skills/sdlc-spec/SKILL.md` (brainstorm, up to 10 questions, spec, tickets).
   - Ticket(s)/bug(s) → read them and their spec. If the spec is missing, write it from the ticket first, using the spec skill's steps 4–6.
   - Feature name → select that feature's tickets whose status is not `done`.
2. **Build.** Run `.agents/skills/sdlc-ticket/SKILL.md` for the selected tickets.
3. **Check.** Spawn `sdlc-verifier` with the feature, spec path, merged ticket IDs, and the next free bug number. It runs the real app and compares it with the acceptance criteria. Without subagent support, follow `.agents/agents/sdlc-verifier.md` yourself.
4. **Decide.**
   - `PASS` with no blocked tickets → set the spec `status: implemented` and commit `docs(sdlc): mark <feature> implemented`. Report **DONE**.
   - `FAIL` or blocked tickets → commit the new bug files as `docs(sdlc): bugs from <feature> verification`. Report **NOT DONE**. List each bug as a prepared unit of work: `/42sdlc-fast docs/bugs/B-xxx-....md`. Stop; do not loop.
5. **Report**, concisely:
   - feature branch
   - table of tickets and status
   - verification evidence per criterion
   - bugs and blocked items
   - limits
   - the user's next step: review `git log main..sdlc/<feature>`, then merge or open a PR. Nothing is merged to main automatically.
