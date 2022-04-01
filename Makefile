export ACCELERATE_PATH ?= $(shell 'pwd')
export OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
export SELF ?= $(MAKE)
# Rewrite the path with vendor folder
export PATH := $(ACCELERATE_PATH)/vendor:$(PATH)

-include $(shell curl -sSL -o .accelerate-base "https://raw.githubusercontent.com/cloudopsworks/accelerate/master/bin/install.sh"; echo .accelerate-base)

ifeq ($(CURDIR),$(realpath $(ACCELERATE_PATH)))
# List of targets the `readme` target should call before generating the readme
export README_DEPS ?= docs/targets.md auto-label
export DEFAULT_HELP_TARGET = help/all
endif

# Import Makefiles into current context
include $(ACCELERATE_PATH)/Makefile.*
include $(ACCELERATE_PATH)/modules/*/Makefile*

init::
	@exit 0