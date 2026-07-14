#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

sudo docker compose ps
printf '\nPublished host ports:\n'
sudo docker compose ps --format json 2>/dev/null || true
printf '\nApplication logs (last 80 lines):\n'
sudo docker compose logs --tail=80 app
