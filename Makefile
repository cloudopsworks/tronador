export TMP ?= /tmp
export ACCELERATE_PATH ?= $(shell 'pwd')
export OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
export ARCH ?= $(shell uname -m)
export SELF ?= $(MAKE)
# Rewrite the path with vendor folder
export PATH := $(ACCELERATE_PATH)/vendor:$(PATH)

ifeq ($(CURDIR),$(realpath $(ACCELERATE_PATH)))
# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md auto-label
export DEFAULT_HELP_TARGET = help/all
endif

# Import Makefiles into current context
include $(ACCELERATE_PATH)/Makefile.*
include $(ACCELERATE_PATH)/modules/*/bootstrap.Makefile*
include $(ACCELERATE_PATH)/modules/*/Makefile*


auto-label: MODULES=$(filter %/, $(sort $(wildcard modules/*/)))
auto-label:
	@for module in $(MODULES); do \
		echo "$${module%/}: $${module}**"; \
	done > .github/$@.yml

init::
	@exit 0

ifndef TRANSLATE_COLON_NOTATION
%:
	@$(SELF) -s $(subst :,/,$@) TRANSLATE_COLON_NOTATION=false
endif
