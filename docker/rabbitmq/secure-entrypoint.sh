#!/usr/bin/env bash
set -Eeuo pipefail

readonly USER_FILE="/run/secrets/rabbitmq_user"
readonly PASSWORD_FILE="/run/secrets/rabbitmq_password"

[[ -r "$USER_FILE" ]] || { echo "RabbitMQ user secret is not readable" >&2; exit 1; }
[[ -r "$PASSWORD_FILE" ]] || { echo "RabbitMQ password secret is not readable" >&2; exit 1; }

export RABBITMQ_DEFAULT_USER="$(cat "$USER_FILE")"
export RABBITMQ_DEFAULT_PASS="$(cat "$PASSWORD_FILE")"

exec /usr/local/bin/docker-entrypoint.sh "$@"
