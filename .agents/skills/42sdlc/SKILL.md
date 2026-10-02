---
name: 42sdlc
description: 42 Forge, closed loop. Same as 42sdlc-fast, but when verification fails it implements the filed bug tickets and re-verifies, up to 3 iterations, until the requested job is done.
disable-model-invocation: true
argument-hint: "<idea | T-001 [T-002 ...] | ticket path | feature name>"
---

Input (`$ARGUMENTS`): same as `42sdlc-fast`. Overview and diagrams: `docs/forge.md`.

1. Run steps 1–3 of `.agents/skills/42sdlc-fast/SKILL.md` (intake, build, check). Set `iteration = 1`.
2. **Loop** while the verifier returns `FAIL`, or tickets are blocked, and `iteration < 3`:
   1. Commit the new bug files: `docs(sdlc): bugs from <feature> verification #<iteration>`.
   2. For blocked tickets, read the recorded reason. If the ticket is under-specified, rewrite it with the missing detail and reset it to `status: todo`. If it needs a user decision, stop and ask.
   3. Run `.agents/skills/sdlc-ticket/SKILL.md` for the open bug files plus the reset tickets.
   4. Spawn `sdlc-verifier` again. It re-checks **all** acceptance criteria of the feature's tickets, not only the bugs, to catch regressions.
   5. `iteration += 1`.
3. **Finish.**
   - `PASS` → do step 4 of 42sdlc-fast (mark implemented, **DONE**).
   - Still failing after 3 iterations → **ESCALATE**. Report what still fails, which fixes were tried, and your best hypothesis for each failure. Leave the open bug files for the user.
4. Report as in 42sdlc-fast step 5, plus the iteration count. Never merge to main, push, or deploy.
