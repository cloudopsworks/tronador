# This module administers repositories templates and allows automated upgrades of workflows
#
TMP=/tmp
JAVA_TEMPLATE := "https://github.com/cloudopsworks/java-app-template.git"
DOCKER_TEMPLATE := "https://github.com/cloudopsworks/docker-app-template.git"
NODE_TEMPLATE := "https://github.com/cloudopsworks/node-app-template.git"
PYTHON_TEMPLATE := "https://github.com/cloudopsworks/python-app-template.git"
MERGE_TEMPLATE ?= 0

repos/template/java:
ifneq("","$(wildcard .github/.java)")
MERGE_TEMPLATE ?= 1
	@echo "Java Project Template will be pulled"
	$(GIT) remote add template $(JAVA_TEMPLATE)
endif

repos/template/node:
ifneq(,$(wildcard .github/.node))
MERGE_TEMPLATE ?= 1
	@echo "NodeJS Project Template will be pulled"
	$(GIT) remote add template $(NODE_TEMPLATE)
endif

repos/template/docker:
ifneq(,$(wildcard .github/.docker))
MERGE_TEMPLATE ?= 1
	@echo "Docker Project Template will be pulled"
	$(GIT) remote add template $(DOCKER_TEMPLATE)
endif

repos/template/python:
ifneq(,$(wildcard .github/.python))
MERGE_TEMPLATE ?= 1
	@echo "Python Project Template will be pulled"
	$(GIT) remote add template $(PYTHON_TEMPLATE)
endif

#repos/template/java repos/template/docker repos/template/node repos/template/python

## Upgrade Repository from Templates
repos/upgrade: packages/install/gh
ifeq(1,$(MERGE_TEMPLATE))
	@echo "Upgrading repository, current Version: $(shell cat .github/_VERSION)"
	@echo "Setting default repository: $(GIT_ORG)/$(GIT_REPO)"
	@$(GH) repo set-default $(GIT_ORG)/$(GIT_REPO)
	@echo "Fetching template repository"
	@$(GIT) fetch template master
	@$(GIT) checkout template/master -- .github/workflows Makefile .github/_VERSION
	@echo "Copying workflows from version: $(shell cat .github/_VERSION)"
	@find .github/workflows/.template -type f -name '*.yml' -print -exec sed -i 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
	@find .github/workflows/.template -type f -name '*.yaml' -print -exec sed -i 's|{{REPO_OWNER}}/base-app-template|$(GIT_ORG)/base-app-template|g' {} \;
	@cp .github/workflows/.template/*.yml .github/workflows
	@cp .github/workflows/.template/*.yaml .github/workflows
	@echo "Removing Initial.yml script, only needed upon creation."
	@rm -f .github/workflows/initial.yml
	@echo "Committing changes"
	@$(GIT) add .github/workflows Makefile
	@$(GIT) commit -m "chore: Upgrade repository from template, version: $(shell cat .github/_VERSION)"
	@echo "Repository upgraded to version: $(shell cat .github/_VERSION)"
	@echo "Please review changes and push to remote repository"
else
	@echo "No templates supported to upgrade by this script, skipping upgrade"
endif