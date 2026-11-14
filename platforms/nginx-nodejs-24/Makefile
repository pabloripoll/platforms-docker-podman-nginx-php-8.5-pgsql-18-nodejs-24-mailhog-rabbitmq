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
ENGINE_PLTF := "NGINX + NODEJS 24"
ENGINE_LEAD := $(SERVICE_LEAD)
ENGINE_SLUG := $(SERVICE_SLUG)
ENGINE_CNET := $(SERVICE_CNET)
ENGINE_HOST := $(SERVICE_HOST)
ENGINE_IMGK := $(WEBAPP_IMGK)
ENGINE_CAAS := $(WEBAPP_CAAS)
ENGINE_PORT := $(WEBAPP_PORT)
ENGINE_BIND := $(WEBAPP_BIND)
ENGINE_CPUS := $(WEBAPP_CPUS)
ENGINE_MEMO := $(WEBAPP_MEMO)
ENGINE_SWAP := $(WEBAPP_SWAP)
ENGINE_USER := $(WEBAPP_USER)
ENGINE_GROUP := $(WEBAPP_GROUP)

# -------------------------------------------------------------------------------------------------
#  Help
# -------------------------------------------------------------------------------------------------
.PHONY: help

help: ## shows this Makefile help message
	@echo "Usage: $$ make "${C_GRN}"[target]"${C_END}
	@echo ${C_GRN}"Targets:"${C_END}
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
	@echo "COMPOSE_LEAD=$(ENGINE_LEAD)" > container/.env
	@echo "COMPOSE_SLUG=$(ENGINE_SLUG)" >> container/.env
	@echo "COMPOSE_CNET=$(ENGINE_CNET)" >> container/.env
	@echo "COMPOSE_IMGK=$(ENGINE_IMGK)" >> container/.env
	@echo "COMPOSE_CAAS=$(ENGINE_CAAS)" >> container/.env
	@echo "COMPOSE_HOST=$(ENGINE_HOST)" >> container/.env
	@echo "COMPOSE_PORT=$(ENGINE_PORT)" >> container/.env
	@echo "COMPOSE_BIND=\"$(ENGINE_BIND)\"" >> container/.env
	@echo "COMPOSE_CPUS=$(ENGINE_CPUS)" >> container/.env
	@echo "COMPOSE_MEMO=$(ENGINE_MEMO)" >> container/.env
	@echo "COMPOSE_SWAP=$(ENGINE_SWAP)" >> container/.env
	@echo "COMPOSE_USER=$(ENGINE_USER)" >> container/.env
	@echo "COMPOSE_GROUP=$(ENGINE_GROUP)" >> container/.env
	chmod +x container/config/ownerships.sh
	container/config/ownerships.sh $(ENGINE_USER) $(ENGINE_GROUP)
	@echo ${C_BLU}"$(SERVICE_NAME)"${C_END}" WEBAPP "${C_YEL}$(ENGINE_PLTF)${C_END}" .env file "${C_GRN}"has been set."${C_END};
	@echo "Directory..........: "${C_GRN}"platforms/$(DIR_BASENAME)"${C_END}
	@echo "Container name.....: "${C_GRN}$(ENGINE_CAAS)${C_END}
	@echo "Container image....: "${C_GRN}$(ENGINE_CAAS):$(ENGINE_IMGK)${C_END}
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
		echo ${C_YEL}"Image........: "${C_END}"$(ENGINE_CAAS):$(ENGINE_IMGK)"; \
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
	cd container && $(ENGINE_COMPOSE) -f docker-compose.yml -f docker-compose.public.yml up -d

build: ## builds and ensures changes in the Dockerfile, build steps, or copied-in files are applied. Not --no-recreate
	cd container && $(ENGINE_COMPOSE) -f docker-compose.yml -f docker-compose.public.yml up --build -d

network: ## starts up into an existing custom network for container-to-container communication, runnning in detached mode
	cd container && $(ENGINE_COMPOSE) -f docker-compose.yml -f docker-compose.network.yml up -d

host-gateway: ## starts up for container-to-host communication, runnning in detached mode
	cd container && $(ENGINE_COMPOSE) -f docker-compose.yml -f docker-compose.host-gateway.yml up -d

start: ## starts the container and put on running from latest configuration
	cd container && $(ENGINE_COMPOSE) start

stop: ## stops the running container but data will not be destroyed
	cd container && $(ENGINE_COMPOSE) stop

restart: ## restarts the running container
	cd container && $(ENGINE_COMMAND) restart $(ENGINE_CAAS)

clear: ## removes container from Docker running containers
	cd container && $(ENGINE_COMPOSE) kill || true
	cd container && $(ENGINE_COMPOSE) down --volumes --remove-orphans || true

destroy: ## delete container image from Docker cache
	cd container && $(ENGINE_COMMAND) rmi -f $(ENGINE_CAAS):$(ENGINE_IMGK)

dev: ## sets a development enviroment
	echo ${C_YEL}"\"dev\" recipe has not usage in this project"${C_END};

# -------------------------------------------------------------------------------------------------
#  Supervisord services management
# -------------------------------------------------------------------------------------------------
.PHONY: supervisord-conf supervisord-conf-update

supervisord-conf: ## lists supervisord services set on the running container
	$(ENGINE_COMMAND) exec -i $(ENGINE_CAAS) sh -c 'ls -l /etc/supervisor/conf.d/'

supervisord-update: ## updates supervisord services without the need of stoping or rebuilding the container
	$(ENGINE_COMMAND) cp container/config/supervisor/conf.d/. $(ENGINE_CAAS):/etc/supervisor/conf.d/
	$(MAKE) restart

# -------------------------------------------------------------------------------------------------
#  Nginx settings management
# -------------------------------------------------------------------------------------------------
.PHONY: nginx-conf nginx-update nginx-default-conf nginx-default-update

nginx-conf: ## shows nginx configuration set on the running container
	$(ENGINE_COMMAND) exec -i $(ENGINE_CAAS) sh -c 'cat /etc/nginx/nginx.conf'

nginx-update: ## updates nginx configuration without the need of stoping or rebuilding the container
	$(ENGINE_COMMAND) cp container/config/nginx/nginx.conf $(ENGINE_CAAS):/etc/nginx/nginx.conf

nginx-default-conf: ## shows nginx default server block set on the running container
	$(ENGINE_COMMAND) exec -i $(ENGINE_CAAS) sh -c 'cat /etc/nginx/conf.d/default.conf'

nginx-default-update: ## updates nginx default server block without the need of stoping or rebuilding the container
	$(ENGINE_COMMAND) cp container/config/nginx/conf.d/default.conf $(ENGINE_CAAS):/etc/nginx/conf.d/default.conf
