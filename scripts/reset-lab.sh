#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

cat <<'EOF'
WARNING: This deletes the MySQL, RabbitMQ, and Elasticsearch Docker volumes.
All application data will be permanently removed.
EOF
read -r -p "Type DELETE to continue: " confirmation
[[ "$confirmation" == "DELETE" ]] || { echo "Cancelled."; exit 1; }

sudo docker compose down --volumes --remove-orphans
echo "Stack and persistent volumes removed."
