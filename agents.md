# Repository Agent Instructions

## Project

A single-file .NET 10 Minimal API (`backend/src/Api/Program.cs`, Swagger at `/swagger`) and a Vite + React frontend (`frontend/`) that calls it. Structure and deployment are in `architecture.md`; the agent workflow is in `docs/forge.md`.

## Workflow

- Keep the backend to what the spec asks for. Do not add dependencies a ticket does not name.
- Use conventional commits: `type(scope): description`.
- Run the checks with `bash scripts/ticket-check.sh` (needs a host .NET 10 SDK and Node 20.19+).
- Start the backend (`dotnet run` in `backend/src/Api`, or the Docker command in `README.md`) and the frontend (`npm run dev` in `frontend`), then exercise the changed behavior for real. Report the exact checks and any limits.
- Treat `.env` files and deployment secrets as private. Never deploy, push, or merge into `main` as a side effect of other work. Deployment is only `.github/workflows/deploy.yml`, after CI passes on `main`.

## Forge

- Full cycle from an idea or ticket: `/42sdlc-fast` (one pass) or `/42sdlc` (loops on bugs, up to 3 times).
- Skills: `.agents/skills/` (`sdlc-spec`, `sdlc-ticket`, `42sdlc`, `42sdlc-fast`). Roles: `.agents/agents/`.
- Specs live in `docs/specs/`, tickets in `docs/features/`, bugs in `docs/bugs/` (each folder has a `_TEMPLATE.md`).
