AWS := $(shell which aws)
AWS_VAULT :=  $(shell which aws-vault)
SPOKE_NUM ?= "001"
REGION ?= "us-east-1"
PROFILE ?= "devops"

## Does login to AWS SSO and sets up the environment for DevOps tasks
devops/aws/login/sso:
	@echo "Logging in to AWS SSO..."
	@$(AWS) sso login --profile $(PROFILE)

# Loads default AWS REGION and PROFILE from $HOME/.tronador_devops or environment variables
devops/aws/load-defaults:
	# Load default AWS REGION and PROFILE from $HOME/.tronador_devops or environment variables, if $HOME/.tronador_devops does not exist, create and save defaults
	# this is done at makefile load time so that the variables are available for other targets
	@echo "Loading AWS defaults..."
	@if [ -f $(HOME)/.tronador_devops ]; then \
		echo "Found existing .tronador_devops file, loading defaults..."; \
	else \
		echo "No .tronador_devops file found, creating with default values..."; \
		echo "export REGION=$(REGION)" > $(HOME)/.tronador_devops; \
		echo "export PROFILE=$(PROFILE)" >> $(HOME)/.tronador_devops; \
		echo "Created $(HOME)/.tronador_devops with REGION=$(REGION) and PROFILE=$(PROFILE)"; \
	fi
	@. $(HOME)/.tronador_devops

## Starts an SSM Session Manager session to the bastion host in the specified spoke number
devops/aws/bastion/ssm: devops/aws/load-defaults
	# Retrieve the instance ID of the bastion host from ssm parameter store
	@echo "Retrieving bastion host instance ID from SSM..."
	# Generate temp file to store the instance ID
	$(eval TEMP_FILE := $(shell mktemp /tmp/bastion_instance_id.XXXXXX))
	@$(AWS_VAULT) exec $(PROFILE) -- $(AWS) ssm get-parameter --name /cloudopsworks/tronador/bastion/$(SPOKE_NUM)/instance-id --query "Parameter.Value" --region $(REGION) --output text > $(TEMP_FILE)
	@echo "Bastion host instance ID: $$(cat $(TEMP_FILE))"
	# Check if the instance ID is in running state, if not, start the instance, wait and then proceed
	@echo "Checking if the bastion host instance is running..."
	@$(AWS_VAULT) exec $(PROFILE) -- $(AWS) ec2 describe-instance-status --instance-ids $$(cat $(TEMP_FILE)) --region $(REGION) --query "InstanceStatuses[0].InstanceState.Name" --output text | grep -q "running" || \
		( echo "Bastion host instance is not running, starting it..." && \
		  $(AWS_VAULT) exec $(PROFILE) -- $(AWS) ec2 start-instances --instance-ids $$(cat $(TEMP_FILE)) --region $(REGION) && \
		  echo "Waiting for the bastion host instance to be running..." && \
		  $(AWS_VAULT) exec $(PROFILE) -- $(AWS) ec2 wait instance-running --instance-ids $$(cat $(TEMP_FILE)) --region $(REGION) && \
		  echo "Bastion host instance is now running." )
	# Start SSM session to the bastion host
	@echo "Starting SSM session to the bastion host..."
	@$(AWS_VAULT) exec $(PROFILE) -- $(AWS) ssm start-session --target $$(cat $(TEMP_FILE)) --region $(REGION)
