##################################################
#                Make helpers                    #
##################################################

export

# Setting DEBUG=1 will print all shell commands (useful for debugging)
SHELL := /usr/bin/env 'PATH=$(PATH)' bash -o errexit -o nounset -o pipefail -O globstar $(if $(DEBUG),-o xtrace,)

.DEFAULT_GOAL := help
PROJECT_ROOT := $(shell git rev-parse --show-toplevel)
MAKE_TARGET_REGEX := ^[a-zA-Z%_-]+:
, := ,

# Suppress Make directory output if not in DEBUG mode
ifndef DEBUG
MAKEFLAGS += --no-print-directory
endif

include $(shell find $(PROJECT_ROOT) -name *.mk)

# Automatically mark all targets as .PHONY
# (since we're not using file-based targets)
.PHONY: $(shell grep -E -h "$(MAKE_TARGET_REGEX)" $(MAKEFILE_LIST) | sed s/:.*// | tr '\n' ' ')

dump: ## Dump all make variables
	@$(foreach V, $(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic, $(origin $V)), \
			$(info $V=$($V) ($(value $V))) \
		) \
	)
	@echo > /dev/null

mandatory-%:
	$(if $($*),,@echo "$* must be provided!" && exit 1)

print-%: # Print the value of a Make variable
	@echo $($*)

help: ## Show help for top-level targets
	@$(MAKE) --no-print-directory help-generate HELP_ANCHOR=##

help-full: ## Show help for all targets
	@$(MAKE) --no-print-directory help-generate HELP_ANCHOR=#

help-generate:
	@grep -E -h "$(MAKE_TARGET_REGEX).*?$(HELP_ANCHOR)" $(MAKEFILE_LIST) \
	| sort \
	| awk -v width=38 'BEGIN {FS = ":.*?##? "} {printf "\033[36m%-*s\033[0m %s\n", width, $$1, $$2}'

##################################################
#                Ansible helpers                 #
##################################################

init: ## Initialise local environment for running playbooks
	sudo apt update
	sudo apt -y install ansible
	@$(MAKE) ansible-galaxy-update-collections

ansible-galaxy-update-collections:
	$(eval ANSIBLE_GALAXY_COMMUNITY_GENERAL_MAJOR_VERSION := $(shell \
		ansible-galaxy collection list community.general \
		| grep '^community.general' \
		| sort \
		| tail -1 \
		| cut -d ' ' -f 2 \
		| cut -d '.' -f 1 \
	))

	@[[ "$(ANSIBLE_GALAXY_COMMUNITY_GENERAL_MAJOR_VERSION)" == "1" ]] && ansible-galaxy collection install -f community.general || exit 0

resolve-environment: # Check whether we are running on WSL or Ubuntu Desktop
	$(eval IS_WSL=$(if $(IS_WSL),1,$(if $(WSL_DISTRO_NAME),1,)))

ansible-playbook: resolve-environment # Run a playbook using Ansible
	$(if $(SUDO),sudo ,)ansible-playbook \
		$(if $(DEBUG),-vvv ,) \
		$(if $(IS_WSL),--extra-vars "is_desktop=0 is_wsl=1",--extra-vars "is_desktop=1 is_wsl=0") \
		'$(PLAYBOOK_PATH)'

conditional-playbook: # Run a playbook only if it exists
	$(if $(wildcard $(PLAYBOOK_PATH)), \
		@$(MAKE) ansible-playbook, \
		$(if $(DEBUG),@echo 'No playbook found at $(PLAYBOOK_PATH)',@:) \
	)

playbook-%: # Run system and user playbooks for a specific helper
	@$(MAKE) conditional-playbook \
		PLAYBOOK_PATH=$(PROJECT_ROOT)/playbooks/$*/system.yml \
		SUDO=1
	
	@$(MAKE) conditional-playbook \
		PLAYBOOK_PATH=$(PROJECT_ROOT)/playbooks/$*/user.yml

##################################################
#                High-level targets              #
##################################################

dev: init base aws docker dotnet gh git node oh-my-posh python ## Set up a full development environment

##################################################
#                Individual workloads            #
##################################################

aws: playbook-aws ## Install AWS CLI tools

base: playbook-base ## Configure base Ubuntu OS

docker: playbook-docker ## Install Docker

dotnet: playbook-dotnet ## Install .NET development tools

gh: playbook-gh ## Install GitHub CLI (gh)

gis: playbook-gis ## Install GIS tools

git: playbook-git ## Configure Git CLI

node: playbook-node ## Install Node JS development tools

oh-my-posh: playbook-oh-my-posh ## Install oh-my-posh shell add-in

pwsh: playbook-pwsh ## Install PowerShell 7+ (pwsh)

python: playbook-python ## Install Python development tools
