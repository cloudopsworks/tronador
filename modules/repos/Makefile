# This module administers repositories templates and allows automated upgrades of workflows
#
TMP=/tmp
JAVA_TEMPLATE=cloudopsworks/java-app-template
DOCKER_TEMPLATE=cloudopsworks/docker-app-template
NODE_TEMPLATE=cloudopsworks/node-app-template
PYTHON_TEMPLATE=cloudopsworks/python-app-template
TERRAGRUNT_TEMPLATE=cloudopsworks/terragrunt-project-template
XCODE_TEMPLATE=cloudopsworks/xcode-app-template
TERRAFORM_MODULE=cloudopsworks/terraform-module-template
DOTNET_TEMPLATE=cloudopsworks/dotnet-app-template
GO_TEMPLATE=cloudopsworks/go-app-template
RUST_TEMPLATE=cloudopsworks/rust-app-template
ANDROIDSDK_TEMPLATE=cloudopsworks/androidsdk-app-template
MERGE_TEMPLATE := 0
VERSIONED_TEMPLATE := 0
CICD_TEMPLATE := 0
BOILERPLATE_TEMPLATE := 0
BOILERPLATE_PATH := .boilerplate
GH ?= $(INSTALL_PATH)/gh
PULL_BRANCH ?= master
REPO_NAME ?= ""
TEMPLATE_HASH ?= ""
ifneq (,$(wildcard .cloudopsworks/_VERSION))
BLUEPRINT_PATH := .cloudopsworks
PRE510 := 0
else
BLUEPRINT_PATH := .github
PRE510 := 1
endif
V510PLUS ?= ""

.PHONY: repos/template/init repos/clean/template repos/template/java repos/template/docker repos/template/node repos/template/python repos/template/terragrunt repos/template/xcode repos/template/terraform-module repos/template/dotnet repos/template/go repos/template/rust repos/template/androidsdk

repos/template/dotnet:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.dotnet))
	@echo "DotNet Project Template will be pulled"
	@$(GIT) clone https://github.com/$(DOTNET_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(DOTNET_TEMPLATE)
MIGRATE_TASK := repos/migrate/dotnet/510
endif

repos/template/go:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.golang))
	@echo "Go Project Template will be pulled"
	@$(GIT) clone https://github.com/$(GO_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(GO_TEMPLATE)
MIGRATE_TASK := repos/migrate/go/510
endif

repos/template/rust:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.rust))
	@echo "Rust Project Template will be pulled"
	@$(GIT) clone https://github.com/$(RUST_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(RUST_TEMPLATE)
MIGRATE_TASK := repos/migrate/rust/510
endif

repos/template/xcode:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.xcode))
	@echo "XCode Project Template will be pulled"
	@$(GIT) clone https://github.com/$(XCODE_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(XCODE_TEMPLATE)
MIGRATE_TASK := repos/migrate/xcode/510
endif

repos/template/androidsdk:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.android))
	@echo "Android SDK Project Template will be pulled"
	@$(GIT) clone https://github.com/$(ANDROIDSDK_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(ANDROIDSDK_TEMPLATE)
MIGRATE_TASK := repos/migrate/androidsdk/510
endif

repos/template/java:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.java))
	@echo "Java Project Template will be pulled"
	@$(GIT) clone https://github.com/$(JAVA_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(JAVA_TEMPLATE)
MIGRATE_TASK := repos/migrate/java/510
endif

repos/template/node:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.node))
	@echo "NodeJS Project Template will be pulled"
	@$(GIT) clone https://github.com/$(NODE_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(NODE_TEMPLATE)
MIGRATE_TASK := repos/migrate/node/510
endif

repos/template/docker:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.docker))
	@echo "Docker Project Template will be pulled"
	@$(GIT) clone https://github.com/$(DOCKER_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(DOCKER_TEMPLATE)
MIGRATE_TASK := repos/migrate/docker/510
endif

repos/template/python:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.python))
	@echo "Python Project Template will be pulled"
	@$(GIT) clone https://github.com/$(PYTHON_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(PYTHON_TEMPLATE)
MIGRATE_TASK := repos/migrate/python/510
endif

repos/template/terragrunt:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.iac))
	@echo "Terragrunt Project Template will be pulled"
	@$(GIT) clone https://github.com/$(TERRAGRUNT_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
BOILERPLATE_TEMPLATE := 1
ifeq ($(PRE510),1)
BOILERPLATE_PATH := .cloudopsworks
else
BOILERPLATE_PATH := .cloudopsworks/boilerplate
endif
REPO_NAME := $(TERRAGRUNT_TEMPLATE)
MIGRATE_TASK := repos/migrate/terragrunt/510
endif

repos/template/terraform-module:
ifneq (,$(wildcard $(BLUEPRINT_PATH)/.terraform-module))
	@echo "Terraform Module Project Template will be pulled"
	@$(GIT) clone https://github.com/$(TERRAFORM_MODULE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
BOILERPLATE_TEMPLATE := 1
ifeq ($(PRE510),1)
BOILERPLATE_PATH := .cloudopsworks
else
BOILERPLATE_PATH := .cloudopsworks/boilerplate
endif
REPO_NAME := $(TERRAFORM_MODULE)
MIGRATE_TASK := repos/migrate/terraform/510
endif

# Init script
repos/template/init: repos/clean/template repos/template/java repos/template/docker repos/template/node repos/template/python repos/template/terragrunt repos/template/xcode repos/template/terraform-module repos/template/dotnet repos/template/go repos/template/rust repos/template/androidsdk

.PHONY: repos/clean/template
repos/clean/template:
	@echo "Cleaning up template repository"
	@if [ -d .template ]; then \
		rm -rf .template ; \
	fi
	@$(GIT) remote remove template > /dev/null 2>&1 || true

.PHONY: repos/cicd/update
## Update CICD Pipeline footer versioning
repos/cicd/update:
	@echo "Updating CICD Pipeline cloudopsworks-ci.yaml"
	@grep -q "#workflow-version-tag" $(BLUEPRINT_PATH)/cloudopsworks-ci.yaml || printf "\n\n############ DO NOT MODIFY BELOW ############\n#workflow-version-tag: 1.0.0" >> $(BLUEPRINT_PATH)/cloudopsworks-ci.yaml
ifeq ($(OS),darwin)
	@sed -i '' "s|#workflow-version-tag.*|#workflow-version-tag: $$(cat $(BLUEPRINT_PATH)/_VERSION) - hash: $(TEMPLATE_HASH)|g" $(BLUEPRINT_PATH)/cloudopsworks-ci.yaml
else
	@sed -i "s|#workflow-version-tag.*|#workflow-version-tag: $$(cat $(BLUEPRINT_PATH)/_VERSION) - hash: $(TEMPLATE_HASH)|g" $(BLUEPRINT_PATH)/cloudopsworks-ci.yaml
endif

.PHONY: repos/clean
repos/clean:
	@echo "Cleaning up repository"
	@rm -rf .github/workflows
	@mkdir -p .github/workflows

# Deprecated on v5
#repos/copy/workflow:
#	@echo "Copying workflows from version: $$(cat $(BLUEPRINT_PATH)/_VERSION)"
#	@cp .github/workflows/.template/*.yml .github/workflows
#	@cp .github/workflows/.template/*.yaml .github/workflows
#ifeq ($(OS),darwin)
#	@find .github/workflows -depth 1 -type f -name '*.yml' -print -exec sed -i '' 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
#	@find .github/workflows -depth 1 -type f -name '*.yaml' -print -exec sed -i '' 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
#else
#	@find .github/workflows -maxdepth 1 -type f -name '*.yml' -print -exec sed -i 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
#	@find .github/workflows -maxdepth 1 -type f -name '*.yaml' -print -exec sed -i 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
#endif
#	@echo "Removing Initial.yml script, only needed upon creation."
#	@rm -f .github/workflows/initial.yml

.PHONY: repos/push
repos/push:
	$(call assert-set,GIT)
	@echo "Committing changes"
ifeq (1,$(CICD_TEMPLATE))
	@$(GIT) add -u .github/ Makefile $(BLUEPRINT_PATH)/_VERSION $(BLUEPRINT_PATH)/Makefile $(BLUEPRINT_PATH)/cloudopsworks-ci.yaml
else
	@$(GIT) add -u .github/ Makefile $(BLUEPRINT_PATH)/_VERSION
endif
ifeq (1,$(BOILERPLATE_TEMPLATE))
	@$(GIT) add $(BOILERPLATE_PATH)
endif
	@$(GIT) commit -am "chore: Upgrade repository from template, version: $$(cat $(BLUEPRINT_PATH)/_VERSION)"
	@echo "Repository upgraded to version: $$(cat $(BLUEPRINT_PATH)/_VERSION)"

## Upgrade Repository from Templates but for DEV!
repos/upgrade/dev: repos/template/init
	$(MAKE) PULL_BRANCH=develop repos/upgrade/stack

.PHONY: repos/avail repos/available
## List available template repository versions next patch versions and next major versions (shortened)
repos/avail: repos/available

## List available template repository versions next patch versions and next major versions
repos/available: packages/install/gh repos/template/init
	$(call assert-set,GH)
	$(eval VERSION_STRING := $(shell cat $(BLUEPRINT_PATH)/_VERSION))
	$(eval VERSION_INFO := $(shell awk -F'[v.]' '{print $$2 " " $$3}' $(BLUEPRINT_PATH)/_VERSION))
	$(eval MAJOR_VERSION := $(word 1,$(VERSION_INFO)))
	$(eval MINOR_VERSION := $(word 2,$(VERSION_INFO)))
	@tags=$$($(GH) api "repos/$(REPO_NAME)/tags" --jq '.[].name' || echo "") ; \
    		the_tag=$$(echo "$$tags" | grep -E '^v?$(MAJOR_VERSION)\.$(MINOR_VERSION)\.[0-9]+$$' | sort -V | tail -n1) ; \
    		echo "Repo: $(REPO_NAME)" ; \
    		echo "Version: $(VERSION_STRING) = $(MAJOR_VERSION).$(MINOR_VERSION)" ; \
    		echo "Latest Minor Version: $$the_tag"
	@tags=$$($(GH) api "repos/$(REPO_NAME)/tags" --jq '.[].name' || echo "") ; \
		the_tag=$$(echo "$$tags" | grep -E '^v?$(MAJOR_VERSION)\.[0-9]+\.[0-9]+$$' | sort -V | tail -n1) ; \
		echo "Repo: $(REPO_NAME)" ; \
		echo "Version: $(VERSION_STRING) = $(MAJOR_VERSION).$(MINOR_VERSION)" ; \
		echo "Latest Major Version: $$the_tag"

.PHONY: repos/upgrade repos/upgrade/major repos/upgrade/master repos/upgrade/stack repos/upgrade/fetch repos/upgrade/eval repos/recover
## Upgrade Repository from master Templates (Default upgrade, no breaking changes)
repos/upgrade: packages/install/gh repos/template/init
	$(call assert-set,GH)
	$(eval VERSION_STRING := $(shell cat $(BLUEPRINT_PATH)/_VERSION))
	$(eval VERSION_INFO := $(shell awk -F'[v.]' '{print $$2 " " $$3}' $(BLUEPRINT_PATH)/_VERSION))
	$(eval MAJOR_VERSION := $(word 1,$(VERSION_INFO)))
	$(eval MINOR_VERSION := $(word 2,$(VERSION_INFO)))
	@tags=$$($(GH) api "repos/$(REPO_NAME)/tags" --jq '.[].name' || echo "") ; \
		the_tag=$$(echo "$$tags" | grep -E '^v?$(MAJOR_VERSION)\.$(MINOR_VERSION)\.[0-9]+$$' | sort -V | tail -n1) ; \
		echo "Repo: $(REPO_NAME)" ; \
		echo "Version: $(VERSION_STRING) = $(MAJOR_VERSION).$(MINOR_VERSION)" ; \
		echo "Last Version: $$the_tag" ; \
		$(MAKE) PULL_BRANCH=$$the_tag repos/upgrade/stack

## Upgrade Repository from master Templates (Default upgrade, no breaking changes)
repos/upgrade/major: packages/install/gh repos/template/init
	$(call assert-set,GH)
	$(eval VERSION_STRING := $(shell cat $(BLUEPRINT_PATH)/_VERSION))
	$(eval VERSION_INFO := $(shell awk -F'[v.]' '{print $$2 " " $$3}' $(BLUEPRINT_PATH)/_VERSION))
	$(eval MAJOR_VERSION := $(word 1,$(VERSION_INFO)))
	$(eval MINOR_VERSION := $(word 2,$(VERSION_INFO)))
	@tags=$$($(GH) api "repos/$(REPO_NAME)/tags" --jq '.[].name' || echo "") ; \
		the_tag=$$(echo "$$tags" | grep -E '^v?$(MAJOR_VERSION)\.[0-9]+\.[0-9]+$$' | sort -V | tail -n1) ; \
		echo "Repo: $(REPO_NAME)" ; \
		echo "Version: $(VERSION_STRING) = $(MAJOR_VERSION).$(MINOR_VERSION)" ; \
		echo "Last Version: $$the_tag" ; \
		$(MAKE) PULL_BRANCH=$$the_tag repos/upgrade/stack

## Upgrade Repository from master Templates (Major upgrade, can contain breaking changes)
repos/upgrade/master: repos/template/init
	$(MAKE) repos/upgrade/stack

.PHONY: repos/upgrade/fetch repos/upgrade/eval
repos/upgrade/fetch:
	$(call assert-set,PULL_BRANCH)
	@echo "Fetching template repository from branch: $(PULL_BRANCH)"
	@cd .template && $(GIT) checkout $(PULL_BRANCH) > /dev/null 2>&1
	$(eval TEMPLATE_HASH := $(shell cd .template && $(GIT) rev-parse $(PULL_BRANCH)))
	@cd .template && rm -fr .git
	@echo "Template repository hash: $(TEMPLATE_HASH)"

# will be empty if pre v5.10 && upgrading same pre v5.10
repos/upgrade/eval:
	$(eval V510PLUS := $(shell if [[ -f .template/.cloudopsworks/_VERSION ]] ; then cat .template/.cloudopsworks/_VERSION ; else echo -n "" ; fi))
	@echo "Template version v5.10+ detected?: '$(V510PLUS)'"

.PHONY: repos/upgrade/stack
repos/upgrade/stack: packages/install/gh repos/upgrade/fetch repos/upgrade/eval
	$(call assert-set,GIT)
	$(call assert-set,GH)
ifeq (1,$(MERGE_TEMPLATE))
	@echo "Upgrading repository, current Version: $$(cat $(BLUEPRINT_PATH)/_VERSION) from $(PULL_BRANCH)"
	@echo "Setting default repository: $(GIT_ORG)/$(GIT_REPO)"
	@$(GH) repo set-default $(GIT_ORG)/$(GIT_REPO)
	@echo "Updating from template repository"
	@$(MAKE) repos/clean
ifeq (1,$(VERSIONED_TEMPLATE))
		@cp -pfR .template/.github/workflows .github
		@$(GIT) add .github/workflows
		@cp -pf .template/Makefile Makefile
		@cp -pf .template/.gitignore .gitignore
		@if [[ -f .template/.helmignore ]] ; then \
		    cp -pf .template/.helmignore .helmignore ; \
		fi
		@if [[ -f .template/.dockerignore ]] ; then \
		    cp -pf .template/.dockerignore .dockerignore ; \
		fi
		@if [[ "x$(V510PLUS)" != "x" ]] ; then \
			echo "Detected template version v5.10+" ; \
			if [[ "$(PRE510)" == "1" ]] ; then \
				$(MAKE) $(MIGRATE_TASK) ; \
				$(GIT) add .cloudopsworks ; \
			fi ; \
			cp -pf .template/.cloudopsworks/_VERSION .cloudopsworks/_VERSION ; \
			[ -f .template/.cloudopsworks/labeler.yml ] && cp -pf .template/.cloudopsworks/labeler.yml .cloudopsworks ; \
			if [ -f .template/.cloudopsworks/Makefile ]; then \
				cp -pf .template/.cloudopsworks/Makefile .cloudopsworks/Makefile ; \
			fi ; \
		else \
			echo "Detected template version < v5.10" ; \
			cp -pf .template/.github/_VERSION .github/_VERSION ; \
			[ -f .template/.github/labeler.yml ] && cp -pf .template/.github/labeler.yml .github ; \
			if [ -f .template/.github/Makefile ]; then \
				cp -pf .template/.github/Makefile .github/Makefile ; \
			fi ; \
		fi
else
		@cp -pfr .template/.github/workflows .github/workflows
		@$(GIT) add .github/workflows
		@cp -pfr .template/Makefile Makefile
endif

ifeq (1,$(BOILERPLATE_TEMPLATE))
		@mkdir -p $(BOILERPLATE_PATH)
		@cp -pfr .template/$(BOILERPLATE_PATH)/ $(BOILERPLATE_PATH)/
endif

ifeq (1,$(CICD_TEMPLATE))
		@$(MAKE) TEMPLATE_HASH=$(TEMPLATE_HASH) repos/cicd/update
endif
	@rm -fr .template/
	@$(MAKE) repos/push
	@echo "Please review changes and push to remote repository"
else
	@echo "No templates supported to upgrade by this script, skipping upgrade"
endif

## Upgrade Repository from Templates for specific version as part of the last / (%) argument
repos/upgrade/%: repos/template/init
	$(eval RELVERSION := $(subst repos/upgrade/,,$@))
	$(MAKE) PULL_BRANCH=$(RELVERSION) repos/upgrade/stack

## Upgrade Repository from Templates
repos/recover: packages/install/gh repos/template/init repos/upgrade/fetch
	$(call assert-set,GIT)
	$(call assert-set,GH)
ifeq (1,$(MERGE_TEMPLATE))
	@echo "Upgrading repository, current Version: $$(cat $(BLUEPRINT_PATH)/_VERSION) from $(PULL_BRANCH)"
	@echo "Setting default repository: $(GIT_ORG)/$(GIT_REPO)"
	@$(GH) repo set-default $(GIT_ORG)/$(GIT_REPO)
	@echo "Fetching template repository"
	@$(MAKE) repos/clean
	@cp -pfr .template/ .
  ifeq (1,$(BOILERPLATE_TEMPLATE))
	@mkdir -p $(BOILERPLATE_PATH)
	@cp -pfR .template/$(BOILERPLATE_PATH)/* $(BOILERPLATE_PATH)
  endif
  ifeq (1,$(CICD_TEMPLATE))
	@$(MAKE) repos/cicd/update
  endif
	@rm -fr .template/
	@echo "!!WARNING!! Some files may have been overwritten, please review changes and push to remote repository"
else
	@echo "No templates supported to upgrade by this script, skipping upgrade"
endif

.PHONY: repos/migrate/510 repos/migrate/java/510 repos/migrate/node/510 repos/migrate/dotnet/510 repos/migrate/go/510 repos/migrate/rust/510 repos/migrate/python/510 repos/migrate/xcode/510 repos/migrate/androidsdk/510 repos/migrate/terragrunt/510 repos/migrate/terraform/510
# Migration tasks:
repos/migrate/510:
	@echo "Migrating Common repository structure to v5.10+"
	@mkdir -p .cloudopsworks
	@mv .github/vars .github/values .github/cloudopsworks*.yaml .github/LICENSE .github/Makefile .github/_VERSION .github/labeler.yml .cloudopsworks/
	@$(GIT) add -A .github

repos/migrate/java/510: repos/migrate/510
	@echo "Migrating Java repository structure to v5.10+"
	@mv .github/.java .cloudopsworks/

repos/migrate/node/510: repos/migrate/510
	@echo "Migrating NodeJS repository structure to v5.10+"
	@mv .github/.node .cloudopsworks/

repos/migrate/dotnet/510: repos/migrate/510
	@echo "Migrating NodeJS repository structure to v5.10+"
	@mv .github/.dotnet .cloudopsworks/

repos/migrate/go/510: repos/migrate/510
	@echo "Migrating GoLang repository structure to v5.10+"
	@mv .github/.golang .cloudopsworks/

repos/migrate/rust/510: repos/migrate/510
	@echo "Migrating Rust repository structure to v5.10+"
	@mv .github/.rust .cloudopsworks/

repos/migrate/python/510: repos/migrate/510
	@echo "Migrating Python repository structure to v5.10+"
	@mv .github/.python .cloudopsworks/

repos/migrate/xcode/510: repos/migrate/510
	@echo "Migrating Xcode repository structure to v5.10+"
	@mv .github/.xcode .cloudopsworks/

repos/migrate/androidsdk/510:
	@echo "NOT SUPPORTED: Migrating Android SDK repository structure to v5.10+"
	@echo "Android SDK is available only for v5.10+ templates, no migration needed."
	exit 100

repos/migrate/terragrunt/510:
	@echo "Migrating Terragrunt repository structure to v5.10+"
	@mkdir -p .cloudopsworks
	@mv .github/cloudopsworks*.yaml .github/LICENSE .github/Makefile .github/_VERSION .github/labeler.yml .cloudopsworks/
	@mv .github/.iac .cloudopsworks/
	@[ -f .github/.inputs_cicd ] && mv .github/.inputs_cicd .cloudopsworks/ || echo "No Inputs CICD indicator found"
	@$(GIT) add -A .github

repos/migrate/terraform/510:
	@echo "Migrating Terraform Module repository structure to v5.10+"
	@mkdir -p  .cloudopsworks/boilerplate/
	@mv .github/.terraform-module .cloudopsworks/
	@mv .github/auto*.yml .cloudopsworks/
	@mv .github/_VERSION .cloudopsworks/
	@[ -f .github/.provider ] && mv .github/.provider .cloudopsworks/ || echo "No Provider indicator found"
	@[ -d .cloudopsworks/aws ] && mv .cloudopsworks/aws .cloudopsworks/boilerplate/ || echo "No AWS boilerplate found"
	@[ -d .cloudopsworks/gcp ] && mv .cloudopsworks/gcp .cloudopsworks/boilerplate/ || echo "No GCP boilerplate found"
	@[ -d .cloudopsworks/azure ] && mv .cloudopsworks/azure .cloudopsworks/boilerplate/ || echo "No Azure boilerplate found"
