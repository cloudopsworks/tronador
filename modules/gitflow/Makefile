GIT:= $(shell which git)
MAIN_BRANCH:=$(shell $(GIT) branch -l --format "%(refname:short)" | egrep "master|main")
GH:=$(INSTALL_DIR)/gh
GITVERSION:=$(INSTALL_DIR)/gitversion
SEMVER:=$(INSTALL_DIR)/semver

## Git-Flow Initialize develop branch
gitflow/init:
	$(call assert-set,GIT)
	if [ "$(MAIN_BRANCH)" = "" ]; then \
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

## Git-Flow feature start
gitflow/feature-start:
	$(call assert-set,GIT)
	$(GIT) checkout -b feature/$(filter-out $@,$(MAKECMDGOALS)) develop

## Git-Flow feature finish
gitflow/feature-finish:
	$(call assert-set,GIT)
	$(GIT) checkout develop
	$(GIT) pull origin develop
	$(GIT) merge --no-ff feature/$(filter-out $@,$(MAKECMDGOALS))
	$(GIT) branch -d feature/$(filter-out $@,$(MAKECMDGOALS))
	$(GIT) push origin develop

## Git-Flow feature publish
gitflow/feature-publish:
	$(call assert-set,GIT)
	$(GIT) checkout feature/$(filter-out $@,$(MAKECMDGOALS))
	$(GIT) push origin feature/$(filter-out $@,$(MAKECMDGOALS))

## Git-Flow release start next version (major)
gitflow/release-start-major: packages/install/semver
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	$(GIT) checkout develop
	$(GIT) pull origin develop
	$(GIT) checkout -b release/$(shell $(SEMVER) bump major -g) develop
	$(GIT) push -u origin release/$(shell $(SEMVER) bump major -g)

## Git-Flow release start next version (minor)
gitflow/release-start-minor: packages/install/semver
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	$(GIT) checkout develop
	$(GIT) pull origin develop
	$(GIT) checkout -b release/$(shell $(SEMVER) bump minor -g) develop
	$(GIT) push -u origin release/$(shell $(SEMVER) bump minor -g)

## Git-Flow release start next version (patch)
gitflow/release-start-patch: packages/install/semver
	$(call assert-set,GIT)
	$(call assert-set,SEMVER)
	$(GIT) checkout develop
	$(GIT) pull origin develop
	$(GIT) checkout -b release/$(shell $(SEMVER) bump patch -g) develop
	$(GIT) push -u origin release/$(shell $(SEMVER) bump patch -g)

## Git-Flow release start
gitflow/release-start:
	$(call assert-set,GIT)
	$(GIT) checkout develop
	$(GIT) pull origin develop
	$(GIT) checkout -b release/$(filter-out $@,$(MAKECMDGOALS)) develop
	$(GIT) push -u origin release/$(filter-out $@,$(MAKECMDGOALS))

## Git-Flow release finish (manual)
gitflow/release-manual-finish:
	$(call assert-set,GIT)
	$(GIT) checkout $(MAIN_BRANCH)
	$(GIT) pull origin $(MAIN_BRANCH)
	$(GIT) merge --no-ff release/$(filter-out $@,$(MAKECMDGOALS))
	$(GIT) tag -a $(filter-out $@,$(MAKECMDGOALS)) -m "Release $(filter-out $@,$(MAKECMDGOALS))"
	$(GIT) push origin $(MAIN_BRANCH)
	$(GIT) push origin $(MAIN_BRANCH) --tags
	$(GIT) checkout develop
	$(GIT) pull origin develop
	$(GIT) merge --no-ff release/$(filter-out $@,$(MAKECMDGOALS))
	$(GIT) push origin develop
	$(GIT) branch -d release/$(filter-out $@,$(MAKECMDGOALS))

## Git-Flow release finish (automatic via pr)
# Creates a milestone on github
# Creates a PR to merge automatically into master and
gitflow/release-finish: packages/install/gitversion packages/install/gh
	$(call assert-set,GIT)
	$(call assert-set,GITVERSION_EXE)
	$(call assert-set,GH_EXE)
	echo "{	\"title\":\"$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)\",\"description\":\"Release v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)\"}" | \
		gh api --method POST repos/:owner/:repo/milestones --input - | \
		jq '{ html_url: .html_url, state: .state, created_at: .created_at }'
	gh pr create --title "Release $(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" \
		-B $(MAIN_BRANCH) -m $(shell $(GITVERSION) -output json -showvariable MajorMinorPatch) \
		-H release/v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch) -b ""
	gh pr create --title "Release Development Merge $(shell $(GITVERSION) -output json -showvariable MajorMinorPatch)" \
		-B develop -m $(shell $(GITVERSION) -output json -showvariable MajorMinorPatch) \
		-H release/v$(shell $(GITVERSION) -output json -showvariable MajorMinorPatch) -b ""

## Git-Flow support start
gitflow/support-start:
	$(call assert-set,GIT)
	$(GIT) checkout
	$(GIT) checkout -b support/$(filter-out $@,$(MAKECMDGOALS)) $(filter-out $@,$(MAKECMDGOALS))

# Ignore any additional arguments that come from MAKECMDGOALS
%:
	@: