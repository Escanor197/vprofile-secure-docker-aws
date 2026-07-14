FROM mysql:8.0.33

LABEL org.opencontainers.image.title="VProfile MySQL" \
      org.opencontainers.image.description="MySQL database initialized with the VProfile schema"

# Passwords are supplied at runtime through Compose secrets.
COPY database/db_backup.sql /docker-entrypoint-initdb.d/01-db_backup.sql
