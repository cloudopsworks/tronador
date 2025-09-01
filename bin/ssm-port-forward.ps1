param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePort,

    [Parameter(Mandatory=$true)]
    [string]$DestinationAddress,

    [Parameter(Mandatory=$true)]
    [string]$DestinationPort,

    [string]$Region = "us-east-1",
    [string]$Profile = "devops",
    [string]$SpokeNum = "001",
    [string]$AwsVaultBackend = "wincred",
    [int]$LeaseHours = 4
)

# Function to check if a command exists
function Test-Command {
    param($CommandName)
    return Get-Command $CommandName -ErrorAction SilentlyContinue
}

# Validate required tools
if (-not (Test-Command "aws")) {
    Write-Error "AWS CLI is not installed or not in PATH"
    exit 1
}

if (-not (Test-Command "aws-vault")) {
    Write-Error "aws-vault is not installed or not in PATH"
    exit 1
}

Write-Host "Port forwarding configuration: $SourcePort -> $DestinationAddress`:$DestinationPort"

try {
    # Load defaults (equivalent to devops/aws/load-defaults)
    Write-Host "Loading AWS defaults..."
    Write-Host "$Region $Profile"

    # Obtain Request SQS URL (equivalent to devops/aws/bastion/authorize)
    Write-Host "Obtaining Request SQS URL..."
    $requestSqsUrl = & aws-vault --backend=$AwsVaultBackend exec $Profile -- aws ssm get-parameter --name "/cloudopsworks/tronador/access-automation/request-queue" --query "Parameter.Value" --region $Region --output text
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to retrieve Request SQS URL"
        exit 1
    }
    Write-Host "Request SQS URL: $requestSqsUrl"
    # Get current ip from https://checkip.amazonaws.com
    $myIp = (Invoke-RestMethod -Uri "https://checkip.amazonaws.com").Trim()
    # Send message to SQS with this format: "{\"action\":\"request_access\",\"ip_address\":\"$(MY_IP)\",\"service\":\"ssh\",\"lease_request\":$(LEASE_HOURS)}"
    $messageBody = @{
        action = "request_access"
        ip_address = "$myIp"
        service = "ssh"
        lease_request = $LeaseHours
    }
    $messageBodyJson1 = $messageBody | ConvertTo-Json -Compress
    $messageBodyJson = $messageBodyJson1.Replace('"', '\"')
    Write-Host "Sending access request to SQS... $messageBodyJson"
    & aws-vault --backend=$AwsVaultBackend exec $Profile -- aws sqs send-message --queue-url $requestSqsUrl --region $Region --message-body $messageBodyJson
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to send message to SQS"
        exit 1
    }
    Write-Host "Access request sent."

    # Bastion SSM check (equivalent to devops/aws/bastion/ssm/check)
    Write-Host "Retrieving bastion host instance ID from SSM..."

    $bastionId = & aws-vault --backend=$AwsVaultBackend exec $Profile -- aws ssm get-parameter --name "/cloudopsworks/tronador/bastion/$SpokeNum/instance-id" --query "Parameter.Value" --region $Region --output text
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to retrieve bastion instance ID"
        exit 1
    }
    Write-Host "Bastion host instance ID: $bastionId"

    # Check if instance is running
    Write-Host "Checking if the bastion host instance is running..."
    $instanceState = & aws-vault --backend=$AwsVaultBackend exec $Profile -- aws ec2 describe-instance-status --instance-ids $bastionId --region $Region --query "InstanceStatuses[0].InstanceState.Name" --output text

    if ($instanceState -ne "running") {
        Write-Host "Waiting for the bastion host instance to be running..."
        & aws-vault --backend=$AwsVaultBackend exec $Profile -- aws ec2 wait instance-running --instance-ids $bastionId --region $Region
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to wait for instance to be running"
            exit 1
        }
        Write-Host "Bastion host instance is now running."
    }

    # Check SSM agent registration
    Write-Host "Checking if the bastion host instance is registered with SSM..."
    $maxRetries = 3
    $retryDelay = 20
    $ssmRegistered = $false

    for ($i = 1; $i -le $maxRetries; $i++) {
        $pingStatus = & aws-vault --backend=$AwsVaultBackend exec $Profile -- aws ssm describe-instance-information --filters "Key=InstanceIds,Values=$bastionId" --region $Region --query "InstanceInformationList[0].PingStatus" --output text

        if ($pingStatus -eq "Online") {
            $ssmRegistered = $true
            break
        }

        Write-Host "SSM agent not registered yet, retrying in $retryDelay seconds... (attempt $i)"
        Start-Sleep -Seconds $retryDelay
    }

    if (-not $ssmRegistered) {
        Write-Error "Bastion host instance is not registered with SSM, please ensure the SSM agent is running on the instance."
        exit 1
    }

    # Start SSM port forwarding session
    Write-Host "Starting SSM port forwarding session to the bastion host... from: $SourcePort to: $DestinationPort"

    $parameters = @{
        host = @($DestinationAddress)
        portNumber = @($DestinationPort)
        localPortNumber = @($SourcePort)
    }

    $parametersJson = $parameters | ConvertTo-Json -Compress

    & aws-vault --backend=$AwsVaultBackend exec $Profile -- aws ssm start-session --target $bastionId --document-name "AWS-StartPortForwardingSessionToRemoteHost" --parameters $parametersJson --region $Region

    if ($LASTEXITCODE -ne 0) {
        Write-Host "... Command failed or interrupted, exiting."
    }

} catch {
    Write-Error "An error occurred: $_"
    exit 1
} finally {
    # Cleanup would go here if needed (equivalent to rm -f $(TEMP_FILE))
    # No temporary files are created in this PowerShell version
}
