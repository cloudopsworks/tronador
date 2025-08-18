AWS := $(shell which aws)
AWS_VAULT :=  $(shell which aws-vault)
SPOKE_NUM ?= "001"
SSH_AGENT_FILE := /tmp/bastion_ssh_agent

tronador_devops.mk:: Makefile
	echo "No .tronador_devops.mk file found, creating with default values..."
	echo "REGION=$(REGION)" > $@
	echo "PROFILE=$(PROFILE)" >> $@
	echo "Created .tronador_devops.mk with REGION=$(REGION) and PROFILE=$(PROFILE)"

-include tronador_devops.mk

REGION ?= "us-east-1"
PROFILE ?= "devops"

## Does login to AWS SSO and sets up the environment for DevOps tasks
devops/aws/login/sso:
	$(call assert-set,AWS)
	@echo "Logging in to AWS SSO..."
	@$(AWS) sso login --profile $(PROFILE)


# Loads default AWS REGION and PROFILE from $HOME/.tronador_devops or environment variables
devops/aws/load-defaults: #tronador_devops.mk
# Load default AWS REGION and PROFILE from $HOME/.tronador_devops or environment variables, if $HOME/.tronador_devops does not exist, create and save defaults
# this is done at makefile load time so that the variables are available for other targets
	@echo "Loading AWS defaults..."
	echo "$(REGION) $(PROFILE)"


# Check if the bastion host instance is running and registered with SSM before starting a session
devops/aws/bastion/ssm/check:
	$(call assert-set,AWS)
	$(call assert-set,AWS_VAULT)
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
# Before starting the session, ensure that the instance ID is available and ssm agent was able to register with SSM
	@echo "Checking if the bastion host instance is registered with SSM..."
# Retry at least 3 times with 20 sec interval to ensure the SSM agent has registered
# Retry at least 3 times with 20 sec interval to ensure the SSM agent has registered
	@for i in 1 2 3; do \
		STATUS=$$($(AWS_VAULT) exec $(PROFILE) -- $(AWS) ssm describe-instance-information --filters "Key=InstanceIds,Values=$$(cat $(TEMP_FILE))" --region $(REGION) --query "InstanceInformationList[0].PingStatus" --output text); \
		if [ "$$STATUS" = "Online" ]; then \
			break; \
		fi; \
		echo "SSM agent not registered yet, retrying in 20 seconds... (attempt $$i)"; \
		sleep 20; \
	done; \
	if [ "$$STATUS" != "Online" ]; then \
		echo "Bastion host instance is not registered with SSM, please ensure the SSM agent is running on the instance."; \
		exit 1; \
	fi


## Starts an SSM Session Manager session to the bastion host in the specified spoke number
devops/aws/bastion/ssm: devops/aws/load-defaults devops/aws/bastion/ssm/check
	$(call assert-set,AWS)
	$(call assert-set,AWS_VAULT)
# If the instance is registered, start the SSM session
	@echo "Starting SSM session to the bastion host..."
	@$(AWS_VAULT) exec $(PROFILE) -- $(AWS) ssm start-session --target $$(cat $(TEMP_FILE)) --region $(REGION)
# Clean up the temporary file
	@rm -f $(TEMP_FILE)


## Starts an SSM Session Manager port forwarding session to the bastion host in the specified spoke number, parameters are specified by <src port>:<dest port>
devops/aws/bastion/ssm-port-forward/%: devops/aws/load-defaults devops/aws/bastion/ssm/check
	$(call assert-set,AWS)
	$(call assert-set,AWS_VAULT)
# Retrieve the source and destination ports from the target parameters $@
	$(eval SRC_DEST ?= $(subst /, ,$(subst devops/aws/bastion/ssm-port-forward/,,$@)))
	$(eval SRC_PORT := $(word 1,$(SRC_DEST)))
	$(eval DEST_PORT := $(word 2,$(SRC_DEST)))
	@echo "Starting SSM port forwarding session to the bastion host... from: $(SRC_PORT) to: $(DEST_PORT)"
	@$(AWS_VAULT) exec $(PROFILE) -- $(AWS) ssm start-session --target $$(cat $(TEMP_FILE)) --document-name AWS-StartPortForwardingSession --parameters '{"portNumber":["$(DEST_PORT)"],"localPortNumber":["$(SRC_PORT)"]}' --region $(REGION) || echo "... Command failed or interrupted, exiting."
# Clean up the temporary file
	@rm -f $(TEMP_FILE)

## Starts an SSH Direct port forwarding session to the bastion host in the specified spoke number, parameters are specified by <src port>:<destination address>:<dest port>
devops/aws/bastion/ssh-port-forward/%: devops/aws/load-defaults devops/aws/bastion/ssm/check
	$(call assert-set,AWS)
	$(call assert-set,AWS_VAULT)
# Retrieve instance's public IP address from EC2 instance metadata instance id is defiende in $(TEMP_FILE)
	@echo "Retrieving bastion host public IP address..."
	$(eval BASTION_IP := $(shell $(AWS_VAULT) exec $(PROFILE) -- $(AWS) ec2 describe-instances --instance-ids $$(cat $(TEMP_FILE)) --region $(REGION) --query "Reservations[0].Instances[0].PublicIpAddress" --output text))
	@echo "Bastion host public IP address: $(BASTION_IP)"
# Retrieve the key name from ssm parameter store
	@echo "Retrieving bastion host key name from SSM..."
	$(eval KEY_NAME := $(shell $(AWS_VAULT) exec $(PROFILE) -- $(AWS) ssm get-parameter --name /cloudopsworks/tronador/bastion/$(SPOKE_NUM)/key-secret-name --query "Parameter.Value" --region $(REGION) --output text))
# Start SSH agent to manage keys and validate is not already running
	@echo "Starting SSH agent..."
	@if [ ! -f $(SSH_AGENT_FILE) ]; then \
		ssh-agent -s > $(SSH_AGENT_FILE); \
	else \
		echo "SSH agent is already running."; \
	fi
	@bash -c "trap 'trap - SIGINT SIGTERM ERR; eval \`cat $(SSH_AGENT_FILE)\`; ssh-agent -k ; rm -f $(SSH_AGENT_FILE); rm -f $(TEMP_FILE); exit 1' SIGINT SIGTERM ERR; PROFILE=$(PROFILE) REGION=$(REGION) SSH_AGENT_FILE=$(SSH_AGENT_FILE) KEY_NAME=$(KEY_NAME) $(MAKE) devops/aws/bastion/ssh-keyadd"
# Retrieve the source and destination ports from the target
	$(eval SRC_DEST ?= $(subst /, ,$(subst devops/aws/bastion/ssh-port-forward/,,$@)))
	$(eval SRC_PORT := $(word 1,$(SRC_DEST)))
	$(eval DEST_ADDR := $(word 2,$(SRC_DEST)))
	$(eval DEST_PORT := $(word 3,$(SRC_DEST)))
# Retrieve from ssm parameter the instance-user value
	@echo "Retrieving bastion host instance user from SSM..."
	$(eval INSTANCE_USER := $(shell $(AWS_VAULT) exec $(PROFILE) -- $(AWS) ssm get-parameter --name /cloudopsworks/tronador/bastion/$(SPOKE_NUM)/instance-user --query "Parameter.Value" --region $(REGION) --output text ))
	@bash -c "trap 'trap - SIGINT SIGTERM ERR; eval \`cat $(SSH_AGENT_FILE)\`; ssh-agent -k ; rm -f $(SSH_AGENT_FILE); rm -f $(TEMP_FILE); exit 1' SIGINT SIGTERM ERR; SSH_AGENT_FILE=$(SSH_AGENT_FILE) SRC_PORT=$(SRC_PORT) DEST_ADDR=$(DEST_ADDR) DEST_PORT=$(DEST_PORT) INSTANCE_USER=$(INSTANCE_USER) BASTION_IP=$(BASTION_IP) $(MAKE) devops/aws/bastion/ssh-run"
# Clean up the temporary file
	@rm -f $(TEMP_FILE)

devops/aws/bastion/ssh-keyadd:
# Retrieve the contents of SecretsManager secret named by  $(KEYNAME)
	@echo "Retrieving bastion host key contents from SecretsManager..."
	@eval `cat $(SSH_AGENT_FILE)` ; \
 		$(AWS_VAULT) exec $(PROFILE) -- $(AWS) secretsmanager get-secret-value --secret-id $(KEY_NAME) --query "SecretString" --region $(REGION) --output text | ssh-add -

devops/aws/bastion/ssh-run:
	@echo "Starting SSH port forwarding session to the bastion host... from: $(SRC_PORT) address-to: $(DEST_ADDR) to: $(DEST_PORT)"
	@eval `cat $(SSH_AGENT_FILE)` ; \
		ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N -L $(SRC_PORT):$(DEST_ADDR):$(DEST_PORT) $(INSTANCE_USER)@$(BASTION_IP)

## Shuts down the bastion host instance in the specified spoke number (alternate name)
devops/aws/bastion/stop: devops/aws/bastion/shutdown

## Shuts down the bastion host instance in the specified spoke number
devops/aws/bastion/shutdown: devops/aws/load-defaults
	$(call assert-set,AWS)
	$(call assert-set,AWS_VAULT)
	$(eval TEMP_FILE := $(shell mktemp /tmp/bastion_instance_id.XXXXXX))
	@$(AWS_VAULT) exec $(PROFILE) -- $(AWS) ssm get-parameter --name /cloudopsworks/tronador/bastion/$(SPOKE_NUM)/instance-id --query "Parameter.Value" --region $(REGION) --output text > $(TEMP_FILE)
	@echo "Bastion host instance ID: $$(cat $(TEMP_FILE))"
# Check if the instance ID is in running state, if not, start the instance, wait and then proceed
	@echo "Checking if the bastion host instance is running..."
	@$(AWS_VAULT) exec $(PROFILE) -- $(AWS) ec2 describe-instance-status --instance-ids $$(cat $(TEMP_FILE)) --region $(REGION) --query "InstanceStatuses[0].InstanceState.Name" --output text | grep -q "None" || \
		( echo "Bastion host instance is running, stopping it..." && \
		  $(AWS_VAULT) exec $(PROFILE) -- $(AWS) ec2 stop-instances --instance-ids $$(cat $(TEMP_FILE)) --region $(REGION) && \
		  echo "Waiting for the bastion host instance to be totally stopped..." && \
		  $(AWS_VAULT) exec $(PROFILE) -- $(AWS) ec2 wait instance-stopped --instance-ids $$(cat $(TEMP_FILE)) --region $(REGION) && \
		  echo "Bastion host instance is now stopped." )
# Clean up the temporary file
	@rm -f $(TEMP_FILE)
