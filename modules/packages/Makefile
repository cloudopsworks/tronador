export INSTALL_PATH ?= $(TRONADOR_PATH)/vendor
export PACKAGES_VERSION ?= master
export PACKAGES_PATH ?= $(TRONADOR_PATH)/vendor/packages

# If customer defined their own packages versions then will come defined from upper
ifndef CUSTOMER_PACKAGES_OWNER
export CUSTOMER_PACKAGES_OWNER ?= cloudopsworks
export CUSTOMER_PACKAGES_REPO ?= tronador-packages
endif

## Delete packages
packages/delete:
	rm -rf $(PACKAGES_PATH)

## Reinstall packages
packages/reinstall: packages/delete packages/install
	@exit 0

## Install packages 
packages/install:
	@if [ ! -d $(PACKAGES_PATH) ]; then \
	  echo "Installing packages $(PACKAGES_VERSION)..." >&2; \
	  rm -rf $(PACKAGES_PATH); \
	  $(GIT) clone -q -c advice.detachedHead=false --depth=1 -b $(PACKAGES_VERSION) https://github.com/$(CUSTOMER_PACKAGES_OWNER)/$(CUSTOMER_PACKAGES_REPO).git $(PACKAGES_PATH) 2>/dev/nul; \
	  rm -rf $(PACKAGES_PATH)/.git; \
	fi 

## Install package (e.g. helm, helmfile, kubectl)
packages/install/%: packages/install
	@if [ ! -x $(INSTALL_PATH)/$(subst packages/install/,,$@) ]; then \
		$(MAKE) -C $(PACKAGES_PATH)/install $(subst packages/install/,,$@); \
	else \
		echo "Package $(subst packages/install/,,$@) already installed" >&2; \
	fi;

## Reinstall package (e.g. helm, helmfile, kubectl)
packages/reinstall/%: packages/install
	@$(MAKE) -C $(PACKAGES_PATH)/install $(subst packages/reinstall/,,$@)

## Uninstall package (e.g. helm, helmfile, kubectl)
packages/uninstall/%: packages/install
	@$(MAKE) -C $(PACKAGES_PATH)/uninstall $(subst packages/uninstall/,,$@)
