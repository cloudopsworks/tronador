# This module administers repositories templates and allows automated upgrades of workflows
#
TMP=/tmp
JAVA_TEMPLATE=https://github.com/cloudopsworks/java-app-template.git
DOCKER_TEMPLATE=https://github.com/cloudopsworks/docker-app-template.git
NODE_TEMPLATE=https://github.com/cloudopsworks/node-app-template.git
PYTHON_TEMPLATE=https://github.com/cloudopsworks/python-app-template.git
MERGE_TEMPLATE := 0
GH ?= $(INSTALL_PATH)/gh
CURR_TEMPLATE := $(shell $(GIT) remote | grep template)

repos/template/java:
ifneq (,$(wildcard .github/.java))
ifeq (,$(CURR_TEMPLATE))
	@echo "Java Project Template will be pulled"
	$(GIT) remote add template $(JAVA_TEMPLATE) --no-tags --no-mirror --no-fetch
else
	@echo "Java Project Template already pulled"
endif
MERGE_TEMPLATE := 1
endif

repos/template/node:
ifneq (,$(wildcard .github/.node))
ifeq (,$(CURR_TEMPLATE))
	@echo "NodeJS Project Template will be pulled"
	$(GIT) remote add template $(NODE_TEMPLATE) --no-tags --no-mirror --no-fetch
else
	@echo "NodeJS Project Template already pulled"
endif
MERGE_TEMPLATE := 1
endif

repos/template/docker:
ifneq (,$(wildcard .github/.docker))
ifeq (,$(CURR_TEMPLATE))
	@echo "Docker Project Template will be pulled"
	$(GIT) remote add template $(DOCKER_TEMPLATE) --no-tags --no-mirror --no-fetch
else
	@echo "Docker Project Template already pulled"
endif
MERGE_TEMPLATE := 1
endif

repos/template/python:
ifneq (,$(wildcard .github/.python))
ifeq (,$(CURR_TEMPLATE))
	@echo "Python Project Template will be pulled"
	$(GIT) remote add template $(PYTHON_TEMPLATE) --no-tags --no-mirror --no-fetch
else
	@echo "Python Project Template already pulled"
endif
MERGE_TEMPLATE := 1
endif

## Update CICD Pipeline footer versioning
repos/cicd/update:
	@echo "Updating CICD Pipeline cloudopsworks-ci.yaml"
	@grep -q "#workflow-version-tag" .github/cloudopsworks-ci.yaml || echo "\n\n############ DO NOT MODIFY BELOW ############\n#workflow-version-tag: 1.0.0" >> .github/cloudopsworks-ci.yaml
ifeq ($(OS),darwin)
	@sed -i '' "s|#workflow-version-tag.*|#workflow-version-tag: $$(cat .github/_VERSION) - hash: $$(git for-each-ref refs/remotes/template --sort="-committerdate" | head -1 | cut -d ' ' -f 1)|g" .github/cloudopsworks-ci.yaml
else
	@sed -i "s|#workflow-version-tag.*|#workflow-version-tag: $$(cat .github/_VERSION) - hash: $$(git for-each-ref refs/remotes/template --sort="-committerdate" | head -1 | cut -d ' ' -f 1)|g" .github/cloudopsworks-ci.yaml
endif


## Upgrade Repository from Templates
repos/upgrade: packages/install/gh repos/template/java repos/template/docker repos/template/node repos/template/python
	$(call assert-set,GIT)
	$(call assert-set,GH)
ifeq (1,$(MERGE_TEMPLATE))
	@echo "Upgrading repository, current Version: $$(cat .github/_VERSION)"
	@echo "Setting default repository: $(GIT_ORG)/$(GIT_REPO)"
	@$(GH) repo set-default $(GIT_ORG)/$(GIT_REPO)
	@echo "Fetching template repository"
	@$(GIT) fetch template master
	@$(GIT) checkout template/master -- .github/workflows Makefile .github/_VERSION
	@echo "Copying workflows from version: $$(cat .github/_VERSION)"
	@cp .github/workflows/.template/*.yml .github/workflows
	@cp .github/workflows/.template/*.yaml .github/workflows
ifeq ($(OS),darwin)
	@find .github/workflows -depth 1 -type f -name '*.yml' -print -exec sed -i '' 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
	@find .github/workflows -depth 1 -type f -name '*.yaml' -print -exec sed -i '' 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
else
	@find .github/workflows -depth 1 -type f -name '*.yml' -print -exec sed -i 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
	@find .github/workflows -depth 1 -type f -name '*.yaml' -print -exec sed -i 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
endif
	@echo "Removing Initial.yml script, only needed upon creation."
	@rm -f .github/workflows/initial.yml
	@echo "Committing changes"
	@$(GIT) add .github/workflows Makefile
	@$(GIT) commit -m "chore: Upgrade repository from template, version: $$(cat .github/_VERSION)"
	@echo "Repository upgraded to version: $$(cat .github/_VERSION)"
	@echo "Please review changes and push to remote repository"
	$(MAKE) repos/cicd/update
else
	@echo "No templates supported to upgrade by this script, skipping upgrade"
endif