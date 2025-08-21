# DevOps Makefile: Comprehensive Usage Guide

This guide documents all targets in devops/* targets and explains how to prepare your workstation, including installing AWS CLI v2 and aws-vault on macOS, Windows, and common Linux distributions.

### Contents
- [Prerequisites and concepts](#prerequisites-and-concepts)
- [Installing AWS CLI v2](#installing-aws-cli-v2)
  - [macOS](#macos) 
  - [Windows](#windows)
  - [Linux (Ubuntu/Debian), (RHEL/CentOS/Fedora), (Arch)](#linux)
- [Installing aws-vault](#installing-aws-vault)
  - macOS
  - Windows
  - Linux (Ubuntu/Debian), (RHEL/CentOS/Fedora), (Arch)
- [Quick start](#quick-start)
- [Targets reference](#targets-reference)
  - devops/aws/login/sso
  - devops/aws/bastion/ssm
  - devops/aws/bastion/ssm-port-forward/<src:dest>
  - devops/aws/bastion/ssh-port-forward/<src:destAddr:destPort>
  - devops/aws/bastion/stop
  - devops/aws/bastion/shutdown
- [Environment variables and defaults](#environment-variables-and-defaults)
- [Security notes](#security-notes)
- [Troubleshooting](#troubleshooting)


### Prerequisites and concepts
- Where to run:
  This is part of the DevOps Accelerator and is intended to be run from a project or folder where the Makefile that includes the DevOps Accelerator is located.
  Projects, which include the DevOps Accelerator, are those based on the following:
  - https://github.com/cloudopsworks/terragrunt-project-template.git
  - https://github.com/cloudopsworks/java-app-template.git
  - https://github.com/cloudopsworks/python-app-template.git
  - https://github.com/cloudopsworks/node-app-template.git
- AWS account with SSO enabled and an SSO profile configured in ~/.aws/config, e.g.:
  [profile devops]
  sso_start_url = https://your-sso-portal.awsapps.com/start
  sso_region = us-east-1
  sso_account_id = 123456789012
  sso_role_name = AWSAdministratorAccess
  region = us-east-1
- Tools required by the Makefile:
  - aws (AWS CLI v2)
  - aws-vault
  - ssh and ssh-agent (for SSH port-forwarding target)
- SSM parameters used by these targets (must exist in the target account/region):
  - /cloudopsworks/tronador/bastion/<SPOKE_NUM>/instance-id
  - /cloudopsworks/tronador/bastion/<SPOKE_NUM>/key-secret-name (Secret in Secrets Manager containing private key PEM)
  - /cloudopsworks/tronador/bastion/<SPOKE_NUM>/instance-user (e.g., ec2-user, ubuntu)


### Installing AWS CLI v2
#### macOS
- Homebrew (recommended):
  brew update
  brew install awscli
- Direct installer (alternative): download the .pkg from https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html and install.
- Verify: aws --version

#### Windows
- Winget (recommended on Windows 10/11):
  winget install --id Amazon.AWSCLI -e
- Chocolatey (alternative):
  choco install awscli -y
- MSI installer: download from AWS docs and install.
- Verify: aws --version

#### Linux
##### Ubuntu/Debian
- Official AWS ZIP install:
  sudo apt-get update
  sudo apt-get install -y unzip curl
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  cd /tmp && unzip -q awscliv2.zip
  sudo ./aws/install
- Verify: aws --version

##### RHEL/CentOS/Fedora
- Using official ZIP:
  sudo dnf -y install unzip curl || sudo yum -y install unzip curl
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
  cd /tmp && unzip -q awscliv2.zip
  sudo ./aws/install
- Verify: aws --version

##### Arch Linux
- Community package:
  sudo pacman -Syu aws-cli
- Verify: aws --version

#### Notes
- For ARM systems, replace x86_64 with aarch64 in the download URL.
- If upgrading, you may need: sudo ./aws/install --update


### Installing aws-vault
#### macOS
- Homebrew:
  brew install aws-vault
- Verify: aws-vault --version

#### Windows
- Scoop (recommended):
    ```powershell
      scoop install aws-vault
    ```
- Chocolatey (alternative):
    ```powershell
    choco install aws-vault -y
    ```
- Manual: download the latest release from https://github.com/99designs/aws-vault/releases, place aws-vault.exe in a directory on PATH.
- Verify: `aws-vault --version`

#### Linux
##### Ubuntu/Debian
- From release tarball:
    ```shell
    sudo apt-get update && sudo apt-get install -y curl
    curl -L https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64 -o /tmp/aws-vault
    sudo install -m 0755 /tmp/aws-vault /usr/local/bin/aws-vault
    ```
- Verify: `aws-vault --version`

##### RHEL/CentOS/Fedora
- From release tarball:
    ```shell
    curl -L https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64 -o /tmp/aws-vault
    sudo install -m 0755 /tmp/aws-vault /usr/local/bin/aws-vault
    ```
- Verify: `aws-vault --version`

##### Arch Linux
- AUR (using yay):
    ```shell
    yay -S aws-vault
    ```
- Verify: `aws-vault --version`

#### Notes
- For ARM, download aws-vault-linux-arm64 instead.
- On Linux desktops, consider configuring a keyring (gnome-keyring, kwallet). aws-vault can also use file-based store: aws-vault --help | grep backends


### Quick start
1) Ensure `aws` and `aws-vault` are installed and on PATH.
2) Ensure your AWS SSO profile exists in ~/.aws/config (e.g., profile devops).
3) Optionally set SPOKE_NUM, REGION, PROFILE when invoking make; otherwise defaults are used or loaded via ./.tronador_devops.mk.
4) Log in with SSO: make PROFILE=devops devops/aws/login/sso
5) Start an SSM session to the bastion in a spoke: make SPOKE_NUM=001 REGION=us-east-1 PROFILE=devops devops/aws/bastion/ssm


### Targets reference
#### General conventions
- Most targets require both aws and aws-vault to be available.
- REGION and PROFILE can be set via environment, the ./.tronador_devops.mk file, or Makefile defaults (REGION=us-east-1, PROFILE=devops). Precedence: environment/CLI variables > ./.tronador_devops.mk > defaults.
- SPOKE_NUM selects which spoke’s parameters to use (default "001"), it is important and is used to retrieve secrets and bastion information.

1) `devops/aws/login/sso`
   - Purpose: Interactive AWS SSO login for a profile.
   - Inputs: 
     - `PROFILE` (default **devops**)
     - `REGION` (default **us-east-1**)
     - `SPOKE_NUM` (default **001**)
   - Example:
       ```shell
       make REGION=us-east-2 PROFILE=devops devops/aws/login/sso
       ```
   - Expected: Browser prompts to authenticate. On success, cached SSO credentials are stored for the profile.


2) `devops/aws/bastion/ssm`
   - Purpose: Open an SSM Session Manager shell into the bastion.
   - Example:
        ```shell
        make PROFILE=devops devops/aws/bastion/ssm
        ```

3) `devops/aws/bastion/ssm-port-forward/<src:dest>`
   - Purpose: Open an SSM Port Forwarding session via Session Manager.
   - Syntax: `devops/aws/bastion/ssm-port-forward/LOCAL_PORT:REMOTE_PORT`
   - Example: Forward local 5432 to bastion’s 5432
      ```shell
      make SPOKE_NUM=001 devops/aws/bastion/ssm-port-forward/5432:5432
      ```
   - Notes: Uses document AWS-StartPortForwardingSession. Close with Ctrl+C.

4) `devops/aws/bastion/ssh-port-forward/<src:destAddr:destPort>`
   - Purpose: Open a classic SSH local port forward through the bastion’s public IP, using a private key retrieved from Secrets Manager.
   - Steps:
     - Retrieves bastion PublicIpAddress from EC2.
     - Reads key secret name from SSM: /cloudopsworks/tronador/bastion/$(SPOKE_NUM)/key-secret-name and fetches SecretString, then pipes to ssh-add (via a transient ssh-agent started by the target).
     - Reads instance-user from SSM: /cloudopsworks/tronador/bastion/$(SPOKE_NUM)/instance-user.
     - Runs: ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -N -L SRC:DEST_ADDR:DEST_PORT INSTANCE_USER@BASTION_IP
     - On interrupt or error, traps to stop ssh-agent and cleanup temp files.
   - Syntax: `devops/aws/bastion/ssh-port-forward/LOCAL_PORT:DESTINATION_ADDRESS:DESTINATION_PORT`
   - Examples:
     - Forward local 22 to a private host through bastion:
        ```shell
        make SPOKE_NUM=001 devops/aws/bastion/ssh-port-forward/2222:10.0.1.10:22
        ```
     - Forward local 443 to an internal ALB:
        ```shell
        make SPOKE_NUM=002 devops/aws/bastion/ssh-port-forward/8443:internal-alb.local:443
        ```
   - Notes: Ensure your IP can reach BASTION_IP (security group rules). The private key in Secrets Manager must be in PEM format acceptable by ssh-add.

5) `devops/aws/bastion/stop`
   - Purpose: Alias for devops/aws/bastion/shutdown.
   - Example:
      ```shell
      make SPOKE_NUM=001 devops/aws/bastion/stop
      ```

6) `devops/aws/bastion/shutdown`
   - Purpose: Stop the bastion EC2 instance for a given SPOKE_NUM.
   - Steps:
     - Reads instance-id from SSM Parameter Store.
     - If the instance is running, stops it and waits until fully stopped.
   - Example:
     ```shell
     make SPOKE_NUM=001 devops/aws/bastion/shutdown
     ```

#### Environment variables and defaults
- SPOKE_NUM: selects the target spoke, default "001".
- REGION: AWS region used for SSM/EC2/Secrets Manager calls; default "us-east-1".
- PROFILE: aws-vault profile and AWS CLI profile; default "devops".
- .tronador_devops.mk: a shell file containing export REGION=... and export PROFILE=... auto-created if missing. Sourced during make execution to populate variables.

#### Security notes
- aws-vault stores credentials securely (macOS Keychain, Windows Credential Manager, Linux keyrings); prefer it over plain profiles.
- Private key material is pulled from AWS Secrets Manager into ssh-agent only for the session; on exit, the agent is terminated and the env file removed.
- StrictHostKeyChecking is disabled for convenience in ssh-run; for stricter security, pre-populate known_hosts and adjust the Makefile or your SSH config.

#### Troubleshooting
- which aws or which aws-vault fails (assert-set): Ensure they are installed and on PATH; see installation sections.
- SSO login keeps opening the browser: Close any stale sessions, run aws sso logout, then try again. Ensure PROFILE points to an SSO profile in ~/.aws/config.
- Parameter not found: Confirm SPOKE_NUM/REGION/PROFILE, IAM permissions for ssm:GetParameter, and that parameters exist at the expected paths.
- Instance never becomes running: Check quotas, instance state, and permissions for ec2:StartInstances; verify the instance ID parameter is correct.
- SSM PingStatus not Online: Verify SSM Agent on the instance, instance role permissions for SSM, VPC endpoints/egress to reach SSM, and that the instance is in the correct REGION.
- SSH port forwarding fails: Ensure your workstation can reach the bastion’s public IP (corporate firewall/SG rules), that the key matches the bastion’s authorized_keys, and that the instance-user is correct.
- Port already in use: Choose a different LOCAL_PORT.
- Cleanup issues: If a session was interrupted, you may need to manually kill ssh-agent and remove /tmp/bastion_ssh_agent.

### Appendix: Examples
- Use a different region and profile for a one-off command:
    ```shell
    make REGION=eu-west-1 PROFILE=devops-eu SPOKE_NUM=003 devops/aws/bastion/ssm
    ```
  
- Forward PostgreSQL from a private RDS through bastion:
    ```shell
      make devops/aws/bastion/ssm-port-forward/15432:5432
      psql -h 127.0.0.1 -p 15432 -U user dbname
    ```
- Stop a bastion when done:
    ```shell
    make devops/aws/bastion/shutdown
    ```
  
