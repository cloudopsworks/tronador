TMP ?= /tmp
TERRAGRUNT ?= $(INSTALL_PATH)/terragrunt

## Install Terragrunt
terragrunt/install: packages/install/terragrunt
	$(TERRAGRUNT) --version

## Ensure all plugins can be fetched
terragrunt/get-plugins:
	$(TERRAGRUNT) --non-interactive run-all init -get=true -backend=false -input=false >/dev/null

## Ensure all modules can be fetched
terragrunt/get-modules:
	$(TERRAGRUNT) --non-interactive run-all init -get -backend=false -input=false >/dev/null

## Basic Terragrunt sanity check
terragrunt/validate:
	$(TERRAGRUNT) --non-interactive run-all validate

## Lint check Terraform
terragrunt/lint:
	@FAIL=`$(TERRAGRUNT) --non-interactive run-all hclfmt --check | xargs -r -n 1 printf '\t- %s\n'`; \
	[ -z "$$FAIL" ] || (echo "Terragrunt configuration needs linting. Run '$(TERRAGRUNT) run-all hclfmt'"; echo $$FAIL; exit 1)

## Upgrade all Terragrunt module sources
terragrunt/upgrade-modules: packages/install/json2hcl
	@$(TRONADOR_PATH)/bin/upgrade_opentofu_modules.sh all

## Format terraform/Terragrunt code
terragrunt/fmt:
	$(TERRAGRUNT) --non-interactive run-all hclfmt --diff