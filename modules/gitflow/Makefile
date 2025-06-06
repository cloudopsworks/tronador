GIT:= $(shell which git)
MAIN_BRANCH:=$(shell $(GIT) branch -r --format "%(refname:short)" | awk '/origin/ && ($$0 ~ /origin\/(master|main)/) {sub("origin/", ""); print}')
export GIT_BRANCH ?= $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null)
export GIT_REMOTE ?= $(shell $(GIT) ls-remote --get-url 2>/dev/null)
export GIT_BRANCH_PREFIX ?= $(shell $(GIT) rev-parse --abbrev-ref HEAD 2>/dev/null | sed -e 's/\(.*\)\/.*/\1/')
GH ?= $(INSTALL_PATH)/gh
SEMVER ?= $(INSTALL_PATH)/semver
GITVERSION ?= $(INSTALL_PATH)/gitversion

# Gitflow shorcut for gitflow/ commands
gf/%:
	$(call assert-set,GIT)
	@$(MAKE) gitflow/$*

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
	@$(GIT) fetch origin --prune
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

## Git-Flow feature finish (manual), this receives the following call pattern: make gitflow/feature/manual/finish:<feature_name>
gitflow/feature/finish/%:
	$(call assert-set,GIT)
	$(eval FEAT_NAME := $(subst gitflow/feature/finish/,,$@))
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
	  @$(GIT) push --set-upstream origin feature/$(FEAT_NAME) ; \
	else \
	  echo "You must specify a feature name." ; \
	  exit 1 ; \
	fi

## Git-Flow feature publish
gitflow/feature/publish:
	$(call assert-set,GIT)
ifeq ($(GIT_BRANCH_PREFIX),feature)
	@$(GIT) push --set-upstream origin $(GIT_BRANCH)
else
	$(error "You must specify a feature name to publish, or being working on a feature branch")
endif

## Git-Flow feature purge, this receives the following call pattern: make gitflow/feature/purge:<feature_name>
gitflow/feature/purge/%: gitflow/co/develop
	$(call assert-set,GIT)
	$(eval FEAT_NAME := $(subst gitflow/feature/purge/,,$@))
	@$(GIT) branch -D feature/$(FEAT_NAME)
	@$(GIT) push origin -d feature/$(FEAT_NAME)

## Git-Flow feature purge, this receives the following call pattern: make gitflow/feature/purge-no-develop:<feature_name> # This will not checkout develop branch
gitflow/feature/purge-no-develop/%: gitflow/co/main
	$(call assert-set,GIT)
	$(eval FEAT_NAME := $(subst gitflow/feature/purge-no-develop/,,$@))
	@$(GIT) branch -D feature/$(FEAT_NAME)
	@$(GIT) push origin -d feature/$(FEAT_NAME)

## GIt-Flow Hotfix start
gitflow/hotfix/start: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	$(call assert-set,GITVERSION)
ifeq ($(GIT_BRANCH_PREFIX),support)
	@echo "You are in a support branch, we are checking out from $(GIT_BRANCH) to start a hotfix."
	@$(GIT) checkout -b hotfix/$(shell $(SEMVER) bump patch v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)) $(GIT_BRANCH)
else
	@$(MAKE) gitflow/co/main
	@$(GIT) checkout -b hotfix/$$($(SEMVER) bump patch v$$($(GITVERSION) -output json -showvariable MajorMinorPatch)) $(MAIN_BRANCH)
endif
#
#	@REV=$$($(GITVERSION) -output json -showvariable MajorMinorPatch) ; \
#		BUMP=$$($(SEMVER) bump patch v$$REV) ; \
#		$(GIT) checkout -b hotfix/$$BUMP $(MAIN_BRANCH)

## GIt-Flow Hotfix publishing
gitflow/hotfix/publish:
	$(call assert-set,GIT)
ifeq ($(GIT_BRANCH_PREFIX),hotfix)
	@$(GIT) push --set-upstream origin $(GIT_BRANCH)
else
	$(error "You must specify a hotfix name to publish, or being working on a hotfix branch")
endif

## Git-Flow Hotfix finish (automatic via PR)
gitflow/hotfix/finish: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GH)
ifeq ($(GIT_BRANCH_PREFIX),hotfix)
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		$(GH) pr create -B $(MAIN_BRANCH) -b "Hotfix Release $(GIT_BRANCH), will merge the code into $(MAIN_BRANCH)" \
			-t "Hotfix Release $(GIT_BRANCH)" ; \
	else \
		echo "You must be in the latest commit of the release branch to publish"; \
	fi
else
	$(error "You must be in a hotfix branch to finish")
endif

## Git-Flow Hotfix finish (local)
gitflow/hotfix/finish/local: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	$(eval RELVERSION := "v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)")
	$(eval MAJOR_VERSION := $(shell echo "$(RELVERSION)" | cut -d. -f1))
	$(eval MINOR_VERSION := $(shell echo "$(RELVERSION)" | cut -d. -f2))
ifeq ($(GIT_BRANCH_PREFIX),hotfix)
	# Check if we have a support branch with the same major.minor version on the git tree
	$(eval SUPPORT_BRANCH := $(shell $(GIT) branch --list 'support/$(MAJOR_VERSION).$(MINOR_VERSION)*'  --format '%(refname:short)'))
	$(eval WORKING_BRANCH := $(if $(SUPPORT_BRANCH),$(SUPPORT_BRANCH),$(MAIN_BRANCH)))
	@echo "Major Version is: $(MAJOR_VERSION)"
	@echo "Minor Version is: $(MINOR_VERSION)"
	@echo "Working Branch is: $(WORKING_BRANCH)"
	@$(GIT) checkout $(WORKING_BRANCH)
	@$(GIT) pull origin $(WORKING_BRANCH)
	@$(GIT) merge --no-ff hotfix/$(RELVERSION)
	@$(GIT) tag -a $(RELVERSION) -m "HotFix Release $(HOTFIX_NAME)"
	@$(GIT) push origin $(WORKING_BRANCH)
	@$(GIT) push origin $(RELVERSION)
	@$(GIT) branch -d hotfix/$(RELVERSION)
	@$(GIT) push origin -d hotfix/$(RELVERSION)
else
	$(error "You must be in a hotfix branch to finish")
endif

### Git-Flow Hotfix finish (manual) UNSUPPORTED!
#gitflow/hotfix/finish/%:
#	$(call assert-set,GIT)
#	$(eval HOTFIX_NAME := $(subst gitflow/hotfix/finish/,,$@))
#	@$(GIT) checkout $(MAIN_BRANCH)
#	@$(GIT) pull origin $(MAIN_BRANCH)
#	@$(GIT) merge --no-ff hotfix/$(HOTFIX_NAME)
#	@$(GIT) tag -a $(HOTFIX_NAME) -m "HotFix Release $(HOTFIX_NAME)"
#	@$(GIT) push origin $(MAIN_BRANCH)
#	@$(GIT) push origin $(HOTFIX_NAME)
#	@$(GIT) branch -d hotfix/$(HOTFIX_NAME)
#	@$(GIT) push origin -d hotfix/$(HOTFIX_NAME)
#

### Git-Flow hotfix purge
gitflow/hotfix/purge: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
ifeq ($(GIT_BRANCH_PREFIX),hotfix)
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) branch -D $(GIT_BRANCH)
	@$(GIT) push origin -d $(GIT_BRANCH)
else
	$(error "You must be in a hotfix branch to purge")
endif

## Git-Flow hotfix purge with hotfix-version
gitflow/hotfix/purge/%: gitflow/deps gitflow/co/main
	$(call assert-set,GIT)
	$(eval BUMP_VERSION := $(subst gitflow/hotfix/purge/,,$@))
	$(eval BUMP_VER := $(if $(filter v%,$(BUMP_VERSION)),$(BUMP_VERSION),v$(BUMP_VERSION)))
	@$(GIT) branch -D hotfix/$(BUMP_VER)
	@$(GIT) push origin -d hotfix/$(BUMP_VER)

# Git check Develop branch
gitflow/check/develop:
	$(call assert-set,GIT)
	@$(GIT) fetch origin
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		echo "You are in the latest commit of the develop branch, Validation Complete."; \
	else \
		echo "You must be in the latest commit of the develop branch to create release"; \
	  	exit 1
	fi

## Git-Flow release start next  minor version.
gitflow/release/start/minor: gitflow/deps gitflow/co/develop
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	$(call assert-set,GITVERSION)
	@$(GIT) checkout -b release/$(shell $(SEMVER) bump minor v$(shell $(GITVERSION) -showvariable MajorMinorPatch)) develop

## Git-Flow release start next  major version.
gitflow/release/start/major: gitflow/deps gitflow/co/develop
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	$(call assert-set,GITVERSION)
	@$(GIT) checkout -b release/$(shell $(SEMVER) bump major v$(shell $(GITVERSION) -showvariable MajorMinorPatch)) develop

## Git-Flow release start next  patch version.
gitflow/release/start/patch: gitflow/deps gitflow/co/develop
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	$(call assert-set,GITVERSION)
	@$(GIT) checkout -b release/$(shell $(SEMVER) bump patch v$(shell $(GITVERSION) -showvariable MajorMinorPatch)) develop

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

## Git-Flow release finish (automatic via pr)
gitflow/release/finish/comment: gitflow/deps
# Creates a milestone on github
# Creates a PR to merge automatically into master and
	$(call assert-set,GIT)
	$(call assert-set,GH)
	# Recover the list of PRs from the release branch
ifeq ($(GIT_BRANCH_PREFIX),release)
	$(eval LIST := $(shell $(GH) pr list --state open -H $(GIT_BRANCH)) --json number -q '.[].number'))
	@$(foreach var, $(LIST), $(GH) pr comment $(var) -b "/approved";)
else
	$(error "You must be in a release branch to approve the PRs")
endif

export BEACON_STATUS ?= "no"
gitflow/check/beacon:
	@touch /tmp/.gitflow_release_beacon
	$(eval BEACON_STATUS := "$(shell cat /tmp/.gitflow_release_beacon)")

## Git-Flow release finish (manual), this receives the following call pattern: make gitflow/release/manual/finish:<version>
gitflow/release/finish/local: gitflow/deps gitflow/check/beacon
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	$(eval RELVERSION := "v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)")
#ifeq ($(GIT_BRANCH_PREFIX),release)
ifneq ($(BEACON_STATUS),merge_master)
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) pull origin $(MAIN_BRANCH)
	@$(GIT) merge --no-ff release/$(RELVERSION)
	@echo "merge_master" > /tmp/.gitflow_release_beacon
endif
ifneq ($(BEACON_STATUS),tag_release)
	@$(GIT) tag -a $(RELVERSION) -m "Release $(RELVERSION)"
	@echo "tag_release" > /tmp/.gitflow_release_beacon
endif
ifneq ($(BEACON_STATUS),push_master)
	@$(GIT) push origin $(MAIN_BRANCH)
	@$(GIT) push origin $(RELVERSION)
	@echo "push_master" > /tmp/.gitflow_release_beacon
endif
ifneq ($(BEACON_STATUS),merge_develop)
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) merge --no-ff release/$(RELVERSION)
	@echo "merge_develop" > /tmp/.gitflow_release_beacon
endif
ifneq ($(BEACON_STATUS),push_develop)
	@$(GIT) push origin develop
	@$(GIT) branch -d release/$(RELVERSION)
	@$(GIT) push -d origin release/$(RELVERSION)
	@rm -fr /tmp/.gitflow_release_beacon
endif
#else
#	$(error "You must be in a release branch to finish locally")
#endif

## Git-Flow release finish (manual), this receives the following call pattern: make gitflow/release/manual/finish:<version>
gitflow/release/finish/%: gitflow/co/main
	$(call assert-set,GIT)
	$(eval RELVERSION := $(subst gitflow/release/finish/,,$@))
	@$(GIT) checkout $(MAIN_BRANCH)
	@$(GIT) pull origin $(MAIN_BRANCH)
	@$(GIT) merge --no-ff release/$(RELVERSION)
	@$(GIT) tag -a $(RELVERSION) -m "Release $(RELVERSION)"
	@$(GIT) push origin $(MAIN_BRANCH)
	@$(GIT) push origin $(RELVERSION)
	@$(GIT) checkout develop
	@$(GIT) pull origin develop
	@$(GIT) merge --no-ff release/$(RELVERSION)
	@$(GIT) push origin develop
	@$(GIT) branch -d release/$(RELVERSION)
	@$(GIT) push -d origin release/$(RELVERSION)

## Git-Flow release publish (manual), this receives the following call pattern: make gitflow/release/manual/publish:<version>
gitflow/release/publish/%:
	$(call assert-set,GIT)
	$(eval BUMP_VERSION := $(subst gitflow/release/publish/,,$@))
	$(eval BUMP_VER := $(if $(filter v%,$(BUMP_VERSION)),$(BUMP_VERSION),v$(BUMP_VERSION)))
	@$(GIT) checkout release/$(BUMP_VER)
	@$(GIT) push --set-upstream origin release/$(BUMP_VER)

## Git-Flow release publish
gitflow/release/publish:
	$(call assert-set,GIT)
ifeq ($(GIT_BRANCH_PREFIX),release)
	@$(GIT) push --set-upstream origin $(GIT_BRANCH)
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

## Git-Flow release purge on current tag
gitflow/release/purge: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	$(eval BUMP_VER := v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch))
	@$(MAKE) gitflow/co/main
	@$(GIT) branch -D release/$(BUMP_VER)
	@$(GIT) push origin -d release/$(BUMP_VER)

## Git-Flow release purge on specific version
gitflow/release/purge/%: gitflow/deps
	$(call assert-set,GIT)
	$(eval BUMP_VERSION := $(subst gitflow/release/purge/,,$@))
	$(eval BUMP_VER := $(if $(filter v%,$(BUMP_VERSION)),$(BUMP_VERSION),v$(BUMP_VERSION)))
	@$(MAKE) gitflow/co/main
	@$(GIT) branch -D release/$(BUMP_VER)
	@$(GIT) push origin -d release/$(BUMP_VER)


## Git-Flow support start, this receives the following call pattern: make gitflow/support/start:<version>
gitflow/support/start/%: gitflow/co/main
	$(call assert-set,GIT)
	$(eval RELVERSION := $(subst gitflow/support/start/,,$@))
	@$(GIT) checkout -b support/$(RELVERSION) $(RELVERSION)

## Git-Flow support publish, this receives the following call pattern: make gitflow/support/publish:<version>
gitflow/support/publish/%:
	$(call assert-set,GIT)
	$(eval RELVERSION := $(subst gitflow/support/publish/,,$@))
	@if [[ "$(RELVERSION)" != "" ]] ; then \
  	  $(GIT) checkout support/$(RELVERSION) ; \
	  $(GIT) push --set-upstream origin support/$(RELVERSION) ; \
	else \
	  echo "You must specify a support version to publish." ; \
	  exit 1 ; \
	fi

## Git-Flow support publish
gitflow/support/publish:
	$(call assert-set,GIT)
ifeq ($(GIT_BRANCH_PREFIX),support)
	@$(GIT) push --set-upstream origin $(GIT_BRANCH)
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
		exit 1 ; \
	fi
else
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		$(GIT) tag v$(shell $(GITVERSION) -output json -showvariable SemVer) -m "Version Tagging: v$(shell $(GITVERSION) -output json -showvariable SemVer)" ; \
		echo "Tagged v$(shell $(GITVERSION) -output json -showvariable SemVer)..."; \
	else \
		echo "You must be in the latest commit of the branch to tag"; \
		exit 1 ; \
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
gitflow/version/publish: gitflow/deps
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION)
	@if [[ \
		"$$($(GIT) ls-remote $(GIT_REMOTE) $(GIT_BRANCH) | cut -f1)" == "$$($(GIT) rev-parse HEAD)" \
	]]; then \
		$(GIT) push origin $(shell $(GIT) describe --tags --abbrev=0) ; \
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

## Creates _VERSION FILE from the MajorMinorPatch version (strip newline) with GitVersion tool, location sent on .github folder commit and push to repo
gitflow/version/file: gitflow/deps
	$(call assert-set,GITVERSION)
	@echo "Pushing version to .github/_VERSION ..."
	@echo -n "v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" > .github/_VERSION
	@echo "Add and commit the version file to repository..."
	@$(GIT) add .github/_VERSION
	@$(GIT) commit -m "chore: Version Bump"
	@$(GIT) push origin $(GIT_BRANCH)
	@echo "Version file completed."


# Ignore any additional arguments that come from MAKECMDGOALS
#gitflow/%:
#	@: