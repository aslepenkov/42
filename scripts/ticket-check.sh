#!/usr/bin/env bash
# Parallel-safe checks for one ticket worktree: builds only, nothing binds a fixed port.
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.."

dotnet --list-sdks 2>/dev/null | grep -q '^10\.' ||
  { echo "ticket-check needs a host .NET 10 SDK." >&2; exit 1; }

dotnet build backend/src/Api/Api.csproj
for proj in backend/tests/*/*.csproj; do
  [ -e "$proj" ] && dotnet test "$proj"
done

npm --prefix frontend ci --prefer-offline --no-audit --no-fund
npm --prefix frontend run build
if npm --prefix frontend run | grep -q '^  test'; then
  npm --prefix frontend test
fi
printf '\nTicket checks passed.\n'
