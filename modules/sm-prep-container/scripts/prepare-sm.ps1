# XMPro SM Zip Preparation Script - PowerShell Core Version
# Container script for preparing SM deployment packages using mcr.microsoft.com/powershell:latest
#
# This script downloads SM.zip from storage account, processes configuration files,
# and creates a deployment-ready zip package

# Environment variables
$SM_ZIP_DOWNLOAD_URL = $env:SM_ZIP_DOWNLOAD_URL
$RELEASE_VERSION = $env:RELEASE_VERSION
$AZURE_KEY_VAULT_NAME = $env:AZURE_KEY_VAULT_NAME
$DEPLOYMENT_TRIGGER = $env:DEPLOYMENT_TRIGGER
$SM_ZIP_DOWNLOAD_URL = $env:SM_ZIP_DOWNLOAD_URL

# Path constants
$WORK_DIR = "/tmp/sm-work"
$EXTRACT_DIR = "$WORK_DIR/extract"
$SITE_DIR = "$EXTRACT_DIR/SM"
$OUTPUT_DIR = "/output"
$SCRIPTS_DIR = "/scripts"

# Logging function
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ"
    Write-Host "[$timestamp] $Level`: $Message"
}

# Error handling function
function Exit-WithError {
    param([string]$Message, [int]$ExitCode = 1)
    Write-Log $Message "ERROR"
    exit $ExitCode
}

# Validate required environment variables
function Test-EnvironmentVariables {
    Write-Log "Validating environment variables..."
    
    if (!$SM_ZIP_DOWNLOAD_URL) {
        Exit-WithError "SM_ZIP_DOWNLOAD_URL environment variable is required"
    }
    if (!$RELEASE_VERSION) {
        Exit-WithError "RELEASE_VERSION environment variable is required"
    }
    if (!$AZURE_KEY_VAULT_NAME) {
        Write-Log "AZURE_KEY_VAULT_NAME not provided - Azure Key Vault integration will be disabled" "WARN"
    }
    
    Write-Log "Environment variables validated successfully"
    Write-Log "SM.zip Download URL: $SM_ZIP_DOWNLOAD_URL"
    Write-Log "Version: $RELEASE_VERSION"
    Write-Log "Key Vault: $AZURE_KEY_VAULT_NAME"
    Write-Log "Deployment Trigger: $DEPLOYMENT_TRIGGER"
}

# Setup working directories
function Initialize-WorkDirectories {
    Write-Log "Setting up working directories..."
    
    # Create working directories
    if (Test-Path $WORK_DIR) {
        Remove-Item $WORK_DIR -Recurse -Force
    }
    New-Item -ItemType Directory -Path $WORK_DIR -Force | Out-Null
    New-Item -ItemType Directory -Path $EXTRACT_DIR -Force | Out-Null
    
    # Ensure output directory exists
    if (!(Test-Path $OUTPUT_DIR)) {
        New-Item -ItemType Directory -Path $OUTPUT_DIR -Force | Out-Null
    }
    
    Write-Log "Working directories created:"
    Write-Log "  Work Dir: $WORK_DIR"
    Write-Log "  Extract Dir: $EXTRACT_DIR"
    Write-Log "  Site Dir: $SITE_DIR"
    Write-Log "  Output Dir: $OUTPUT_DIR"
}

# Install required PowerShell modules and tools
function Install-Requirements {
    Write-Log "Installing required tools and modules..."
    
    # Install curl and unzip using Ubuntu package manager
    & apt-get update -y
    if ($LASTEXITCODE -ne 0) {
        Exit-WithError "Failed to update package lists"
    }
    
    & apt-get install -y curl unzip zip
    if ($LASTEXITCODE -ne 0) {
        Exit-WithError "Failed to install required packages"
    }
    
    Write-Log "Required tools installed successfully"
}

# Download SM.zip directly from storage account
function Get-SmZipDirect {
    Write-Log "Downloading SM.zip from storage account..."
    
    $smZipFile = "$WORK_DIR/SM.zip"
    
    Write-Log "SM.zip URL: $SM_ZIP_DOWNLOAD_URL"
    Write-Log "Downloading to: $smZipFile"
    
    # Download SM.zip directly
    & curl -L -o $smZipFile $SM_ZIP_DOWNLOAD_URL
    if ($LASTEXITCODE -ne 0) {
        Exit-WithError "Failed to download SM.zip from storage account. URL: $SM_ZIP_DOWNLOAD_URL"
    }
    
    if (!(Test-Path $smZipFile)) {
        Exit-WithError "Downloaded SM.zip file not found: $smZipFile"
    }
    
    $fileSize = (Get-Item $smZipFile).Length
    Write-Log "Downloaded SM.zip successfully ($fileSize bytes)"
    
    # Extract SM.zip directly to our working site directory
    Write-Log "Extracting SM.zip to site directory..."
    New-Item -ItemType Directory -Path $SITE_DIR -Force | Out-Null
    & unzip -q $smZipFile -d $SITE_DIR
    if ($LASTEXITCODE -ne 0) {
        Exit-WithError "Failed to extract SM.zip"
    }
    
    Write-Log "SM.zip extracted successfully to: $SITE_DIR"
}

# Process Web.config after extraction
function Initialize-WebConfig {
    
    # Look for Web.config.template and rename to Web.config
    $webConfigTemplatePath = "$SITE_DIR/Web.config.template"
    $webConfigPath = "$SITE_DIR/Web.config"
    
    if (Test-Path $webConfigTemplatePath) {
        Write-Log "Found Web.config.template, renaming to Web.config"
        Move-Item $webConfigTemplatePath $webConfigPath
        Write-Log "Web.config.template renamed to Web.config successfully"
    } elseif (Test-Path $webConfigPath) {
        Write-Log "Web.config already exists: $webConfigPath"
    } else {
        Exit-WithError "Neither Web.config nor Web.config.template found in SM source. Expected at: $webConfigPath or $webConfigTemplatePath"
    }
    
    Write-Log "Web.config ready for processing: $webConfigPath"
}


# Process configuration files using bundled Install.ps1 directly
function Invoke-ConfigProcessing {
    Write-Log "Processing configuration files..."
    
    # Set environment variables for Install.ps1 (SITE_PATH is required)
    $env:SITE_PATH = $SITE_DIR
    
    # Log Key Vault if configured
    if ($AZURE_KEY_VAULT_NAME) {
        Write-Log "Key Vault: $AZURE_KEY_VAULT_NAME"
    }
    
    # Path to bundled Install.ps1 script
    $installScriptPath = "$SITE_DIR/Install.ps1"
    
    if (!(Test-Path $installScriptPath)) {
        Exit-WithError "Install.ps1 not found at: $installScriptPath. Ensure SM.zip bundle was extracted properly."
    }
    
    Write-Log "Calling bundled Install.ps1 directly for config processing"
    Write-Log "Install script: $installScriptPath"
    Write-Log "Processing site: $SITE_DIR"
    
    # Execute the bundled Install.ps1 with only the ConfigFiles step
    # This leverages the linux-compatible, cross-platform improvements from work item 20580
    & pwsh -NoLogo -ExecutionPolicy RemoteSigned -File $installScriptPath -ConfigFiles
    
    if ($LASTEXITCODE -ne 0) {
        Exit-WithError "Install.ps1 -ConfigFiles failed (exit code: $LASTEXITCODE)"
    }
    
    Write-Log "Configuration processing completed successfully using bundled Install.ps1"
    
    # Fix Serilog file path to use a writable location
    # The default %BASEDIR%/App_Data/logs path is not writable when WEBSITE_RUN_FROM_PACKAGE=1 (read-only filesystem)
    Write-Log "Fixing Serilog file logging path in Web.config to use writable location..."
    $webConfigPath = "$SITE_DIR/Web.config"
    $webConfigContent = Get-Content $webConfigPath -Raw
    
    # Replace the read-only Serilog path with a writable location
    # The default %BASEDIR%/App_Data/logs path points to C:\home\site\wwwroot which is read-only when Azure App Service uses WEBSITE_RUN_FROM_PACKAGE=1
    # Using hardcoded D:\home path as %BASEDIR% doesn't resolve correctly in Azure App Service with WEBSITE_RUN_FROM_PACKAGE
    $oldPath = '%BASEDIR%/App_Data/logs/sm-log-.txt'
    $newPath = 'D:\home\LogFiles\Application\sm-log-.txt'  # Hardcoded writable path in Azure App Service
    
    if ($webConfigContent -match [regex]::Escape($oldPath)) {
        Write-Log "Replacing Serilog path: $oldPath -> $newPath"
        $webConfigContent = $webConfigContent -replace [regex]::Escape($oldPath), $newPath
        Set-Content -Path $webConfigPath -Value $webConfigContent -NoNewline
        Write-Log "Serilog file path hardcoded successfully"
    } else {
        Write-Log "Serilog file path not found or already fixed"
    }
    
    # Verify Web.config was processed (check for Azure Key Vault configuration)
    if ($AZURE_KEY_VAULT_NAME -and $webConfigContent -notmatch "vaultName=`".*`"") {
        Write-Log "Warning: Azure Key Vault configuration may not have been applied correctly" "WARN"
    } else {
        Write-Log "Web.config processing verified successfully"
    }
}

# Create deployment zip package
function New-DeploymentPackage {
    Write-Log "Creating deployment zip package..."
    
    # Use versioned filename format: SM-v4.5.0.80-alpha-ede1ab6d70.zip
    $versionedZipFile = "$OUTPUT_DIR/SM-$RELEASE_VERSION.zip"
    $legacyZipFile = "$OUTPUT_DIR/sm.zip"  # Keep for backward compatibility
    $timestamp = Get-Date -Format "yyyyMMddHHmmss"
    
    # Remove existing versioned zip if it exists
    if (Test-Path $versionedZipFile) {
        Remove-Item $versionedZipFile -Force
        Write-Log "Removed existing versioned zip file: $versionedZipFile"
    }
    
    # Remove existing legacy zip if it exists  
    if (Test-Path $legacyZipFile) {
        Remove-Item $legacyZipFile -Force
        Write-Log "Removed existing legacy zip file: $legacyZipFile"
    }
    
    # Create zip archive from site directory
    Write-Log "Creating zip from: $SITE_DIR"
    Write-Log "Output versioned zip: $versionedZipFile"
    Write-Log "Output legacy zip: $legacyZipFile"
    
    # Change to site directory and create zip
    Push-Location $SITE_DIR
    try {
        # Create versioned zip file
        & zip -r $versionedZipFile . -x "*.git*" "*.vs*" "*.DS_Store*" "Thumbs.db*"
        if ($LASTEXITCODE -ne 0) {
            Exit-WithError "Failed to create versioned zip package"
        }
        
        # Create legacy zip file for backward compatibility
        & zip -r $legacyZipFile . -x "*.git*" "*.vs*" "*.DS_Store*" "Thumbs.db*"
        if ($LASTEXITCODE -ne 0) {
            Exit-WithError "Failed to create legacy zip package"
        }
    }
    finally {
        Pop-Location
    }
    
    if (!(Test-Path $versionedZipFile)) {
        Exit-WithError "Versioned zip file was not created: $versionedZipFile"
    }
    
    if (!(Test-Path $legacyZipFile)) {
        Exit-WithError "Legacy zip file was not created: $legacyZipFile"
    }
    
    $versionedZipSize = (Get-Item $versionedZipFile).Length
    $legacyZipSize = (Get-Item $legacyZipFile).Length
    Write-Log "Deployment packages created successfully:"
    Write-Log "  Versioned file: $versionedZipFile"
    Write-Log "  Versioned size: $versionedZipSize bytes"
    Write-Log "  Legacy file: $legacyZipFile"
    Write-Log "  Legacy size: $legacyZipSize bytes"
    
    # Create metadata file
    $metadataFile = "$OUTPUT_DIR/sm-metadata.json"
    $metadata = @{
        version = $RELEASE_VERSION
        created = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        source = $SM_ZIP_DOWNLOAD_URL
        keyvault = $AZURE_KEY_VAULT_NAME
        trigger = $DEPLOYMENT_TRIGGER
        versionedFile = "SM-$RELEASE_VERSION.zip"
        versionedSize = $versionedZipSize
        legacyFile = "sm.zip"
        legacySize = $legacyZipSize
    } | ConvertTo-Json -Depth 2
    
    $metadata | Out-File -FilePath $metadataFile -Encoding UTF8
    Write-Log "Metadata file created: $metadataFile"
}

# Cleanup temporary files
function Clear-TempFiles {
    Write-Log "Cleaning up temporary files..."
    
    if (Test-Path $WORK_DIR) {
        Remove-Item $WORK_DIR -Recurse -Force
        Write-Log "Temporary files cleaned up"
    }
}

# Display summary information
function Show-Summary {
    Write-Log "=== SM Zip Preparation Summary ==="
    Write-Log "Version: $RELEASE_VERSION"
    Write-Log "Source: $SM_ZIP_DOWNLOAD_URL"
    Write-Log "Key Vault: $AZURE_KEY_VAULT_NAME"
    Write-Log "Trigger: $DEPLOYMENT_TRIGGER"
    
    # List output files
    Write-Log "Output files created:"
    if (Test-Path $OUTPUT_DIR) {
        Get-ChildItem $OUTPUT_DIR | ForEach-Object {
            $size = if ($_.PSIsContainer) { "directory" } else { "$($_.Length) bytes" }
            Write-Log "  $($_.Name) - $size"
        }
    }
    
    Write-Log "=== SM Zip Preparation Completed Successfully ==="
}

# Main execution function
function Main {
    Write-Log "=== Starting XMPro SM Zip Preparation ==="
    Write-Log "PowerShell version: $($PSVersionTable.PSVersion)"
    Write-Log "OS: $($PSVersionTable.OS)"
    
    try {
        Test-EnvironmentVariables
        Initialize-WorkDirectories
        Install-Requirements
        Get-SmZipDirect
        Initialize-WebConfig
        Invoke-ConfigProcessing
        New-DeploymentPackage
        Show-Summary
        
        Write-Log "=== SM Zip Preparation Completed Successfully ==="
        exit 0
    }
    catch {
        Write-Log "Unexpected error: $($_.Exception.Message)" "ERROR"
        Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
        exit 1
    }
    finally {
        Clear-TempFiles
    }
}

# Run main function
Main