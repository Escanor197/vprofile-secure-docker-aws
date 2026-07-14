#!/usr/bin/env bash
set -Eeuo pipefail

if [[ ${EUID} -ne 0 ]]; then
  exec sudo "$0" "$@"
fi

cat > /etc/sysctl.d/99-vprofile.conf <<'EOF'
vm.max_map_count=262144
EOF

sysctl --system >/dev/null

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed. Install Docker Engine and the Compose plugin first." >&2
  exit 1
fi

docker version >/dev/null
docker compose version >/dev/null

echo "Host prerequisites are ready."
