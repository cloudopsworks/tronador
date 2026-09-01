export TMP ?= /tmp
export TRONADOR_PATH ?= $(shell 'pwd')
export OS ?= $(shell uname -s | tr '[:upper:]' '[:lower:]')
export OS_ARCH ?= $(shell uname -m)
ifeq ($(OS_ARCH),x86_64)
export ARCH ?= amd64
else
export ARCH ?= $(OS_ARCH)
endif
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

# Deprecation notice - emitted once per top-level invocation.
# MAKE_RESTARTS guards the re-exec that happens when make remakes its own
# included makefiles; MAKELEVEL guards the recursive $(SELF) sub-makes.
ifndef MAKE_RESTARTS
ifeq ($(MAKELEVEL),0)
ifndef TRONADOR_DEPRECATION_SHOWN
TRONADOR_DEPRECATION_SHOWN := 1
$(shell printf '\n%s\n%s\n\n  %-15s %s\n  %-15s %s\n  %-15s %s\n\n' \
  'Deprecation Notice: this make module is being deprecated in favor of our CLI.' \
  'Please refer to our resources documentation and GitHub project:' \
  'Install guide:'  'https://cloudopsworks.co/resources/tronador-cli-installation/' \
  'Resources:'      'https://cloudopsworks.co/resources/' \
  'GitHub project:' 'https://github.com/cloudopsworks/tronador-cli' >&2)
endif
endif
endif


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
