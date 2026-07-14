#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

[[ -f .env ]] || {
  echo ".env is missing. Copy .env.example to .env and set APP_BIND_IP." >&2
  exit 1
}

for secret in mysql_root_password mysql_app_password rabbitmq_user rabbitmq_password app_properties; do
  [[ -s "secrets/$secret" ]] || {
    echo "Missing secret: secrets/$secret. Run scripts/generate-secrets.sh." >&2
    exit 1
  }
done

sudo docker compose config --quiet
sudo docker compose up -d --build

printf '\nDeployment status:\n'
sudo docker compose ps
