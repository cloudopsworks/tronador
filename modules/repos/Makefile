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
MERGE_TEMPLATE := 0
VERSIONED_TEMPLATE := 0
CICD_TEMPLATE := 0
BOILERPLATE_TEMPLATE := 0
BOILERPLATE_PATH := .boilerplate
GH ?= $(INSTALL_PATH)/gh
PULL_BRANCH ?= master
REPO_NAME ?= ""

repos/template/dotnet:
ifneq (,$(wildcard .github/.dotnet))
	@echo "DotNet Project Template will be pulled"
	@$(GIT) clone https://github.com/$(DOTNET_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(DOTNET_TEMPLATE)
endif

repos/template/go:
ifneq (,$(wildcard .github/.golang))
	@echo "Go Project Template will be pulled"
	@$(GIT) clone https://github.com/$(GO_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(GO_TEMPLATE)
endif

repos/template/rust:
ifneq (,$(wildcard .github/.rust))
	@echo "Rust Project Template will be pulled"
	@$(GIT) clone https://github.com/$(RUST_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(RUST_TEMPLATE)
endif

repos/template/xcode:
ifneq (,$(wildcard .github/.xcode))
	@echo "XCode Project Template will be pulled"
	@$(GIT) clone https://github.com/$(XCODE_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(XCODE_TEMPLATE)
endif

repos/template/java:
ifneq (,$(wildcard .github/.java))
	@echo "Java Project Template will be pulled"
	@$(GIT) clone https://github.com/$(JAVA_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(JAVA_TEMPLATE)
endif

repos/template/node:
ifneq (,$(wildcard .github/.node))
	@echo "NodeJS Project Template will be pulled"
	@$(GIT) clone https://github.com/$(NODE_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(NODE_TEMPLATE)
endif

repos/template/docker:
ifneq (,$(wildcard .github/.docker))
	@echo "Docker Project Template will be pulled"
	@$(GIT) clone https://github.com/$(DOCKER_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(DOCKER_TEMPLATE)
endif

repos/template/python:
ifneq (,$(wildcard .github/.python))
	@echo "Python Project Template will be pulled"
	@$(GIT) clone https://github.com/$(PYTHON_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
REPO_NAME := $(PYTHON_TEMPLATE)
endif

repos/template/terragrunt:
ifneq (,$(wildcard .github/.iac))
	@echo "Terragrunt Project Template will be pulled"
	@$(GIT) clone https://github.com/$(TERRAGRUNT_TEMPLATE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
CICD_TEMPLATE := 1
BOILERPLATE_TEMPLATE := 1
BOILERPLATE_PATH := .cloudopsworks
REPO_NAME := $(TERRAGRUNT_TEMPLATE)
endif

repos/template/terraform-module:
ifneq (,$(wildcard .github/.terraform-module))
	@echo "Terraform Module Project Template will be pulled"
	@$(GIT) clone https://github.com/$(TERRAFORM_MODULE).git .template > /dev/null 2>&1
MERGE_TEMPLATE := 1
VERSIONED_TEMPLATE := 1
BOILERPLATE_TEMPLATE := 1
REPO_NAME := $(TERRAFORM_MODULE)
endif

.PHONY: repos/template/init
repos/template/init: repos/clean/template repos/template/java repos/template/docker repos/template/node repos/template/python repos/template/terragrunt repos/template/xcode repos/template/terraform-module repos/template/dotnet repos/template/go repos/template/rust

.PHONY: repos/clean/template
repos/clean/template:
	@echo "Cleaning up template repository"
	@if [ -d .template ]; then \
		rm -rf .template ; \
	fi
	@$(GIT) remote remove template > /dev/null 2>&1 || true

## Update CICD Pipeline footer versioning
repos/cicd/update:
	@echo "Updating CICD Pipeline cloudopsworks-ci.yaml"
	@grep -q "#workflow-version-tag" .github/cloudopsworks-ci.yaml || printf "\n\n############ DO NOT MODIFY BELOW ############\n#workflow-version-tag: 1.0.0" >> .github/cloudopsworks-ci.yaml
ifeq ($(OS),darwin)
	@sed -i '' "s|#workflow-version-tag.*|#workflow-version-tag: $$(cat .github/_VERSION) - hash: $$(git for-each-ref refs/remotes/template --sort="-committerdate" | head -1 | cut -d ' ' -f 1)|g" .github/cloudopsworks-ci.yaml
else
	@sed -i "s|#workflow-version-tag.*|#workflow-version-tag: $$(cat .github/_VERSION) - hash: $$(git for-each-ref refs/remotes/template --sort="-committerdate" | head -1 | cut -d ' ' -f 1)|g" .github/cloudopsworks-ci.yaml
endif

repos/clean:
	@echo "Cleaning up repository"
	@rm -rf .github/workflows
	@mkdir -p .github/workflows

# Deprecated on v5
#repos/copy/workflow:
#	@echo "Copying workflows from version: $$(cat .github/_VERSION)"
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

repos/push:
	$(call assert-set,GIT)
	@echo "Committing changes"
ifeq (1,$(CICD_TEMPLATE))
	@$(GIT) add .github/workflows Makefile .github/_VERSION .github/cloudopsworks-ci.yaml
else
	@$(GIT) add .github/workflows Makefile .github/_VERSION
endif
ifeq (1,$(BOILERPLATE_TEMPLATE))
	@$(GIT) add $(BOILERPLATE_PATH)
endif
	@$(GIT) commit -m "chore: Upgrade repository from template, version: $$(cat .github/_VERSION)"
	@echo "Repository upgraded to version: $$(cat .github/_VERSION)"

## Upgrade Repository from Templates but for DEV!
repos/upgrade/dev: repos/template/init
	$(MAKE) PULL_BRANCH=develop repos/upgrade/stack

## Upgrade Repository from master Templates (Default upgrade, no breaking changes)
repos/upgrade: packages/install/gh repos/template/init
	$(call assert-set,GH)
	$(eval VERSION_STRING := $(shell cat .github/_VERSION))
	$(eval VERSION_INFO := $(shell awk -F'[v.]' '{print $$2 " " $$3}' .github/_VERSION))
	$(eval MAJOR_VERSION := $(word 1,$(VERSION_INFO)))
	$(eval MINOR_VERSION := $(word 2,$(VERSION_INFO)))
	$(eval THETAG= $(shell ))
	tags=$$($(GH) api "repos/$(REPO_NAME)/tags" --jq '.[].name' || echo "") ; \
	the_tag=$$(echo "$$tags" | grep -E '^v?$(MAJOR_VERSION)\.$(MINOR_VERSION)\.[0-9]+$$' | sort -V | tail -n1) ; \
	echo "Repo: $(REPO_NAME)" ; \
	echo "Version: $(VERSION_STRING) = $(MAJOR_VERSION).$(MINOR_VERSION)" ; \
	echo "Last Version: $$the_tag" ; \
	$(MAKE) PULL_BRANCH=$$the_tag repos/upgrade/stack

## Upgrade Repository from master Templates (Default upgrade, no breaking changes)
repos/upgrade/major: packages/install/gh repos/template/init
	$(call assert-set,GH)
	$(eval VERSION_STRING := $(shell cat .github/_VERSION))
	$(eval VERSION_INFO := $(shell awk -F'[v.]' '{print $$2 " " $$3}' .github/_VERSION))
	$(eval MAJOR_VERSION := $(word 1,$(VERSION_INFO)))
	$(eval MINOR_VERSION := $(word 2,$(VERSION_INFO)))
	tags=$$($(GH) api "repos/$(REPO_NAME)/tags" --jq '.[].name' || echo "") ; \
	the_tag=$$(echo "$$tags" | grep -E '^v?$(MAJOR_VERSION)\.[0-9]+\.[0-9]+$$' | sort -V | tail -n1) ; \
	echo "Repo: $(REPO_NAME)" ; \
	echo "Version: $(VERSION_STRING) = $(MAJOR_VERSION).$(MINOR_VERSION)" ; \
	echo "Last Version: $$the_tag" ; \
	$(MAKE) PULL_BRANCH=$$the_tag repos/upgrade/stack

## Upgrade Repository from master Templates (Major upgrade, can contain breaking changes)
repos/upgrade/master: repos/template/init
	$(MAKE) repos/upgrade/stack

repos/upgrade/fetch:
	$(call assert-set,PULL_BRANCH)
	@echo "Fetching template repository from branch: $(PULL_BRANCH)"
	@cd .template && \
		$(GIT) checkout $(PULL_BRANCH) > /dev/null 2>&1 && \
		rm -fr .git

repos/upgrade/stack: packages/install/gh repos/upgrade/fetch
	$(call assert-set,GIT)
	$(call assert-set,GH)
ifeq (1,$(MERGE_TEMPLATE))
	@echo "Upgrading repository, current Version: $$(cat .github/_VERSION) from $(PULL_BRANCH)"
	@echo "Setting default repository: $(GIT_ORG)/$(GIT_REPO)"
	@$(GH) repo set-default $(GIT_ORG)/$(GIT_REPO)
	@echo "Updating from template repository"
	$(MAKE) repos/clean
  ifeq (1,$(VERSIONED_TEMPLATE))
	@cp -pfR .template/.github/workflows .github
	@cp -pf .template/Makefile Makefile
	@cp -pf .template/.github/_VERSION .github/_VERSION
	@if [ -f .template/.github/Makefile ]; then \
		cp -pf .template/.github/Makefile .github/Makefile ; \
	fi
  else
	@cp -pfr .template/.github/workflows .github/workflows
	@cp -pfr .template/Makefile Makefile
  endif
  ifeq (1,$(BOILERPLATE_TEMPLATE))
	@cp -pfR .template/$(BOILERPLATE_PATH) .
  endif
  ifeq (1,$(CICD_TEMPLATE))
	$(MAKE) repos/cicd/update
  endif
	$(MAKE) repos/push
	@echo "Please review changes and push to remote repository"
else
	@echo "No templates supported to upgrade by this script, skipping upgrade"
endif

## Upgrade Repository from Templates for specific version as part of the last / (%) argument
repos/upgrade/%: repos/template/init
	$(eval RELVERSION := $(subst repos/upgrade/,,$@))
	$(MAKE) PULL_BRANCH=$(RELVERSION) repos/upgrade/stack

## Upgrade Repository from Templates
repos/recover: packages/install/gh repos/template/init
	$(call assert-set,GIT)
	$(call assert-set,GH)
ifeq (1,$(MERGE_TEMPLATE))
	@echo "Upgrading repository, current Version: $$(cat .github/_VERSION) from $(PULL_BRANCH)"
	@echo "Setting default repository: $(GIT_ORG)/$(GIT_REPO)"
	@$(GH) repo set-default $(GIT_ORG)/$(GIT_REPO)
	@echo "Fetching template repository"
	@$(GIT) fetch template $(PULL_BRANCH)
	$(MAKE) repos/clean
	@$(GIT) checkout template/$(PULL_BRANCH) -- .
  ifeq (1,$(CICD_TEMPLATE))
	$(MAKE) repos/cicd/update
  endif
	@echo "!!WARNING!! Some files may have been overwritten, please review changes and push to remote repository"
else
	@echo "No templates supported to upgrade by this script, skipping upgrade"
endif
