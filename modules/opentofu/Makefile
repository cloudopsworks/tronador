TMP ?= /tmp
OPENTOFU ?= $(INSTALL_PATH)/tofu

## Install opentofu
tofu/install: packages/install/opentofu
	$(OPENTOFU) version

## Ensure all plugins can be fetched
tofu/get-plugins:
	$(OPENTOFU) init -get=true -backend=false -input=false >/dev/null

## Ensure all modules can be fetched
tofu/get-modules:
	$(OPENTOFU) init -get -backend=false -input=false >/dev/null

## Basic opentofu sanity check
tofu/validate:
	$(OPENTOFU) validate

## Lint check Terraform
tofu/lint:
	@FAIL=`$(OPENTOFU) fmt -write=false | xargs -r -n 1 printf '\t- %s\n'`; \
	[ -z "$$FAIL" ] || (echo "Opentofu configuration needs linting. Run '$(OPENTOFU) fmt'"; echo $$FAIL; exit 1)

## Upgrade all opentofu module sources
tofu/upgrade-modules: packages/install/json2hcl
	@$(TRONADOR_PATH)/bin/upgrade_opentofu_modules.sh all

## Format terraform/opentofu code
tofu/fmt:
	$(OPENTOFU) fmt