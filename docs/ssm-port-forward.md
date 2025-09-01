# SSM Port Forward Script (Windows)

This document explains how to install prerequisites on Windows using Chocolatey, clone this repository, and use the PowerShell script `bin/ssm-port-forward.ps1` to start an AWS Systems Manager (SSM) port forwarding session to a bastion host.

The script automates:
- Requesting access via SQS to whitelist your public IP for a lease period
- Discovering the bastion instance ID from SSM Parameter Store
- Verifying the instance is running and registered with SSM
- Starting an SSM port forwarding session to a remote host behind the bastion

Repository: https://github.com/cloudopsworks/tronador


## Prerequisites on Windows (Chocolatey)

The steps below assume you are using PowerShell with Administrator rights.

1) Install Chocolatey (if not already installed)
- Open PowerShell as Administrator and run:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; \
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
iwr https://community.chocolatey.org/install.ps1 -UseBasicParsing | iex
```

2) Install required tools with Chocolatey
- Still in an elevated PowerShell window, run:

```
choco install -y git awscli aws-vault session-manager-plugin
```

Notes:
- `git` is installed in case it is not already present.
- `awscli` provides the `aws` command.
- `aws-vault` is used to securely execute AWS commands with your profile credentials.
- `session-manager-plugin` is required by `aws ssm start-session` to function on Windows.

3) Close and reopen PowerShell so the new PATH settings apply.


## Clone the repository

Use Git to clone the repository and navigate to it:

```
cd $HOME
git clone https://github.com/cloudopsworks/tronador.git
cd tronador
```

The script is located at `bin/ssm-port-forward.ps1`.


## Configure aws-vault and AWS profile (SSO)

Use AWS IAM Identity Center (formerly AWS SSO) with the AWS CLI v2. This avoids storing long‑lived access keys and works seamlessly with aws-vault.

1) Create an SSO-backed AWS CLI profile named `devops`:

```
aws configure sso --profile devops
```

Follow the prompts in your browser and CLI:
- SSO Start URL (e.g., https://your-company.awsapps.com/start)
- SSO Region (e.g., us-east-1)
- Select the AWS account and role
- Default CLI region (e.g., us-east-1)
- Default output format (e.g., json)

This writes configuration to `%USERPROFILE%\.aws\config`.

2) (Optional) Verify your `%USERPROFILE%\.aws\config` contains entries similar to:

```
[profile devops]
sso_session = my-sso
sso_account_id = 123456789012
sso_role_name = AdministratorAccess
region = us-east-1
output = json

[sso-session my-sso]
sso_start_url = https://your-company.awsapps.com/start
sso_region = us-east-1
sso_registration_scopes = sso:account:access
```

3) Sign in and verify the profile with aws-vault. No `aws-vault add` step is required for SSO profiles:

```
aws-vault --backend=wincred exec devops -- aws sts get-caller-identity
```

If you are not signed in yet, this will prompt a browser-based SSO login and then execute the command.


## Allow script execution (if needed)

If your system prevents running local scripts, you can allow them for the current user:

```
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

If you downloaded this repo from the internet, you may need to unblock the script once:

```
Unblock-File -Path .\bin\ssm-port-forward.ps1
```


## Script parameters and defaults

The script accepts the following parameters (with defaults where applicable):

- `-SourcePort` (string, required): Local port to open on your machine.
- `-DestinationAddress` (string, required): Remote host address reachable from the bastion.
- `-DestinationPort` (string, required): Remote host port.
- `-Region` (string, default: `us-east-1`)
- `-Profile` (string, default: `devops`)
- `-SpokeNum` (string, default: `001`)
- `-AwsVaultBackend` (string, default: `wincred`)
- `-LeaseHours` (int, default: `4`)

The script will:
- Read the request SQS URL from `/cloudopsworks/tronador/access-automation/request-queue` in SSM Parameter Store
- Send a JSON message to that SQS queue to request access for your public IP for the number of hours specified by `-LeaseHours`
- Read the bastion instance ID from `/cloudopsworks/tronador/bastion/<SpokeNum>/instance-id`
- Ensure the instance is running and registered with SSM
- Start port forwarding via the `AWS-StartPortForwardingSessionToRemoteHost` document


## Usage examples

Run from the repository root in a normal PowerShell window (not admin required for running):

- Forward local port 5439 to a remote database on 10.0.1.25:5439 via the bastion, using defaults:

```
.\bin\ssm-port-forward.ps1 -SourcePort 5439 -DestinationAddress 10.0.1.25 -DestinationPort 5439
```

- Specify a different profile and region:

```
.\bin\ssm-port-forward.ps1 -SourcePort 8080 -DestinationAddress 10.10.0.50 -DestinationPort 80 -Profile myprofile -Region us-west-2
```

- Use a different spoke number and a shorter lease:

```
.\bin\ssm-port-forward.ps1 -SourcePort 1521 -DestinationAddress 10.0.2.10 -DestinationPort 1521 -SpokeNum 002 -LeaseHours 1
```


## Troubleshooting

- Command not found: Ensure `aws`, `aws-vault`, and `session-manager-plugin` are in your PATH. Reopen PowerShell after installing with Chocolatey.
- Access denied / authorization issues: Verify your IP was authorized (SQS request succeeds) and your IAM permissions allow SSM/EC2 describe and SSM start-session.
- SSM plugin error: Confirm `session-manager-plugin` is installed (`choco list --local-only | Select-String session-manager-plugin`).
- Profile problems: Confirm your profile exists and works: `aws-vault --backend=wincred exec devops -- aws sts get-caller-identity`.
- Execution policy: Use `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` and `Unblock-File` as shown above if the script won’t run.


## Uninstalling the tools (optional)

If needed, you can remove the packages installed with Chocolatey:

```
choco uninstall -y awscli aws-vault session-manager-plugin git
```
