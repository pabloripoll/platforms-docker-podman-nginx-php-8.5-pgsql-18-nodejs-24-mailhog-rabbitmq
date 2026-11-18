# This Makefile requires GNU Make.
MAKEFLAGS += --silent

# Linux / macOS / WSL2 codes for rendering colors
C_BLU := '\033[0;34m'
C_GRN := '\033[0;32m'
C_RED := '\033[0;31m'
C_YEL := '\033[0;33m'
C_END := '\033[0m'

DIR_ROOT=$(patsubst %/,%,$(dir $(realpath $(firstword $(MAKEFILE_LIST)))))
DIR_BASENAME=$(shell basename $(DIR_ROOT))

# Root environment constants
include ../../.env

# Container environment variables
ENGINE_PLTF := "POSTGRES 18+"
ENGINE_LEAD := $(SERVICE_LEAD)
ENGINE_SLUG := $(SERVICE_SLUG)
ENGINE_CNET := $(SERVICE_CNET)
ENGINE_HOST := $(SERVICE_HOST)
ENGINE_IMGK := $(DATABASE_IMGK)
ENGINE_CAAS := $(DATABASE_CAAS)
ENGINE_PORT := $(DATABASE_PORT)
ENGINE_BIND := $(DATABASE_BIND)
ENGINE_CPUS := $(DATABASE_CPUS)
ENGINE_MEMO := $(DATABASE_MEMO)
ENGINE_SWAP := $(DATABASE_SWAP)
ENGINE_DATA := $(DATABASE_DATA)
ENGINE_LOGS := $(DATABASE_LOGS)
SQL_ROOT := $(DATABASE_ROOT)
SQL_NAME := $(DATABASE_NAME)
SQL_USER := $(DATABASE_USER)
SQL_PASS := $(DATABASE_PASS)

# Default to docker-compose.dockerhub.yml if ENGINE_IMGK is empty or "dockerhub"
ifeq ($(filter-out dockerhub,$(ENGINE_IMGK)),)
	ENGINE_IMGK := postgres:18-alpine3.24
    COMPOSE_BASE_SCRIPT := docker-compose.dockerhub.yml
else
    COMPOSE_BASE_SCRIPT := docker-compose.yml
endif

# -------------------------------------------------------------------------------------------------
#  Help
# -------------------------------------------------------------------------------------------------
.PHONY: help

help: ## shows this Makefile help message
	echo "Usage: $$ make "${C_GRN}"[target]"${C_END}
	echo ${C_GRN}"Targets:"${C_END}
	awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z0-9_-]+:.*?## / {printf "$$ make \033[0;33m%-30s\033[0m %s\n", $$1, $$2}' ${MAKEFILE_LIST} | column -t -c 2 -s ':#'

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: hostcheck

hostcheck: ## shows this project port availability on local machine
	if [ -f ./container/.env ]; then \
		echo "Checking configuration for "${C_YEL}"$(ENGINE_CAAS)"${C_END}" container:"; \
		if [ -z "$($(ENGINE_COMMAND) lsof -i :$(ENGINE_PORT))" ]; then \
			echo ${C_GRN}"$(ENGINE_CAAS)"${C_END}" can be served at 127.0.0.1:"${C_GRN}"$(ENGINE_PORT) (is free to use)."${C_END}; \
		else \
			echo ${C_RED}"$(ENGINE_CAAS)"${C_END}" can't be served at 127.0.0.1:"${C_RED}"$(ENGINE_PORT) (is busy)."${C_END}; \
			echo ${C_YEL}"Update container configuration."${C_END}; \
		fi \
	else \
		echo ${C_RED}"$(SERVICE_NAME) - Platform $(ENGINE_PLTF): Environment file does not exist!"${C_END}; \
		echo ${C_YEL}"Create it with Makefile recipe or copy the platform's container/.env.example"${C_END}; \
	fi

# -------------------------------------------------------------------------------------------------
#  Enviroment
# -------------------------------------------------------------------------------------------------
.PHONY: env-set

env-set: ## sets container .env file
	@echo "COMPOSE_LEAD=$(ENGINE_LEAD)" > ./container/.env
	@echo "COMPOSE_SLUG=$(ENGINE_SLUG)" >> container/.env
	@echo "COMPOSE_CNET=$(ENGINE_CNET)" >> ./container/.env
	@echo "COMPOSE_IMGK=$(ENGINE_IMGK)" >> ./container/.env
	@echo "COMPOSE_CAAS=$(ENGINE_CAAS)" >> ./container/.env
	@echo "COMPOSE_HOST=$(ENGINE_HOST)" >> ./container/.env
	@echo "COMPOSE_PORT=$(ENGINE_PORT)" >> ./container/.env
	@echo "COMPOSE_CPUS=$(ENGINE_CPUS)" >> ./container/.env
	@echo "COMPOSE_MEMO=$(ENGINE_MEMO)" >> ./container/.env
	@echo "COMPOSE_SWAP=$(ENGINE_SWAP)" >> ./container/.env
	@echo "COMPOSE_DATA=\"$(ENGINE_DATA)\"" >> ./container/.env
	@echo "COMPOSE_LOGS=\"$(ENGINE_LOGS)\"" >> ./container/.env
	@echo "POSTGRES_DATABASE=$(SQL_NAME)" >> ./container/.env
	@echo "POSTGRES_USER=$(SQL_USER)" >> ./container/.env
	@echo "POSTGRES_PASSWORD=\"$(SQL_PASS)\"" >> ./container/.env
	@echo ${C_BLU}"$(SERVICE_NAME)"${C_END}" DATABASE "${C_YEL}$(ENGINE_PLTF)${C_END}" .env file "${C_GRN}"has been set."${C_END};
	@echo "Directory..........: "${C_GRN}"platforms/$(DIR_BASENAME)"${C_END}
	@echo "Container name.....: "${C_GRN}$(ENGINE_CAAS)${C_END}
	@echo "Container image....: "${C_GRN}$(ENGINE_IMGK)${C_END}
	@echo "Max. CPUs..........: "${C_GRN}$(ENGINE_CPUS)${C_END}
	@echo "Max. memory / Swap.: "${C_GRN}$(ENGINE_MEMO)${C_END}" / "${C_GRN}$(ENGINE_SWAP)${C_END}
	@echo "Localhost..........: 127.0.0.1:"${C_GRN}"$(ENGINE_PORT)"${C_END};
	@echo "Hostname...........: $(word 1,$(shell hostname -I)):"${C_GRN}"$(ENGINE_PORT)"${C_END};

# -------------------------------------------------------------------------------------------------
#  Container
# -------------------------------------------------------------------------------------------------
.PHONY: info ssh up build network start stop restart clear destroy dev

info: ## shows container information
	if [ -f ./container/.env ]; then \
		echo ${C_YEL}"Project......: "${C_END}"$(SERVICE_NAME)"; \
		echo ${C_YEL}"Platform.....: "${C_END}"$(ENGINE_PLTF)"; \
		echo ${C_YEL}"Directory....: "${C_END}"platforms/$(DIR_BASENAME)"; \
		CID=$$($(ENGINE_COMMAND) ps -aqf "name=^$(ENGINE_CAAS)$$"); echo ${C_YEL}"Container ID.: "${C_END}"$${CID:-null}"; \
		echo ${C_YEL}"Name.........: "${C_END}"$(ENGINE_CAAS)"; \
		echo ${C_YEL}"Image........: "${C_END}"$(ENGINE_IMGK)"; \
		echo ${C_YEL}"CPUs.........: "${C_END}"$(ENGINE_CPUS)"; \
		echo ${C_YEL}"RAM..........: "${C_END}"$(ENGINE_MEMO)"; \
		echo ${C_YEL}"SWAP.........: "${C_END}"$(ENGINE_SWAP)"; \
		echo ${C_YEL}"Host.........: "${C_END}"$(ENGINE_HOST):$(ENGINE_PORT)"; \
		echo ${C_YEL}"Hostname.....: "${C_END}"$(word 1,$(shell hostname -I)):"$(ENGINE_PORT); \
		DIP=$$($(ENGINE_COMMAND) inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(ENGINE_CAAS) 2>/dev/null); echo ${C_YEL}"Docker.Host..: "${C_END}"$${DIP:-null}"; \
		NID=$$($(ENGINE_COMMAND) inspect -f '{{range.NetworkSettings.Networks}}{{.NetworkID}}{{end}}' $(ENGINE_CAAS) 2>/dev/null); echo ${C_YEL}"NetworkID....: "${C_END}"$${NID:-null}"; \
	else \
		echo ${C_RED}"$(SERVICE_NAME) - Platform $(ENGINE_PLTF): Environment file does not exist!"${C_END}; \
		echo ${C_YEL}"Create it with Makefile recipe or copy the platform's container/.env.example"${C_END}; \
	fi

ssh: ## enters the container shell
	$(ENGINE_COMMAND) exec -it $(ENGINE_CAAS) sh

up: ## starts and recreates containers if compose config or image changed, runnning in detached mode
	cd container && $(ENGINE_COMPOSE) -f $(COMPOSE_BASE_SCRIPT) -f docker-compose.public.yml up -d

build: ## builds and ensures changes in the Dockerfile, build steps, or copied-in files are applied. Not --no-recreate
	cd container && $(ENGINE_COMPOSE) -f $(COMPOSE_BASE_SCRIPT) -f docker-compose.public.yml up --build -d

network: ## starts up into an existing custom network for container-to-container communication, runnning in detached mode
	cd container && $(ENGINE_COMPOSE) -f $(COMPOSE_BASE_SCRIPT) -f docker-compose.network.yml up -d

start: ## starts the container and put on running from latest configuration
	cd container && $(ENGINE_COMPOSE) start

stop: ## stops the running container but data will not be destroyed
	cd container && $(ENGINE_COMPOSE) stop

restart: ## restarts the running container
	cd container && $(ENGINE_COMMAND) restart $(ENGINE_CAAS)

clear: ## removes container from Docker running containers
	cd container && $(ENGINE_COMPOSE) kill || true
	cd container && $(ENGINE_COMPOSE) down --volumes --remove-orphans || true

destroy: ## delete container image from Docker cache - $(ENGINE_IMGK)
	cd container && $(ENGINE_COMMAND) rmi -f $(ENGINE_IMGK)
	$(SUDO) rm -rf ./root
	$(SUDO) rm -rf $(ENGINE_DATA)
	$(SUDO) rm -rf $(ENGINE_LOGS)

dev: ## sets a development enviroment
	echo ${C_YEL}"\"dev\" recipe has not usage in this project"${C_END};

# -------------------------------------------------------------------------------------------------
#  Testing Database
# -------------------------------------------------------------------------------------------------

.PHONY: test-up test-down

test-up: ## creates a side database for testing porpuses
	$(ENGINE_COMMAND) exec -it $(ENGINE_CAAS) sh -c 'dropdb -f $(DATABASE_NAME)_testing -U "$(DATABASE_USER)"; createdb $(DATABASE_NAME)_testing -U "$(DATABASE_USER)"';

test-down: ## drops the side testing database
	$(ENGINE_COMMAND) exec -it $(ENGINE_CAAS) sh -c 'dropdb -f $(DATABASE_NAME)_testing -U "$(DATABASE_USER)";';

# -------------------------------------------------------------------------------------------------
#  PostgreSQL | directory path is defined in root .env file, e.g.: ./../../resources/database/
# -------------------------------------------------------------------------------------------------

.PHONY: sql-install sql-replace sql-backup sql-remote copy-remote

sql-install: ## migrates sql file with schema / data into the container main database to init a project
	$(ENGINE_COMMAND) exec -i $(ENGINE_CAAS) sh -c 'psql -d $(DATABASE_NAME) -U "$(DATABASE_USER)"' < $(DIR_ROOT)$(DATABASE_PATH)$(DATABASE_INIT)
	echo ${C_YEL}"$(SERVICE_NAME) DATABASE"${C_END}" has been copied to container from "${C_BLU}"$(DATABASE_PATH)$(DATABASE_INIT)"${C_END}

sql-replace: ## replaces the container main database with the latest database .sql backup file
	$(ENGINE_COMMAND) exec -i $(ENGINE_CAAS) sh -c 'psql -d $(DATABASE_NAME) -U "$(DATABASE_USER)"' < $(DIR_ROOT)$(DATABASE_PATH)$(DATABASE_BACK)
	echo ${C_YEL}"$(SERVICE_NAME) DATABASE"${C_END}" has been replaced from "${C_BLU}"$(DATABASE_PATH)$(DATABASE_BACK)"${C_END}

sql-backup: ## copies the container main database as backup into a .sql file
	[ -d .$(DATABASE_PATH)$(DATABASE_BACK) ] || touch .$(DATABASE_PATH)$(DATABASE_BACK)
	$(ENGINE_COMMAND) exec $(ENGINE_CAAS) sh -c 'pg_dump -d $(DATABASE_NAME) -U "$(DATABASE_USER)"' > $(DIR_ROOT)$(DATABASE_PATH)$(DATABASE_BACK)
	echo ${C_YEL}"$(SERVICE_NAME) DATABASE"${C_END}" backup has been created at "${C_BLU}"$(DATABASE_PATH)$(DATABASE_BACK)"${C_END}

sql-drop: ## drops the container main database but recreates the database without schema as a reset action
	$(ENGINE_COMMAND) exec -i $(ENGINE_CAAS) sh -c 'dropdb -f $(DATABASE_NAME) -U "$(DATABASE_USER)"; createdb $(DATABASE_NAME) -U "$(DATABASE_USER)"'
	echo ${C_YEL}"$(SERVICE_NAME) DATABASE"${C_END}" in container "${C_YEL}"$(ENGINE_CAAS)"${C_END}" has been deleted."
