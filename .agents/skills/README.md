# Shared Skills

Each directory contains a portable `SKILL.md` with `name` and `description` frontmatter.

- `42sdlc-fast` / `42sdlc`: 42 Forge: idea or ticket → spec → parallel worktree tickets → review → verify; single pass or loop until done. See `docs/forge.md`.
- `sdlc-spec`: brainstorm, write `docs/specs/<feature>.md`, cut tickets into `docs/features/`.
- `sdlc-ticket`: per-ticket worktree → implement → clean review → commit → merge into `sdlc/<feature>`.

SDLC role subagents (`sdlc-planner`, `sdlc-implementer`, `sdlc-reviewer`, `sdlc-verifier`) live in `.agents/agents/`. Other agents read those files as role instructions.
