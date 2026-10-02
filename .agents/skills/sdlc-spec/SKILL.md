---
name: sdlc-spec
description: Turn a task, idea, or non-technical statement into a complete feature spec in docs/specs/ and atomic parallelizable tickets in docs/features/ on an sdlc/<feature> branch. Phase 1 of the 42sdlc flows.
---

1. **Understand.** Read `agents.md`, `architecture.md`, and the code the idea touches. Restate the idea in two sentences.
2. **Brainstorm.** List what is unknown: users, scenarios, data fields, validation, UI states, errors, limits, out of scope. Decide which unknowns change the result:
   - Ask the user up to **10 questions**, each with 2–4 concrete options and the recommended one first (batches of up to 4 when a question tool is available). Skip questions the code or conventions already answer.
   - Fill every remaining gap with a sensible default and record it under **Assumptions**.
3. **Name and branch.** Pick a kebab-case feature name. Run `bash scripts/sdlc-worktree.sh feature <name>` (creates or switches to `sdlc/<name>` in the main checkout).
4. **Specify.** Write `docs/specs/<name>.md` from `docs/specs/_TEMPLATE.md`. It must be complete enough that someone who never saw the conversation can build and verify it: every behavior, error, API contract, UI state, and numbered acceptance criterion (AC-x), each checkable in the running app. Set `status: approved`.
5. **Plan.** Find the next free ticket number (`ls docs/features docs/bugs`). Spawn the `sdlc-planner` subagent with the spec path and that number. Without subagent support, follow `.agents/agents/sdlc-planner.md` yourself. Check its output: each AC is covered, `depends_on` is acyclic, and no two independent tickets edit the same file.
6. **Commit** the spec and tickets on `sdlc/<name>`: `docs(sdlc): spec and tickets for <name>`.

Done: `sdlc/<name>` contains an approved spec and ticket files with valid frontmatter, and you can list the parallel waves.
