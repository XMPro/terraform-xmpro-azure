# Script to get the public IP address of the machine running Terraform
# This is used to create a firewall rule to allow access to the SQL server
try {
    # Force TLS 1.2 for older PowerShell hosts
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Use ipify.org API to get the public IP
    $publicIP = (Invoke-WebRequest -Uri 'https://api.ipify.org' -UseBasicParsing -TimeoutSec 10).Content

    # Output the result in JSON format for Terraform external data source
    Write-Output "{`"public_ip`":`"$publicIP`"}"
} catch {
    Write-Error "Failed to fetch public IP: $_"
    exit 1
}