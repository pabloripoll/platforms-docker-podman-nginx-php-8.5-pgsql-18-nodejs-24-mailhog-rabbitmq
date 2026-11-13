# This Makefile requires GNU Make for Windows (e.g., from Chocolatey or winget).
MAKEFLAGS += --silent

# Force Make to use cmd.exe as its shell context on Windows
SHELL := cmd.exe

# Native PowerShell wrapper to safely print with colors on Windows
PRINT_CMD = powershell -NoProfile -Command "Write-Host"
C_RED := "-ForegroundColor Red"
C_YEL := "-ForegroundColor Yellow"
C_BLU := "-ForegroundColor Cyan"
C_GRN := "-ForegroundColor Green"

# Environment constants
include .env

# Helpers (Windows equivalents for paths)
DIR_ROOT := $(CURDIR)
# Grabs the current folder name using PowerShell
DIR_BASENAME := $(shell powershell -NoProfile -Command "(Get-Item .).Name")

# -------------------------------------------------------------------------------------------------
#  Help
# -------------------------------------------------------------------------------------------------
.PHONY: help

help: ## shows this Makefile help message
	@$(PRINT_CMD) "Usage: $$ make [target]" $(C_GRN)
	@$(PRINT_CMD) "Targets:" $(C_GRN)
	@powershell -NoProfile -Command "\
		Select-String -Path '$(MAKEFILE_LIST)' -Pattern '^[a-zA-Z0-9_-]+:.*?## ' | ForEach-Object { \
			if ($$_.Line -match '^([a-zA-Z0-9_-]+):.*?## (.*)$$') { \
				Write-Host ('$$ make ' + $$Matches[1].PadRight(30)) -NoNewline -ForegroundColor Yellow; \
				Write-Host $$Matches[2] \
			} \
		}"

# -------------------------------------------------------------------------------------------------
#  System
# -------------------------------------------------------------------------------------------------
.PHONY: local-info local-ownership local-ownership-set

# Windows equivalent to get the local IPv4 address
local_ip := $(shell powershell -NoProfile -Command "(Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias 'Wi-Fi', 'Ethernet' | Select-Object -First 1).IPAddress")
local-info: ## shows local machine ip and container ports set
	@$(PRINT_CMD) "Local IP / Hostname:" $(C_BLU) -NoNewline; $(PRINT_CMD) " $(local_ip)" $(C_YEL)

# Windows permissions differ from Linux chown; these targets display the current user account context
user := $(USERNAME)
local-ownership: ## shows local ownership context
	@echo $(user)

local-ownership-set: ## sets directory permissions (Windows icacls equivalent)
	@echo Setting permissions via icacls...
	icacls "$(DIR_ROOT)" /grant "$(user):(OI)(CI)F" /T /Q

# -------------------------------------------------------------------------------------------------
#  Networking
# -------------------------------------------------------------------------------------------------
.PHONY: network-exists network-create network-info network-destroy

network-exists: ## lists all local networks
	$(ENGINE) network ls

network-create: ## creates network
	$(ENGINE) network create --driver bridge $(SERVICE_LEAD)-$(SERVICE_CNET)

network-info: ## shows network information
	$(ENGINE) network inspect $(SERVICE_LEAD)-$(SERVICE_CNET) --format "{{json .Containers}}"

network-destroy: ## destroys network
	$(ENGINE) network rm $(SERVICE_LEAD)-$(SERVICE_CNET)

# -------------------------------------------------------------------------------------------------
#  Frontend Application Service
# -------------------------------------------------------------------------------------------------
.PHONY: web-hostcheck web-info web-set web-build web-create web-network web-host-gateway web-ssh web-start web-stop web-restart web-down web-destroy

web-hostcheck: ## shows this project ports availability on local machine for the container
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) port-check

web-info: ## shows the ENGINE related information
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) info

web-set: ## sets the enviroment file to build the container
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) env-set

web-build: ## builds and ensures changes in the ENGINEfile, build steps, or copied-in files are applied
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) build

web-create: ## starts up or creates the container for running in detached mode
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) up

web-network: ## starts up into an existing custom network for container-to-container communication, runnning in detached mode
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) clear network

web-host-gateway: ## starts up for container-to-host communication, runnning in detached mode
	$(MAKE) web-stop
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) clear host-gateway

web-ssh: ## enters the container shell
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) ssh

web-start: ## starts the container running
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) start

web-stop: ## stops the container but its assets will not be destroyed
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) stop

web-restart: ## restarts the running container
	cd ./platforms/$(WEBAPP_PLTF) && $(MAKE) restart

web-down: ## stops and removes the container, network and volume established
	@powershell -NoProfile -Command "\
		Write-Host 'Attention!' $(C_RED); \
		Write-Host \"You're about to stop and remove the $(WEBAPP_PLTF) container with its network and volume.\" $(C_YEL); \
		$$r = Read-Host 'Are you sure to proceed? [y/n]'; \
		if ($$r -eq 'y') { \
			Set-Location './platforms/$(WEBAPP_PLTF)'; \
			$(MAKE) clear; \
			Write-Host \"O.K.! $(ENGINE) cache has been cleared up.\" $(C_GRN); \
		} else { \
			Write-Host 'O.K.! container continues with its latest status.' $(C_GRN); \
		}"

web-destroy: ## destroys completely the container
	@powershell -NoProfile -Command "\
		Write-Host 'Attention!' $(C_RED); \
		Write-Host \"You're about to remove the $(WEBAPP_PLTF) container and delete its image resource.\" $(C_YEL); \
		$$r = Read-Host 'Are you sure to proceed? [y/n]'; \
		if ($$r -eq 'y') { \
			Set-Location './platforms/$(WEBAPP_PLTF)'; \
			$(MAKE) clear destroy; \
			$$c = Read-Host 'Do you want to clear $(ENGINE) cache? [y/n]'; \
			if ($$c -eq 'y') { \
				Start-Process '$(ENGINE_COMMAND)' -ArgumentList 'system prune -f' -NoNewWindow -Wait; \
				Write-Host \"O.K.! $(ENGINE) cache has been cleared up.\" $(C_GRN); \
			} else { \
				Write-Host 'The following command is delegated to be executed by user:' $(C_YEL); \
				Write-Host '$$ $(ENGINE_COMMAND) system prune'; \
			} \
		} else { \
			Write-Host 'O.K.! container continues with its latest status.' $(C_GRN); \
		}"

# -------------------------------------------------------------------------------------------------
#  ...recipes in development
# -------------------------------------------------------------------------------------------------
