GIT:= $(shell which git)
MAIN_BRANCH:=$(shell $(GIT) branch -l --format "%(refname:short)" | egrep "master|main")
export GIT_BRANCH ?= $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null)
export GIT_BRANCH_PREFIX ?= $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null | sed -e 's/\(.*\)\/.*/\1/')
export GH ?= $(INSTALL_PATH)/gh
export SEMVER ?= $(INSTALL_PATH)/semver
export GITVERSION ?= $(INSTALL_PATH)/gitversion

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

## Git-Flow feature start
gitflow/feature/start:
	$(call assert-set,GIT)
	@$(GIT) checkout -b feature/$(filter-out $@,$(MAKECMDGOALS)) develop

## Git-Flow feature finish
gitflow/feature/finish:
	$(call assert-set,GIT)
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) merge --no-ff feature/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) branch -d feature/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) push origin develop

## Git-Flow feature publish
gitflow/feature/publish:
	$(call assert-set,GIT)
	@$(GIT) checkout feature/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) push origin feature/$(filter-out $@,$(MAKECMDGOALS))

## Git-Flow release start next version, type inferred from input. (major, minor, patch)
gitflow/release/start/%: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) checkout -b release/$(shell $(SEMVER) bump $(subst gitflow/release/start/,,$@) -g) develop
	@$(GIT) push -u origin release/$(shell $(SEMVER) bump $(subst gitflow/release/start/,,$@) -g)

## Git-Flow release start
gitflow/release/start: gitflow/release/start/minor

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
gitflow/release/publish:
	$(call assert-set,GIT)
	@$(GIT) checkout release/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) push origin release/$(filter-out $@,$(MAKECMDGOALS))

# Recover the list of PRs from the release branch
LIST ?= $(shell $(GH) pr list --state open -H release/$(filter-out $@,$(MAKECMDGOALS)) --json number -q '.[].number')

## Git-Flow release finish (automatic via pr)
# Creates a milestone on github
# Creates a PR to merge automatically into master and
gitflow/release/finish: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	$(call assert-set,GH)
	@$(foreach var, $(LIST), $(GH) pr comment $(var) -b "/finish";)

## Git-Flow support start
gitflow/support/start:
	$(call assert-set,GIT)
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) checkout -b support/$(filter-out $@,$(MAKECMDGOALS)) $(filter-out $@,$(MAKECMDGOALS))

## Git-Flow support publish
gitflow/support/publish: gitflow/deps
	$(call assert-set,GIT)
ifdef ($(filter-out $@,$(MAKECMDGOALS)))
	@$(GIT) checkout support/$(filter-out $@,$(MAKECMDGOALS))
	@$(GIT) push origin support/$(filter-out $@,$(MAKECMDGOALS))
else ifeq ($(GIT_BRANCH_PREFIX),support)
	@$(GIT) push origin $(GIT_BRANCH)
else
	$(error "You must specify a support version to publish, or being working on a support branch")
endif

# Ignore any additional arguments that come from MAKECMDGOALS
%:
	@: