SHELL := /usr/bin/env bash
DC := sudo docker compose

.PHONY: prepare secrets validate build up down restart status logs backup clean

prepare:
	./scripts/prepare-host.sh

secrets:
	./scripts/generate-secrets.sh

validate:
	$(DC) config --quiet
	bash -n scripts/*.sh docker/rabbitmq/secure-entrypoint.sh

build:
	$(DC) build --pull

up:
	./scripts/deploy.sh

down:
	$(DC) down

restart:
	$(DC) restart

status:
	./scripts/status.sh

logs:
	$(DC) logs -f app

backup:
	./scripts/backup-volumes.sh

clean:
	./scripts/reset-lab.sh
