#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="${1:-${PROJECT_ROOT}/backups/$(date -u +%Y%m%dT%H%M%SZ)}"
mkdir -p "$BACKUP_DIR"
cd "$PROJECT_ROOT"

# Logical MySQL backup. The root password is read without printing it.
sudo docker compose exec -T db01 sh -ec '
  MYSQL_PWD="$(cat /run/secrets/mysql_root_password)" \
  mysqldump -uroot --single-transaction --routines --events accounts
' > "$BACKUP_DIR/accounts.sql"

sudo docker run --rm \
  -v vprofile_rabbitmq_data:/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine:3.20 sh -c 'tar -czf /backup/rabbitmq-data.tar.gz -C /source .'

sudo docker run --rm \
  -v vprofile_elasticsearch_data:/source:ro \
  -v "$BACKUP_DIR":/backup \
  alpine:3.20 sh -c 'tar -czf /backup/elasticsearch-data.tar.gz -C /source .'

chmod 0600 "$BACKUP_DIR"/*
echo "Backup created at: $BACKUP_DIR"
