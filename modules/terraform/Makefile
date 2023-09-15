TMP ?= /tmp
TERRAFORM ?= $(INSTALL_PATH)/terraform

## Install terraform
terraform/install: packages/install/terraform
	$(TERRAFORM) version

## Ensure all plugins can be fetched
terraform/get-plugins:
	$(TERRAFORM) init -get=true -backend=false -input=false >/dev/null

## Ensure all modules can be fetched
terraform/get-modules:
	$(TERRAFORM) init -get -backend=false -input=false >/dev/null

## Basic terraform sanity check
terraform/validate:
	$(TERRAFORM) validate

## Lint check Terraform
terraform/lint:
	@FAIL=`$(TERRAFORM) fmt -write=false | xargs -r -n 1 printf '\t- %s\n'`; \
	[ -z "$$FAIL" ] || (echo "Terraform configuration needs linting. Run '$(TERRAFORM) fmt'"; echo $$FAIL; exit 1)

## Upgrade all terraform module sources
terraform/upgrade-modules: packages/install/json2hcl
	@$(TRONADOR_PATH)/bin/upgrade_terraform_modules.sh all
