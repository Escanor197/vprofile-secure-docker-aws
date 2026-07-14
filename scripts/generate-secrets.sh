#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  if command -v sudo >/dev/null 2>&1; then
    exec sudo --preserve-env=PATH "$0" "$@"
  fi
  echo "Run this script as root so secret ownership can be applied securely." >&2
  exit 1
fi

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SECRETS_DIR="${PROJECT_ROOT}/secrets"

command -v openssl >/dev/null 2>&1 || {
  echo "openssl is required." >&2
  exit 1
}

install -d -m 0700 -o root -g root "$SECRETS_DIR"

MYSQL_ROOT_PASSWORD="$(openssl rand -hex 32)"
MYSQL_APP_PASSWORD="$(openssl rand -hex 32)"
RABBITMQ_USER="vprofile_app"
RABBITMQ_PASSWORD="$(openssl rand -hex 32)"

printf '%s' "$MYSQL_ROOT_PASSWORD" > "$SECRETS_DIR/mysql_root_password"
printf '%s' "$MYSQL_APP_PASSWORD" > "$SECRETS_DIR/mysql_app_password"
printf '%s' "$RABBITMQ_USER" > "$SECRETS_DIR/rabbitmq_user"
printf '%s' "$RABBITMQ_PASSWORD" > "$SECRETS_DIR/rabbitmq_password"

cat > "$SECRETS_DIR/app_properties" <<EOF
# JDBC configuration
jdbc.driverClassName=com.mysql.cj.jdbc.Driver
jdbc.url=jdbc:mysql://db01:3306/accounts?useUnicode=true&characterEncoding=UTF-8&zeroDateTimeBehavior=CONVERT_TO_NULL&sslMode=REQUIRED&allowPublicKeyRetrieval=false
jdbc.username=vprofile_app
jdbc.password=${MYSQL_APP_PASSWORD}

# Memcached configuration
memcached.active.host=mc01
memcached.active.port=11211
memcached.standBy.host=mc01
memcached.standBy.port=11211

# RabbitMQ configuration
rabbitmq.address=rmq01
rabbitmq.port=5672
rabbitmq.username=${RABBITMQ_USER}
rabbitmq.password=${RABBITMQ_PASSWORD}
rabbitmq.vhost=/vprofile

# Elasticsearch configuration
elasticsearch.host=vprosearch01
elasticsearch.port=9300
elasticsearch.cluster=vprofile
elasticsearch.node=vprofilenode
EOF

# MySQL and RabbitMQ entrypoints read their secrets while starting as root.
chown root:root \
  "$SECRETS_DIR/mysql_root_password" \
  "$SECRETS_DIR/mysql_app_password" \
  "$SECRETS_DIR/rabbitmq_user" \
  "$SECRETS_DIR/rabbitmq_password"
chmod 0400 \
  "$SECRETS_DIR/mysql_root_password" \
  "$SECRETS_DIR/mysql_app_password" \
  "$SECRETS_DIR/rabbitmq_user" \
  "$SECRETS_DIR/rabbitmq_password"

# The application runs as UID/GID 10001 and requires group read access.
chown root:10001 "$SECRETS_DIR/app_properties"
chmod 0440 "$SECRETS_DIR/app_properties"

printf '%s\n' \
  "Secrets generated successfully." \
  "Directory: $SECRETS_DIR" \
  "Application secret ownership: root:10001 mode 0440" \
  "Other secrets: root:root mode 0400" \
  "Do not commit the secrets directory."
