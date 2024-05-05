export

# Setting DEBUG=1 will print all shell commands (useful for debugging)
SHELL := /usr/bin/env 'PATH=$(PATH)' bash -o errexit -o nounset -o pipefail -O globstar $(if $(DEBUG),-o xtrace,)
.DEFAULT_GOAL := default
PROJECT_ROOT := $(shell git rev-parse --show-toplevel)
MAKE_TARGET_REGEX := ^[a-zA-Z%_-]+:
, := ,

include $(shell find $(PROJECT_ROOT) -name *.mk)

# Automatically mark all targets as .PHONY
# (since we're not using file-based targets)
.PHONY: $(shell grep -E -h "$(MAKE_TARGET_REGEX)" $(MAKEFILE_LIST) | sed s/:.*// | tr '\n' ' ')

default: help

dump: ## Dump all make variables
	@$(foreach V, $(sort $(.VARIABLES)), \
		$(if $(filter-out environment% default automatic, $(origin $V)), \
			$(info $V=$($V) ($(value $V))) \
		) \
	)
	@echo > /dev/null

mandatory-%:
	$(if $($*),,@echo "$* must be provided!" && exit 1)

print-%:
	@echo $($*)

help: ## Show help for main targets
	@$(MAKE) --no-print-directory help-generate HELP_ANCHOR=##

help-full: ## Show help for all targets
	@$(MAKE) --no-print-directory help-generate HELP_ANCHOR=#

help-generate:
	@grep -E -h "$(MAKE_TARGET_REGEX).*?$(HELP_ANCHOR)" $(MAKEFILE_LIST) \
	| sort \
	| awk -v width=38 'BEGIN {FS = ":.*?##? "} {printf "\033[36m%-*s\033[0m %s\n", width, $$1, $$2}'

common-playbooks:
	sudo ansible-playbook system.yml
	ansible-playbook user.yml

desktop-playbooks:
	sudo ansible-playbook full/system.yml
	ansible-playbook full/user.yml

full: common-playbooks desktop-playbooks

wsl: common-playbooks
