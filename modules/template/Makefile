export GOMPLATE ?= $(TRONADOR_PATH)/vendor/gomplate

## Install dependencies
template/deps: packages/install/gomplate

## Create $OUT file by building it from $IN template file
template/build: template/deps
	@$(TRONADOR_PATH)/bin/template_generate.sh
