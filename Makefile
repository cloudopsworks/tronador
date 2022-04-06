export TMP ?= /tmp
export TRONADOR_PATH ?= $(shell 'pwd')
export OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
export ARCH ?= $(shell uname -m)
export SELF ?= $(MAKE)
# Rewrite the path with vendor folder
export PATH := $(TRONADOR_PATH)/vendor:$(PATH)

ifeq ($(CURDIR),$(realpath $(TRONADOR_PATH)))
# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md auto-label
export DEFAULT_HELP_TARGET = help/all
endif

# Import Makefiles into current context
include $(TRONADOR_PATH)/Makefile.*
include $(TRONADOR_PATH)/modules/*/bootstrap.Makefile*
include $(TRONADOR_PATH)/modules/*/Makefile*


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
