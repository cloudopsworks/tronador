GIT:= $(shell which git)
MAIN_BRANCH:=$(shell $(GIT) branch -l --format "%(refname:short)" | egrep "master|main")
export GIT_BRANCH ?= $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null)
export GIT_REMOTE ?= $(shell $(GIT) ls-remote --get-url 2>/dev/null)
export GIT_BRANCH_PREFIX ?= $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null | sed -e 's/\(.*\)\/.*/\1/')
GH ?= $(INSTALL_PATH)/gh
SEMVER ?= $(INSTALL_PATH)/semver
GITVERSION ?= $(INSTALL_PATH)/gitversion

## Git-Flow Initialize develop branch
gitflow/init:
	$(call assert-set,GIT)
	@if [ "$(MAIN_BRANCH)" = "" ]; then \
		$(GIT) checkout -b main; \
		$(GIT) push -u origin main; \
		$(GIT) checkout -b develop; \
		$(GIT) push -u origin develop; \
	else \
		$(GIT) checkout $(MAIN_BRANCH); \
		$(GIT) pull origin $(MAIN_BRANCH); \
		$(GIT) checkout -b develop; \
		$(GIT) push -u origin develop; \
	fi

gitflow/deps: packages/install/gitversion packages/install/gh packages/install/semver
	@exit 0

## Git-Flow feature start
gitflow/feature/start:
	$(call assert-set,GIT)
	$(eval FEAT_NAME := $(filter-out $@,$(MAKECMDGOALS)))
ifneq ($(FEAT_NAME),)
	@$(GIT) checkout -b feature/$(FEAT_NAME) develop
else
	$(error "You must specify a feature name")
endif

## Git-Flow feature finish (automatic via PR), this receives the following call pattern: make gitflow/feature/finish <feature_name>, defaults PR to develop
gitflow/feature/finish:
	$(call assert-set,GIT)
	$(call assert-set,GH)
	$(eval FEAT_NAME := $(filter-out $@,$(MAKECMDGOALS)))
ifneq ($(FEAT_NAME),)
	$(GH) pr create -B develop -H feature/$(FEAT_NAME) -b "Feature feature/$(FEAT_NAME) Finish, will merge the code into develop." \
		-t "Feature feature/$(FEAT_NAME) Finish" ; \
else ifneq ($(GIT_BRANCH_PREFIX),feature)
	@if [[ \
		"$$(git ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$(git rev-parse HEAD)" \
	]]; then \
		$(GH) pr create -B $(TARGET_BRANCH) -b "Feature $(GIT_BRANCH) Finish, will merge the code into $(TARGET_BRANCH)" \
			-t "Feature $(GIT_BRANCH) Finish" ; \
	else \
		echo "You must be in the latest commit of the release branch to publish"; \
	fi
else
	$(error "You must specify a feature name to publish, or being working on a feature branch")
endif

## Git-Flow feature finish (manual)
gitflow/feature/manual/finish:
	$(call assert-set,GIT)
	$(eval FEAT_NAME := $(filter-out $@,$(MAKECMDGOALS)))
ifneq ($(FEAT_NAME),)
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) merge --no-ff feature/$(FEAT_NAME)
	@$(GIT) branch -d feature/$(FEAT_NAME)
	@$(GIT) push origin develop
else
	$(error "You must specify a feature name")
endif

## Git-Flow feature publish
gitflow/feature/publish:
	$(eval FEAT_NAME := $(filter-out $@,$(MAKECMDGOALS)))
	$(call assert-set,GIT)
ifneq ($(FEAT_NAME),)
	@$(GIT) checkout feature/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) push origin feature/$(filter-out $@,$(MAKECMDGOALS))
else ifeq ($(GIT_BRANCH_PREFIX),feature)
	@$(GIT) push origin $(GIT_BRANCH)
else
	$(error "You must specify a feature name to publish, or being working on a feature branch")
endif

## GIt-Flow Hotfix start
gitflow/hotfix/start: gitflow/deps
	$(call assert-set,GIT)
	$(eval WORD_COUNT := $(words $(MAKECMDGOALS)))
	$(eval HOTFIX_NAME := $(if $(filter 2 3,$(WORD_COUNT)),$(word 2,$(MAKECMDGOALS))))
	$(eval HOTFIX_TARGET := $(if $(filter 3,$(WORD_COUNT)),$(word 3,$(MAKECMDGOALS)),$(MAIN_BRANCH)))
	@$(GIT) checkout $(HOTFIX_TARGET)
	@$(GIT) pull origin $(HOTFIX_TARGET)
ifneq ($(HOTFIX_NAME),)
	@$(GIT) checkout -b hotfix/$(HOTFIX_NAME) $(HOTFIX_TARGET)
else
	@$(GIT) checkout -b hotfix/$(shell $(SEMVER) bump patch -g) $(HOTFIX_TARGET)
endif

## GIt-Flow Hotfix publishing
gitflow/hotfix/publish:
	$(call assert-set,GIT)
	$(eval HOTFIX_NAME := $(filter-out $@,$(MAKECMDGOALS)))
ifneq ($(HOTFIX_NAME),)
	@$(GIT) checkout hotfix/$(HOTFIX_NAME)
	@$(GIT) push origin hotfix/$(HOTFIX_NAME)
else ifeq ($(GIT_BRANCH_PREFIX),hotfix)
	@$(GIT) push origin $(GIT_BRANCH)
else
	$(error "You must specify a hotfix name to publish, or being working on a hotfix branch")
endif

## Git-Flow Hotfix finish (manual)
gitflow/hotfix/manual/finish:
	$(call assert-set,GIT)
	$(eval WORD_COUNT := $(words $(MAKECMDGOALS)))
	$(eval HOTFIX_NAME := $(if $(filter 2 3,$(WORD_COUNT)),$(word 2,$(MAKECMDGOALS))))
	$(eval HOTFIX_TARGET := $(if $(filter 3,$(WORD_COUNT)),$(word 3,$(MAKECMDGOALS)),$(MAIN_BRANCH)))
ifneq ($(HOTFIX_NAME),)
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) pull origin $(MAIN_BRANCH)
	@$(GIT) merge --no-ff hotfix/$(HOTFIX_NAME)
	@$(GIT) tag -a $(HOTFIX_NAME) -m "HotFix Release $(HOTFIX_NAME)"
	@$(GIT) push origin $(MAIN_BRANCH)
	@$(GIT) push origin $(MAIN_BRANCH) --tags
else
	$(error "You must specify a hotfix name to publish")
endif

## Git-Flow release start next version, type inferred from input. (major, minor, patch)
gitflow/release/start/%: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) checkout -b release/$(shell $(SEMVER) bump $(subst gitflow/release/start/,,$@) -g) develop

## Git-Flow release start - this process uses the GitVersion tool to infer the next version
gitflow/release/start: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) checkout -b release/v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch) develop


## Git-Flow release finish (manual)
gitflow/release/manual/finish:
	$(call assert-set,GIT)
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) pull origin $(MAIN_BRANCH)
	@$(GIT) merge --no-ff release/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) tag -a $(filter-out $@,$(MAKECMDGOALS)) -m "Release $(filter-out $@,$(MAKECMDGOALS))"
	@$(GIT) push origin $(MAIN_BRANCH)
	@$(GIT) push origin $(MAIN_BRANCH) --tags
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) merge --no-ff release/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) push origin develop
	@$(GIT) branch -d release/$(filter-out $@,$(MAKECMDGOALS))

## Git-Flow release publish (manual)
gitflow/release/manual/publish:
	$(call assert-set,GIT)
	@$(GIT) checkout release/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) push origin release/$(filter-out $@,$(MAKECMDGOALS))

## Git-Flow release publish
gitflow/release/publish:
	$(call assert-set,GIT)
ifeq ($(GIT_BRANCH_PREFIX),release)
	@$(GIT) push -u origin $(GIT_BRANCH)
else
	$(error "You must be in a release branch to publish")
endif

## Git-Flow release publish Pull-Request against MAIN and DEVELOP branches
gitflow/release/finish: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	$(call assert-set,GH)
ifeq ($(GIT_BRANCH_PREFIX),release)
	@if [[ \
		"$$(git ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$(git rev-parse HEAD)" \
	]]; then \
		$(GH) pr create -B $(MAIN_BRANCH) -b "Release v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" \
			-t "Release v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" ; \
		$(GH) pr create -B develop -b "Development Merge from Release v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" \
			-t "Merge from Release v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" ; \
	else \
		echo "You must be in the latest commit of the release branch to publish"; \
	fi
else
	$(error "You must be in a release branch to publish")
endif

# Recover the list of PRs from the release branch
LIST ?= $(shell $(GH) pr list --state open -H release/$(filter-out $@,$(MAKECMDGOALS)) --json number -q '.[].number')

## Git-Flow release finish (automatic via pr)
gitflow/release/finish/comment: gitflow/deps
# Creates a milestone on github
# Creates a PR to merge automatically into master and
	$(call assert-set,GIT)
	$(call assert-set,GH)
	@$(foreach var, $(LIST), $(GH) pr comment $(var) -b "/finish";)

## Git-Flow release purge
gitflow/release/purge: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	@$(GIT) branch -D release/v$(shell $(GITVERSION) -output json -showvariable SemVer)
	@$(GIT) push origin -d release/v$(shell $(GITVERSION) -output json -showvariable SemVer)


## Git-Flow support start
gitflow/support/start:
	$(call assert-set,GIT)
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) checkout -b support/$(filter-out $@,$(MAKECMDGOALS)) $(filter-out $@,$(MAKECMDGOALS))

## Git-Flow support publish
gitflow/support/publish:
	$(call assert-set,GIT)
ifeq ($(filter-out $@,$(MAKECMDGOALS)),)
	@$(GIT) checkout support/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) push origin support/$(filter-out $@,$(MAKECMDGOALS))
else ifeq ($(GIT_BRANCH_PREFIX),support)
	@$(GIT) push origin $(GIT_BRANCH)
else
	$(error "You must specify a support version to publish, or being working on a support branch")
endif

## Git-Flow version tagging
gitflow/version/tag: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
ifeq ($(GIT_BRANCH),$(MAIN_BRANCH))
	@if [[ \
		"$$(git ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$(git rev-parse HEAD)" \
	]]; then \
		$(GIT) tag v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch) -m "Version Tagging: v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" ; \
		echo "Tagged v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)..."; \
	else \
		echo "You must be in the latest commit of the branch to tag"; \
	fi
else
	@if [[ \
		"$$(git ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$(git rev-parse HEAD)" \
	]]; then \
		$(GIT) tag v$(shell $(GITVERSION) -output json -showvariable SemVer) -m "Version Tagging: v$(shell $(GITVERSION) -output json -showvariable SemVer)" ; \
		echo "Tagged v$(shell $(GITVERSION) -output json -showvariable SemVer)..."; \
	else \
		echo "You must be in the latest commit of the branch to tag"; \
	fi
endif

## Git-Flow version publish to remote (push tags
gitflow/version/publish:
	$(call assert-set,GIT)
	@if [[ \
		"$$(git ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$(git rev-parse HEAD)" \
	]]; then \
		$(GIT) push origin --tags ; \
	else \
	  echo "You must be in the latest commit of the branch to push tags!"; \
	fi

## Retrieve the SemVer version with GitVersion tool
gitflow/version/semver: gitflow/deps
	$(call assert-set,GITVERSION)
	@$(GITVERSION) -output json -showvariable SemVer

## Retrieve the Full SemVer version (commits count) with GitVersion tool translate + to - for compatibility with Helm/Docker
gitflow/version/semver/full: gitflow/deps
	$(call assert-set,GITVERSION)
	@$(GITVERSION) -output json -showvariable FullSemVer | tr '+' '-'

# Ignore any additional arguments that come from MAKECMDGOALS
#gitflow/%:
#	@: