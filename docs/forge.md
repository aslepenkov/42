# 42 Forge

A strong model turns an idea into a complete spec and atomic tickets. Cheap models implement the tickets in parallel, each in an isolated git worktree. Every change is reviewed by a clean-context reviewer before it merges. A verifier then runs the real app against the acceptance criteria and turns any failure into a new bug ticket. `/42sdlc-fast` does one pass and reports. `/42sdlc` loops on the bug tickets until the job is done, up to 3 iterations. Nothing reaches `main` without a human.

## Commands

| Command | Input | Behavior |
|---|---|---|
| `/42sdlc-fast <input>` | idea text, `T-001 T-002`, `docs/bugs/B-001-x.md`, or feature name | One pass: build and verify. Reports DONE, or files bugs and stops. |
| `/42sdlc <input>` | same | Same, then fixes the filed bugs and re-verifies, up to 3 iterations, then escalates. |

Building blocks: `sdlc-spec` (phase 1) and `sdlc-ticket` (phase 2) skills.

## Roles

| Role | Where | Model | Job |
|---|---|---|---|
| Orchestrator | your session | session model | Brainstorm with the user, write the spec, schedule waves, commit and merge |
| `sdlc-planner` | `.agents/agents/` | opus | Spec → atomic tickets with `depends_on` |
| `sdlc-implementer` | `.agents/agents/` | haiku | One ticket, one worktree, `scripts/ticket-check.sh` |
| `sdlc-reviewer` | `.agents/agents/` | sonnet | Clean-context, read-only review → APPROVE / CHANGES_REQUESTED |
| `sdlc-verifier` | `.agents/agents/` | sonnet | Real run (build, start backend and frontend, curl, browser if available) → PASS / FAIL + bug files |

## The whole forge

```
 INPUT                         THINK (strong model)                BUILD (cheap models, parallel)
 ─────                         ────────────────────                ──────────────────────────────
 idea / task / plain text ──► ┌──────────────┐   ┌─────────────┐   ┌──────────┐ ┌──────────┐
                              │  BRAINSTORM  │──►│ docs/specs/ │──►│ T-001.md │ │ T-002.md │ ...
                              │ ≤10 Qs with  │   │ <feature>.md│   │ atomic   │ │ atomic   │
                              │   options    │   └─────────────┘   └────┬─────┘ └────┬─────┘
                              └──────────────┘                         │            │
 docs/features/T-xxx.md / docs/bugs/B-xxx.md ──────────────────────────────────►│            │
                                                                       ▼            ▼
                                                               ┌────────────────────────────┐
                                                               │ TICKET PIPELINE (x N, ||)  │
                                                               └─────────────┬──────────────┘
                                                                             ▼
                                                               ┌────────────────────────────┐
                                                               │ VERIFY: run app, compare   │
                                                               │ with acceptance criteria   │
                                                               └──────┬──────────────┬──────┘
                                                                  OK  │              │ NOT OK
                                                                      ▼              ▼
                                                                 REPORT DONE   docs/bugs/B-xxx.md
                                                                               (new unit of work)
```

## Pipeline for one ticket

```
 T-001.md (on sdlc/<feature>)
    │
    ▼
 scripts/sdlc-worktree.sh start T-001  ──►  .worktrees/T-001  on  ticket/T-001-<slug>
    │
    ▼
 sdlc-implementer (haiku) ──► code + test ──► scripts/ticket-check.sh ──► status: in-review
    │
    ▼
 sdlc-reviewer (fresh context) ── CHANGES_REQUESTED ──► implementer fix ──┐  (max 2 rounds,
    │ APPROVE                                     ▲                       │   then blocked)
    │                                             └───────────────────────┘
    ▼
 status: done ──► sdlc-worktree.sh commit T-001 "feat(scope): ..."
    │
    ▼
 sdlc-worktree.sh merge T-001 ──► sdlc/<feature>  (--no-ff; removes worktree + branch)
                                  conflict? → implementer merges base into worktree → re-review
```

## Waves (parallelism)

```
 depends_on:  T-001: []   T-002: []   T-003: [T-001]   T-004: [T-001, T-002]

 wave 1:  T-001 ║ T-002          (parallel worktrees, parallel implementers)
            └──────┬──────┘
               merge in ID order
 wave 2:  T-003 ║ T-004
```

## fast compared with standard

```
 /42sdlc-fast (single pass)                 /42sdlc (loop until done)
 ──────────────────────────                 ──────────────────────────────────
 input?                                     input?
  ├─ idea   → brainstorm → spec → tickets    ├─ same as fast
  └─ ticket → (skip)                         │
        ▼                                    ▼
   implement tickets                    ┌─► implement tickets / bugs
        ▼                               │        ▼
      verify                            │      verify (all criteria again)
     ┌──┴───┐                           │     ┌──┴───┐
    OK     NOT OK                       │    OK    NOT OK
     ▼       ▼                          │     ▼      ▼
   DONE   file bug B-xxx                │   DONE   file bug B-xxx
          report & STOP                 └──────────────┘
                                        after 3 iterations → ESCALATE to user
```

## Branches and files

```
 main ──────────────────────────────────────────────── (human merges / PR)
   └── sdlc/<feature>        spec + tickets + merged work (integration branch)
         ├── ticket/T-001-<slug>   in .worktrees/T-001   (deleted after merge)
         └── ticket/B-001-<slug>   in .worktrees/B-001

 docs/specs/<feature>.md          full spec (template: docs/specs/_TEMPLATE.md)
 docs/features/T-NNN-<slug>.md    tickets   (template: docs/features/_TEMPLATE.md)
 docs/bugs/B-NNN-<slug>.md        bugs      (template: docs/bugs/_TEMPLATE.md)
```

Ticket `status` goes: `todo → in-progress → in-review → done`. A ticket that can't proceed becomes `blocked`, with the reason recorded.

## Checks

- **Per ticket, parallel-safe:** `bash scripts/ticket-check.sh`. It builds the backend, runs any backend tests, then installs and builds the frontend. It starts nothing on a fixed port, so worktrees don't fight over ports.
- **Per feature, serialized:** start the backend and frontend, then real API and browser checks. The verifier runs these from the main checkout on `sdlc/<feature>`.

## Human gate and limits

- The flows never merge into `main`, push, or deploy. At the end, review `git log main..sdlc/<feature>` and merge the branch or open a PR yourself.
- `ticket-check.sh` needs a host .NET 10 SDK and Node 24.
- Subagent roles and model routing are Claude Code specific. Codex, Cursor and other agents run the same skills sequentially, reading each role's instructions from `.agents/agents/<role>.md`.
- Deployment (`.github/workflows/deploy.yml`) runs only from CI on `main`, never from these flows.
- Jira is not integrated yet. Tickets are local markdown files.
