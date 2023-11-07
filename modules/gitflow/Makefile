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
ifeq ($(MAIN_BRANCH),)
	@$(GIT) checkout -b main
	@$(GIT) push -u origin main
	@$(GIT) checkout -b develop
	@$(GIT) push -u origin develop
else
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) pull origin $(MAIN_BRANCH)
	@$(GIT) checkout -b develop
	@$(GIT) push -u origin develop
endif

# Chceckout develop branch
gitflow/co/develop:
	$(call assert-set,GIT)
	@$(GIT) checkout develop
	@$(GIT) pull origin develop

# Chceckout main branch
gitflow/co/main:
	$(call assert-set,GIT)
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) pull origin $(MAIN_BRANCH)

# Install gitflow dependencies
gitflow/deps: packages/install/gitversion packages/install/gh packages/install/semver
	@exit 0

## Git-Flow feature start, this receives the following call pattern: make gitflow/feature/start:<feature_name>
gitflow/feature/start/%:
	$(call assert-set,GIT)
	$(eval FEAT_NAME ?= $(subst gitflow/feature/start/,,$@))
	@if [[ "$(FEAT_NAME)" != "" ]] ; then \
	  $(GIT) checkout -b feature/$(FEAT_NAME) develop ; \
	else \
	  echo "You must specify a feature name." ; \
	  exit 1 ; \
	fi

## Git-Flow feature finish (automatic via PR), this receives the following call pattern: make gitflow/feature/finish must be on a feature branch
gitflow/feature/finish: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GH)
ifeq ($(GIT_BRANCH_PREFIX),feature)
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		$(GH) pr create -B develop -b "Feature '$(GIT_BRANCH)' Finish, will merge the code into 'develop'." \
			-t "Feature '$(GIT_BRANCH)' Finish" ; \
	else \
		echo "You must be in the latest commit of the feature branch to publish"; \
	fi
else
	$(error "You must specify a feature name to publish, or being working on a feature branch")
endif

## Git-Flow feature finish (automatic via PR), this receives the following call pattern: make gitflow/feature/finish:<feature_name>
gitflow/feature/finish/%: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GH)
	$(eval FEAT_NAME := $(subst gitflow/feature/finish/,,$@))
	@if [[ "$(FEAT_NAME)" != "" ]]
	  $(GH) pr create -B develop -H feature/$(FEAT_NAME) -b "Feature 'feature/$(FEAT_NAME)' Finish, will merge the code into 'develop'." \
		-t "Feature 'feature/$(FEAT_NAME)' Finish" ; \
	else \
	  echo "You must specify a feature name." ; \
	  exit 1 ; \
	fi

## Git-Flow feature finish (manual), this receives the following call pattern: make gitflow/feature/manual/finish:<feature_name>
gitflow/feature/manual/finish/%:
	$(call assert-set,GIT)
	$(eval FEAT_NAME := $(subst gitflow/feature/manual/finish/,,$@))
	@if [[ "$(FEAT_NAME)" != "" ]] ; then \
	  $(GIT) checkout develop ; \
	  $(GIT) pull origin develop ; \
	  $(GIT) merge --no-ff feature/$(FEAT_NAME) ; \
	  $(GIT) branch -d feature/$(FEAT_NAME) ; \
	  $(GIT) push origin develop ; \
	else \
	  echo "You must specify a feature name." ; \
	  exit 1 ; \
	fi

## Git-Flow feature publish, this receives the following call pattern: make gitflow/feature/publish:<feature_name>
gitflow/feature/publish/%:
	$(call assert-set,GIT)
	$(eval FEAT_NAME := $(subst gitflow/feature/publish/,,$@))
	@if [[ "$(FEAT_NAME)" != "" ]] ; then \
	  @$(GIT) checkout feature/$(FEAT_NAME) ; \
	  @$(GIT) push origin feature/$(FEAT_NAME) ; \
	else \
	  echo "You must specify a feature name." ; \
	  exit 1 ; \
	fi

## Git-Flow feature publish
gitflow/feature/publish:
	$(call assert-set,GIT)
ifeq ($(GIT_BRANCH_PREFIX),feature)
	@$(GIT) push origin $(GIT_BRANCH)
else
	$(error "You must specify a feature name to publish, or being working on a feature branch")
endif

## Git-Flow feature purge, this receives the following call pattern: make gitflow/feature/purge:<feature_name>
gitflow/feature/purge/%: gitflow/co/develop
	$(call assert-set,GIT)
	$(eval FEAT_NAME := $(subst gitflow/feature/purge/,,$@))
	@$(GIT) branch -D feature/$(FEAT_NAME)
	@$(GIT) push origin -d feature/$(FEAT_NAME)


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
gitflow/hotfix/manual/finish%:
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

## Git-Flow Hotfix finish (automatic via PR)
gitflow/hotfix/finish: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GH)
	$(eval WORD_COUNT := $(words $(MAKECMDGOALS)))
	$(eval TARGET_BRANCH := $(if $(filter 2,$(WORD_COUNT)),$(word 2,$(MAKECMDGOALS)),$(MAIN_BRANCH)))
ifeq ($(GIT_BRANCH_PREFIX),hotfix)
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		$(GH) pr create -B $(TARGET_BRANCH) -b "Hotfix Release $(GIT_BRANCH), will merge the code into $(TARGET_BRANCH)" \
			-t "Hotfix Release $(GIT_BRANCH)" ; \
	else \
		echo "You must be in the latest commit of the release branch to publish"; \
	fi
else
	$(error "You must be in a hotfix branch to finish")
endif

## Git-Flow hotfix purge
gitflow/hotfix/purge: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	@$(GIT) branch -D hotfix/v$(shell $(GITVERSION) -output json -showvariable SemVer)
	@$(GIT) push origin -d hotfix/v$(shell $(GITVERSION) -output json -showvariable SemVer)

## Git-Flow release start next  minor version.
gitflow/release/start/minor: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	@$(GIT) checkout -b release/$(shell $(SEMVER) bump minor -g) develop

## Git-Flow release start next  major version.
gitflow/release/start/major: gitflow/deps gitflow/co/develop
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	@$(GIT) checkout -b release/$(shell $(SEMVER) bump major -g) develop

## Git-Flow release start next  patch version.
gitflow/release/start/patch: gitflow/deps gitflow/co/develop
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	@$(GIT) checkout -b release/$(shell $(SEMVER) bump patch -g) develop

## Git-Flow release start next version, for forced version the call is gitflow/release/start:<version>
gitflow/release/start/%: gitflow/deps gitflow/co/develop
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	$(eval BUMP_VERSION := $(subst gitflow/release/start/,,$@))
	# check that BUMP_VERSION is prefixed with v if not add it
	$(eval BUMP_VER := $(if $(filter v%,$(BUMP_VERSION)),$(BUMP_VERSION),v$(BUMP_VERSION)))
	@$(GIT) checkout -b release/$(BUMP_VER) develop

## Git-Flow release start - this process uses the GitVersion tool to infer the next version
gitflow/release/start: gitflow/deps gitflow/co/develop
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	@$(GIT) checkout -b release/v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch) develop

## Git-Flow release finish (manual), this receives the following call pattern: make gitflow/release/manual/finish:<version>
gitflow/release/manual/finish/%: gitflow/co/main
	$(call assert-set,GIT)
	$(eval RELVERSION := $(subst gitflow/release/manual/finish/,,$@))
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) pull origin $(MAIN_BRANCH)
	@$(GIT) merge --no-ff release/$(RELVERSION)
	@$(GIT) tag -a $(RELVERSION) -m "Release $(RELVERSION)"
	@$(GIT) push origin $(MAIN_BRANCH)
	@$(GIT) push origin $(MAIN_BRANCH) --tags
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) merge --no-ff release/$(RELVERSION)
	@$(GIT) push origin develop
	@$(GIT) branch -d release/$(RELVERSION)

## Git-Flow release publish (manual), this receives the following call pattern: make gitflow/release/manual/publish:<version>
gitflow/release/manual/publish/%:
	$(call assert-set,GIT)
	$(eval RELVERSION := $(subst gitflow/release/manual/publish/,,$@))
	@$(GIT) checkout release/$(RELVERSION)
	@$(GIT) push origin release/$(RELVERSION)

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
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
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


## Git-Flow support start, this receives the following call pattern: make gitflow/support/start:<version>
gitflow/support/start/%: gitflow/co/main
	$(call assert-set,GIT)
	$(eval RELVERSION := $(subst gitflow/support/start/,,$@))
	@$(GIT) checkout -b support/$(RELVERSION)) $(RELVERSION)

## Git-Flow support publish, this receives the following call pattern: make gitflow/support/publish:<version>
gitflow/support/publish/%:
	$(call assert-set,GIT)
	$(eval RELVERSION := $(subst gitflow/support/publish/,,$@))
	@if [[ "$(RELVERSION)" != "" ]] ; then \
  	  $(GIT) checkout support/$(RELVERSION) ; \
	  $(GIT) push origin support/$(RELVERSION) ; \
	else \
	  echo "You must specify a support version to publish." ; \
	  exit 1 ; \
	fi

## Git-Flow support publish
gitflow/support/publish:
	$(call assert-set,GIT)
ifeq ($(GIT_BRANCH_PREFIX),support)
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
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		$(GIT) tag v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch) -m "Version Tagging: v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" ; \
		echo "Tagged v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)..."; \
	else \
		echo "You must be in the latest commit of the branch to tag"; \
	fi
else
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		$(GIT) tag v$(shell $(GITVERSION) -output json -showvariable SemVer) -m "Version Tagging: v$(shell $(GITVERSION) -output json -showvariable SemVer)" ; \
		echo "Tagged v$(shell $(GITVERSION) -output json -showvariable SemVer)..."; \
	else \
		echo "You must be in the latest commit of the branch to tag"; \
	fi
endif

## Git-Flow version tagging with meta tagging for release&pre-release, meta tag is in form of <meta_tag>(. or -)<meta_tag_value>
gitflow/version/tag/%: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	$(eval META_TAG := $(subst gitflow/version/tag/,,$@))
ifeq ($(GIT_BRANCH),$(MAIN_BRANCH))
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		VER="$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)+deploy-$(META_TAG)" ; \
		$(GIT) tag v$$VER -m "Version Tagging: v$$VER" ; \
		echo "Tagged v$$VER ..."; \
	else \
		echo "You must be in the latest commit of the branch to tag"; \
	fi
else
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		VER="$(shell $(GITVERSION) -output json -showvariable SemVer)+deploy-$(META_TAG)" ; \
		$(GIT) tag v$$VER -m "Pre Release Version Tagging: v$$VER" ; \
		echo "Tagged v$$VER ..."; \
	else \
		echo "You must be in the latest commit of the branch to tag"; \
	fi
endif


## Git-Flow version publish to remote (push tags
gitflow/version/publish:
	$(call assert-set,GIT)
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
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