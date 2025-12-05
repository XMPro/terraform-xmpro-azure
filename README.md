# XMPro Azure Terraform Module - Layered Architecture

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Azure](https://img.shields.io/badge/azure-%230072C6.svg?style=for-the-badge&logo=microsoftazure&logoColor=white)](https://azure.microsoft.com/)

A layered Terraform module for deploying the XMPro Industrial IoT platform on Microsoft Azure with separate infrastructure and application lifecycle management.

## 🏗️ Architecture Overview

The XMPro platform consists of multiple interconnected services that provide a complete Industrial IoT solution:

### Core Services
- **SM (Subscription Manager)**: Identity and subscription management service
- **AD (App Designer)**: Visual application builder for IoT dashboards
- **DS (Data Stream Designer)**: Real-time data processing and analytics engine
- **AI (AI Designer)**: AI/ML integration and model management (optional)
- **Stream Host**: Container-based stream processing runtime

### Supporting Infrastructure
- **Azure SQL Database**: Separate databases for each service (SM, AD, DS, AI)
- **Azure App Services**: Containerized hosting for web applications
- **Azure Container Instances**: Database migration and initialization containers
- **Azure Key Vault**: Secure storage for certificates and secrets
- **Azure Storage Account**: File storage for deployment artifacts
- **Azure DNS Zone**: Custom domain management (optional)
- **Application Insights**: Monitoring and telemetry
- **Log Analytics**: Centralized logging

For a visual representation of the architecture, see the [Azure Architecture Diagram](https://documentation.xmpro.com/4.5/src/installation/deployment/azure-terraform/#thats-it).

> ⚠️ **Security Notice**
> Use Azure Key Vault, environment variables, or your CI pipeline's secret store for all passwords, access tokens, and connection strings.
> The credentials shown below are sample values only – never commit real secrets to version control.
>
> **Password Requirements:**
> - All passwords (`db_admin_password`, `company_admin_password`, `site_admin_password`, `masterdata_db_admin_password`) must be at least **12 characters long**
> - Use strong passwords with special characters (e.g., `!@#$%^&*`)
> - Use unique passwords for each credential
> - Store passwords securely using environment variables:
>   ```bash
>   export TF_VAR_db_admin_password="YourSecure!Pass123"
>   export TF_VAR_company_admin_password="CompanyAdmin!Pass123"
>   export TF_VAR_site_admin_password="SiteAdmin!Pass123"
>   ```

## 📁 Module Structure

This module uses a **layered architecture** for separation of infrastructure and application lifecycle management:

```
terraform-xmpro-azure/
├── _infra/                    # Infrastructure orchestration module
│   ├── main.tf               # Orchestrates infrastructure sub-modules
│   ├── variables.tf          # Infrastructure variables
│   ├── outputs.tf            # Infrastructure outputs
│   └── locals.tf             # Local variables
├── _app/                      # Application orchestration module
│   ├── main.tf               # Orchestrates application sub-modules
│   ├── variables.tf          # Application variables
│   ├── outputs.tf            # Application outputs
│   └── locals.tf             # Local variables
├── modules/                   # Individual resource modules
│   ├── _infra/               # Infrastructure sub-modules
│   │   ├── resource-group/
│   │   ├── database/
│   │   ├── storage-account/
│   │   ├── monitoring/
│   │   ├── key-vault/
│   │   ├── app-service-plan/
│   │   ├── redis-cache/
│   │   ├── dns-zone/
│   │   └── alerting/
│   └── _app/                 # Application sub-modules
│       ├── sm-app-service/
│       ├── ad-app-service-container/
│       ├── ds-app-service-container/
│       ├── ai-app-service-container/
│       ├── sm-dbmigrate/
│       ├── ad-dbmigrate/
│       ├── ds-dbmigrate/
│       ├── ai-dbmigrate/
│       ├── sm-prep-container/
│       ├── licenses-container/
│       ├── stream-host-container/
│       ├── sm-key-vault/
│       ├── keyvault-secrets/
│       └── monitoring/
└── examples/
    └── layered/              # Layered deployment example
        ├── infra/            # Infrastructure layer
        └── app/              # Application layer
```

## 🎯 Layered Deployment Architecture

### Why Layered Architecture?

This pattern is [officially recommended by HashiCorp](https://developer.hashicorp.com/terraform/tutorials/modules/organize-configuration) and widely adopted in enterprise environments:

> "As your infrastructure grows, restructuring your monolith into logical units will make your Terraform configurations less confusing and safer to manage."

### Benefits

- **Different Lifecycles**: Infrastructure changes quarterly, applications change daily
- **Blast Radius Control**: Infrastructure failures don't affect application state
- **Team Separation**: Platform teams manage infrastructure, dev teams manage applications
- **Independent Deployments**: Deploy infrastructure once, redeploy applications multiple times
- **State Isolation**: Separate state files reduce risk and improve performance

## 🚀 Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) >= 2.0
- Azure subscription with appropriate permissions
- Docker registry access (Azure Container Registry recommended)

### Module Source

This module is available directly from GitHub:

```hcl
# Infrastructure layer
module "infrastructure" {
  source = "github.com/XMPro/terraform-xmpro-azure-ykgw//_infra?ref=main"
  # ... configuration
}

# Application layer
module "applications" {
  source = "github.com/XMPro/terraform-xmpro-azure-ykgw//_app?ref=main"
  # ... configuration
}
```

## 📖 Deployment Guide

### Step 1: Deploy Infrastructure Layer

The infrastructure layer creates foundational resources that change infrequently.

**Directory**: `examples/layered/infra/`

#### 1.1 Configure Infrastructure Variables

Copy the example file and customize:

```bash
cd examples/layered/infra
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:

```hcl
# ==========================================
# REQUIRED - Infrastructure settings
# ==========================================

# Core platform settings
company_name = "mycompany"                    # Your company name (lowercase, alphanumeric only)
name_suffix = "dev001"                        # Unique suffix for resource naming (4-8 chars, lowercase alphanumeric)
location = "eastus"                           # Azure region (e.g., eastus, westus2, westeurope)

# Database credentials - IMPORTANT: Don't change these after deployment!
db_admin_username = "xmadmin"                 # Database admin username
db_admin_password = "YourStrongPassword123!"  # Database admin password

# Master Data database credentials (only needed if create_masterdata = true)
# masterdata_db_admin_username = "mdadmin"
# masterdata_db_admin_password = "YourMDPassword123!"


# ==========================================
# OPTIONAL - Infrastructure tuning
# ==========================================

# App Service Plan configuration - Configure SKUs independently for each service
ad_service_plan_sku = "P1v4"                  # AD App Service Plan SKU (Options: B1, B2, B3, S1, S2, S3, P0v3, P1v3, P2v3, P3v3, P0v4, P1v4, P2v4, P3v4)
ds_service_plan_sku = "P1v4"                  # DS App Service Plan SKU (Options: B1, B2, B3, S1, S2, S3, P0v3, P1v3, P2v3, P3v3, P0v4, P1v4, P2v4, P3v4)
sm_service_plan_sku = "P1v4"                  # SM App Service Plan SKU (Options: B1, B2, B3, S1, S2, S3, P0v3, P1v3, P2v3, P3v3, P0v4, P1v4, P2v4, P3v4)
ai_service_plan_sku = "P1v4"                  # AI App Service Plan SKU (Options: B1, B2, B3, S1, S2, S3, P0v3, P1v3, P2v3, P3v3, P0v4, P1v4, P2v4, P3v4)
app_service_plan_worker_count = 1             # Number of workers for all App Service Plans

# Storage configuration
storage_account_tier = "Standard"             # Standard or Premium
storage_replication_type = "LRS"              # LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS

# Database configuration
# db_sku_name = "Basic"                       # Options: Basic, S0, S1, S2, S3, P1, P2, P4
# db_max_size_gb = 2                          # Maximum database size in GB
# db_collation = "SQL_Latin1_General_CP1_CI_AS"
# db_zone_redundant = false
# db_allow_all_ips = false
# create_local_firewall_rule = true

# Feature flags
enable_app_insights = true                    # Enable Application Insights monitoring
enable_log_analytics = true                   # Enable Log Analytics workspace
create_redis_cache = false                    # Create Redis Cache instance
enable_alerting = false                       # Enable Azure Monitor alerts
create_masterdata = false                     # Create separate Master Data database
enable_ai = false                             # Enable AI service infrastructure

# DNS configuration (optional)
enable_custom_domain = false
# dns_zone_name = "mycompany.com"

# Additional tags
# tags = {
#   "Project" = "XMPro"
#   "CostCenter" = "IT"
# }
```

#### 1.2 Initialize and Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply

# Save outputs for application layer
terraform output -json > ../app/infra-outputs.json
```

#### 1.3 Capture Infrastructure Outputs

Key outputs needed for the application layer:

```bash
# Resource names
terraform output resource_group_name
terraform output storage_account_name
terraform output sql_server_fqdn
terraform output name_suffix

# App Service Plans
terraform output ad_service_plan_name
terraform output ds_service_plan_name
terraform output sm_service_plan_name

# Key Vaults
terraform output ad_key_vault_name
terraform output ds_key_vault_name
terraform output sm_key_vault_name

# Monitoring (required for app layer)
terraform output log_analytics_workspace_name
terraform output app_insights_name
terraform output app_insights_connection_string
```

### Step 2: Deploy Application Layer

The application layer deploys XMPro services that can be updated frequently.

**Directory**: `examples/layered/app/`

#### 2.1 Configure Application Variables

Copy the example file and customize:

```bash
cd ../app
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` using outputs from Step 1:

```hcl
# Core settings (must match infrastructure)
company_name = "mycompany"
name_suffix = "dev001"

# Infrastructure resource names (from infrastructure outputs)
resource_group_name = "rg-mycompany-dev001"
storage_account_name = "stmycdev001"
sql_server_fqdn = "sql-mycompany-dev001.database.windows.net"

# Storage SAS Token (optional - leave empty to auto-generate)
# Format: "?sv=2021-06-08&ss=bfqt&srt=sco&sp=rwdlacupiytfx&se=2025-12-31T23:59:59Z&st=2025-01-01T00:00:00Z&spr=https&sig=..."
storage_sas_token = ""

# App Service Plan names from infrastructure
ad_service_plan_name = "plan-ad-mycompany-dev001"
ds_service_plan_name = "plan-ds-mycompany-dev001"
sm_service_plan_name = "plan-sm-mycompany-dev001"
ai_service_plan_name = null  # AI disabled

# Key Vault names from infrastructure
ad_key_vault_name = "kv-ad-mycompany-dev001"
ds_key_vault_name = "kv-ds-mycompany-dev001"
sm_key_vault_name = "kv-sm-mycompany-dev001"

# Monitoring (from infrastructure outputs) - REQUIRED
log_analytics_workspace_name = "log-mycompany-dev001"
app_insights_name            = "appinsights-mycompany-dev001"

# Application Insights connection string (optional)
app_insights_connection_string = ""

# Container registry settings
acr_url_product = "xmpro.azurecr.io"
acr_username = ""  # Leave empty for public registry
acr_password = ""  # Leave empty for public registry

# Database credentials (must match infrastructure)
db_admin_username = "xmadmin"
db_admin_password = "YourStrongPassword123!"

# Application passwords
site_admin_password = "P@ssw0rd1234!XM"
company_admin_password = "P@ssw0rd1234!XM"

# Company admin user details
company_admin_first_name = "Admin"
company_admin_last_name = "User"

# Container image version
imageversion = "4.5.3"

# Evaluation mode (set to true for evaluation deployments)
is_evaluation_mode = false

# SMTP configuration (optional)
smtp_server = ""
smtp_from_address = "noreply@mycompany.com"
smtp_username = ""
smtp_password = ""
smtp_port = 587
smtp_enable_ssl = true

# Feature flags
enable_ai = false
create_stream_host = true

# DNS configuration
enable_custom_domain = false
dns_zone_name = ""

# Tags
keep_or_delete_tag = "keep"
billing_tag = "development"
```

#### 2.2 Initialize and Deploy Applications

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy applications
terraform apply
```

### Step 3: Deploy Additional Stream Hosts (Optional)

The application layer supports deploying multiple identical Stream Host containers for horizontal scaling scenarios such as edge processing, load distribution, or regional deployments.

#### 3.1 Configure Additional Stream Hosts

In your `terraform.tfvars` file (from Step 2), add stream host configuration:

```hcl
# Deploy multiple identical Stream Host containers
stream_host_count             = 3  # Number of stream hosts (0-20)
stream_host_ds_server_url     = "https://ds-mycompany-dev001.azurewebsites.net"
stream_host_collection_id     = "12345678-1234-1234-1234-123456789abc"
stream_host_collection_secret = "your-collection-secret-here"

# Resource allocation (applied to all stream hosts)
stream_host_cpu    = 2  # CPU cores (0.25-4)
stream_host_memory = 8  # Memory in GB (0.5-16)

# Optional: Use specific image variant
stream_host_variant = "bookworm-slim-python3.12"  # "" (default), "bookworm-slim-python3.12", "alpine3.21"

# Optional: Add Python packages (Python variant only)
stream_host_environment_variables = {
  SH_PIP_MODULES = "pandas numpy scikit-learn"
}

# Optional: Enable alerting for all stream hosts
stream_host_enable_alerting       = true
stream_host_alert_email_addresses = ["admin@mycompany.com", "ops@mycompany.com"]
stream_host_enable_cpu_alerts     = true
stream_host_cpu_alert_threshold   = 80
stream_host_enable_memory_alerts  = true
stream_host_memory_alert_threshold = 85
```

#### 3.2 Deploy Stream Hosts

```bash
cd examples/layered/app

# Review changes
terraform plan

# Deploy additional stream hosts
terraform apply

# View deployed stream hosts
terraform output stream_hosts
terraform output stream_hosts_summary
```

#### 3.3 Stream Host Naming

Each stream host gets a unique random suffix for naming:
- Container names: `ci-sh-{company_name}-{random_suffix}`
- Example: `ci-sh-mycompany-a1b2c3d4`, `ci-sh-mycompany-e5f6g7h8`

#### 3.4 Use Cases

**Horizontal Scaling**:
```hcl
stream_host_count = 5  # Deploy 5 identical stream hosts
stream_host_cpu   = 4
stream_host_memory = 16
```

**Edge Processing**:
```hcl
stream_host_count = 10  # Deploy 10 lightweight stream hosts
stream_host_variant = "alpine3.21"
stream_host_cpu    = 1
stream_host_memory = 2
```

**ML/AI Workloads**:
```hcl
stream_host_count = 3
stream_host_variant = "bookworm-slim-python3.12"
stream_host_cpu    = 4
stream_host_memory = 16
stream_host_environment_variables = {
  SH_PIP_MODULES = "pandas numpy scikit-learn tensorflow"
}
```

### Step 4: Access Your XMPro Platform

After deployment, use these credentials to access:

- **Site Admin**: `admin@xmpro.onxmpro.com` / `site_admin_password`
- **Company Admin**: `firstname.lastname@{company_name}.onxmpro.com` / `company_admin_password`

For example, if `company_name = "mycompany"` and the admin is John Doe:
- Company Admin login: `john.doe@mycompany.onxmpro.com`

Access URLs:
```bash
# Get application URLs
cd examples/layered/app
terraform output sm_app_url
terraform output ad_app_url
terraform output ds_app_url
```

## 🔄 Update Workflow

### Updating Applications Only

When you need to update application settings or redeploy:

```bash
cd examples/layered/app

# Update terraform.tfvars with new values
# For example: imageversion = "5.0.1"

terraform plan
terraform apply
```

### Updating Infrastructure

When you need to modify infrastructure (rare):

```bash
cd examples/layered/infra

# Update terraform.tfvars with new values
# For example: app_service_plan_sku = "P2v4"

terraform plan
terraform apply

# Update application layer with any new output values
cd ../app
terraform apply -refresh-only  # Update state with infrastructure changes
terraform apply                # Apply any necessary application changes
```

## 📋 Infrastructure Layer Inputs

### Required Variables

| Name | Description | Type | Example |
|------|-------------|------|---------|
| company_name | Company name for resource naming | `string` | `"mycompany"` |
| name_suffix | Unique suffix for resource naming | `string` | `"dev001"` |
| location | Azure region for resources | `string` | `"eastus"` |
| db_admin_username | Database admin username | `string` | `"xmadmin"` |
| db_admin_password | Database admin password | `string` | `"P@ssw0rd1234!"` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| ad_service_plan_sku | AD App Service plan SKU | `string` | `"B1"` |
| ds_service_plan_sku | DS App Service plan SKU | `string` | `"B1"` |
| sm_service_plan_sku | SM App Service plan SKU | `string` | `"B1"` |
| ai_service_plan_sku | AI App Service plan SKU | `string` | `"B1"` |
| app_service_plan_worker_count | Number of workers for all plans | `number` | `1` |
| storage_account_tier | Storage account tier | `string` | `"Standard"` |
| storage_replication_type | Storage replication type | `string` | `"LRS"` |
| enable_app_insights | Enable Application Insights | `bool` | `true` |
| enable_log_analytics | Enable Log Analytics | `bool` | `true` |
| create_redis_cache | Create Redis Cache | `bool` | `false` |
| enable_alerting | Enable Azure Monitor alerts | `bool` | `false` |
| enable_ai | Enable AI service infrastructure | `bool` | `false` |
| enable_custom_domain | Enable custom domain | `bool` | `false` |
| dns_zone_name | DNS zone name | `string` | `""` |
| create_masterdata | Create Master Data database | `bool` | `false` |
| sm_database_name | Subscription Manager database name | `string` | `"SM"` |
| ad_database_name | App Designer database name | `string` | `"AD"` |
| ds_database_name | Data Stream Designer database name | `string` | `"DS"` |
| ai_database_name | AI Service database name | `string` | `"AI"` |

**Note**: Each XMPro service (AD, DS, SM, AI) can be configured with its own App Service Plan SKU, allowing independent scaling based on workload requirements.

#### App Service Plan SKU Options

| SKU | vCPU | RAM | Use Case |
|-----|------|-----|----------|
| **B1** | 1 | 1.75 GB | Development/Testing |
| **B2** | 2 | 3.5 GB | Small workloads |
| **B3** | 4 | 7 GB | Medium workloads |
| **S1** | 1 | 1.75 GB | Production (staging slots) |
| **S2** | 2 | 3.5 GB | Production (staging slots) |
| **S3** | 4 | 7 GB | Production (staging slots) |
| **P0v3** | 1 | 4 GB | Production (entry level) |
| **P1v3** | 2 | 8 GB | Production (high memory) |
| **P2v3** | 4 | 16 GB | Production (large workloads) |
| **P3v3** | 8 | 32 GB | Production (extra large) |
| **P0v4** | 1 | 4 GB | Production v4 (entry level, recommended) |
| **P1v4** | 2 | 8 GB | Production v4 (high memory, recommended) |
| **P2v4** | 4 | 16 GB | Production v4 (large workloads, recommended) |
| **P3v4** | 8 | 32 GB | Production v4 (extra large, recommended) |

**Scaling Strategy Examples**:
```hcl
# Example 1: Cost-optimized for development
ad_service_plan_sku = "B1"
ds_service_plan_sku = "B1"
sm_service_plan_sku = "B1"
ai_service_plan_sku = "B1"

# Example 2: Production-ready with independent scaling
ad_service_plan_sku = "P1v4"  # App Designer - moderate load
ds_service_plan_sku = "P2v4"  # Data Stream - high processing needs
sm_service_plan_sku = "P1v4"  # Subscription Manager - moderate load
ai_service_plan_sku = "P2v4"  # AI Designer - high compute needs

# Example 3: Mixed environment (dev/prod services)
ad_service_plan_sku = "B2"    # Development AD instance
ds_service_plan_sku = "P1v4"  # Production DS instance
sm_service_plan_sku = "P1v4"  # Production SM instance
ai_service_plan_sku = "B1"    # Development AI instance
```

## 📋 Application Layer Inputs

### Required Variables

| Name | Description | Type | Example |
|------|-------------|------|---------|
| company_name | Company name (must match infra) | `string` | `"mycompany"` |
| name_suffix | Suffix (must match infra) | `string` | `"dev001"` |
| resource_group_name | Resource group from infra | `string` | `"rg-mycompany-dev001"` |
| storage_account_name | Storage account from infra | `string` | `"stmycdev001"` |
| sql_server_fqdn | SQL Server FQDN from infra | `string` | `"sql-mycompany-dev001.database.windows.net"` |
| ad_service_plan_name | AD App Service plan name | `string` | `"plan-ad-mycompany-dev001"` |
| ds_service_plan_name | DS App Service plan name | `string` | `"plan-ds-mycompany-dev001"` |
| sm_service_plan_name | SM App Service plan name | `string` | `"plan-sm-mycompany-dev001"` |
| ad_key_vault_name | AD Key Vault name | `string` | `"kv-ad-mycompany-dev001"` |
| ds_key_vault_name | DS Key Vault name | `string` | `"kv-ds-mycompany-dev001"` |
| sm_key_vault_name | SM Key Vault name | `string` | `"kv-sm-mycompany-dev001"` |
| db_admin_username | Database username (must match infra) | `string` | `"xmadmin"` |
| db_admin_password | Database password (must match infra) | `string` | `"P@ssw0rd1234!"` |
| site_admin_password | Site admin password | `string` | `"P@ssw0rd1234!"` |
| company_admin_password | Company admin password | `string` | `"P@ssw0rd1234!"` |
| log_analytics_workspace_name | Log Analytics workspace name from infra | `string` | `"log-mycompany-dev001"` |
| app_insights_name | Application Insights name from infra | `string` | `"appinsights-mycompany-dev001"` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| acr_url_product | Container registry URL | `string` | `"xmpro.azurecr.io"` |
| acr_username | Registry username | `string` | `""` |
| acr_password | Registry password | `string` | `""` |
| imageversion | Container image version | `string` | `"4.5.3"` |
| is_evaluation_mode | Deploy with evaluation licenses | `bool` | `false` |
| company_admin_first_name | Admin first name (alphanumeric, spaces, hyphens allowed, 1-50 chars) | `string` | `"John"` |
| company_admin_last_name | Admin last name (alphanumeric, spaces, hyphens allowed, 1-50 chars) | `string` | `"Doe"` |
| company_admin_email_address | Admin email | `string` | `""` |
| enable_ai | Enable AI service (must match infra) | `bool` | `false` |
| create_stream_host | Create Stream Host instance | `bool` | `true` |
| enable_custom_domain | Enable custom domain (must match infra) | `bool` | `false` |
| smtp_server | SMTP server address | `string` | `""` |
| smtp_from_address | SMTP from address | `string` | `""` |
| smtp_username | SMTP username | `string` | `""` |
| smtp_password | SMTP password | `string` | `""` |
| smtp_port | SMTP port | `number` | `587` |
| smtp_enable_ssl | Enable SSL for SMTP | `bool` | `true` |
| sm_database_name | Subscription Manager database name | `string` | `"SM"` |
| ad_database_name | App Designer database name | `string` | `"AD"` |
| ds_database_name | Data Stream Designer database name | `string` | `"DS"` |
| ai_database_name | AI Service database name | `string` | `"AI"` |

## 🗃️ Custom Database Names

The module supports custom database names instead of the default `SM`, `AD`, `DS`, and `AI` names. This allows you to follow organizational naming conventions or integrate with existing database infrastructure.

### Benefits

- **Organizational Standards**: Follow your company's database naming conventions
- **Existing Infrastructure**: Integrate with existing databases using non-standard names
- **Descriptive Names**: Use meaningful names like `XMPro_SubscriptionManager` or `Prod_AppDesigner`
- **Backward Compatible**: Defaults to standard names when not specified

### Configuration in Layered Architecture

#### Infrastructure Layer (`infra/terraform.tfvars`)

Add custom database names to your infrastructure configuration:

```hcl
# Database configuration
db_admin_username = "xmadmin"
db_admin_password = "YourStrongPassword123!"

# Custom database names (optional - defaults to SM, AD, DS, AI)
sm_database_name = "XMPro_SubscriptionManager"
ad_database_name = "XMPro_AppDesigner"
ds_database_name = "XMPro_DataStream"
ai_database_name = "XMPro_AI"
```

#### Application Layer (`app/terraform.tfvars`)

Specify the same custom names in your application configuration:

```hcl
# Database credentials (must match infrastructure)
db_admin_username = "xmadmin"
db_admin_password = "YourStrongPassword123!"

# Custom database names (must match infrastructure)
sm_database_name = "XMPro_SubscriptionManager"
ad_database_name = "XMPro_AppDesigner"
ds_database_name = "XMPro_DataStream"
ai_database_name = "XMPro_AI"
```

### Complete Example

**Step 1: Infrastructure with Custom Database Names**

```bash
cd examples/layered/infra
```

Edit `terraform.tfvars`:
```hcl
company_name = "mycompany"
name_suffix = "prod01"
location = "eastus"

# Database configuration with custom names
db_admin_username = "xmadmin"
db_admin_password = "YourStrongPassword123!"

sm_database_name = "MyCompany_SM_Prod"
ad_database_name = "MyCompany_AD_Prod"
ds_database_name = "MyCompany_DS_Prod"
ai_database_name = "MyCompany_AI_Prod"
```

Deploy infrastructure:
```bash
terraform init
terraform apply
terraform output -json > ../app/infra-outputs.json
```

**Step 2: Application with Custom Database Names**

```bash
cd ../app
```

Edit `terraform.tfvars`:
```hcl
# Core settings (from infrastructure)
company_name = "mycompany"
name_suffix = "prod01"
resource_group_name = "rg-mycompany-prod01"
sql_server_fqdn = "sql-mycompany-prod01.database.windows.net"

# Database credentials (must match infrastructure)
db_admin_username = "xmadmin"
db_admin_password = "YourStrongPassword123!"

# Custom database names (must match infrastructure)
sm_database_name = "MyCompany_SM_Prod"
ad_database_name = "MyCompany_AD_Prod"
ds_database_name = "MyCompany_DS_Prod"
ai_database_name = "MyCompany_AI_Prod"

# ... other application settings
```

Deploy applications:
```bash
terraform init
terraform apply
```

### Using with Existing Databases

Custom database names work seamlessly when using existing databases. The infrastructure layer will skip database creation, and the application layer will connect to your existing databases with custom names.

**Infrastructure Layer** (`infra/terraform.tfvars`):
```hcl
# Use existing database
use_existing_database = true
existing_sql_server_fqdn = "existing-server.database.windows.net"

# Custom database names (must match existing databases)
sm_database_name = "Legacy_SM_Database"
ad_database_name = "Legacy_AD_Database"
ds_database_name = "Legacy_DS_Database"
ai_database_name = "Legacy_AI_Database"

# Existing database credentials
db_admin_username = "admin"
db_admin_password = "ExistingPassword123!"
```

**Application Layer** (`app/terraform.tfvars`):
```hcl
# Reference existing infrastructure
use_existing_database = true
sql_server_fqdn = "existing-server.database.windows.net"

# Custom database names (must match existing databases)
sm_database_name = "Legacy_SM_Database"
ad_database_name = "Legacy_AD_Database"
ds_database_name = "Legacy_DS_Database"
ai_database_name = "Legacy_AI_Database"

# Existing database credentials (must match infrastructure)
db_admin_username = "admin"
db_admin_password = "ExistingPassword123!"

# Existing product IDs and keys (required)
existing_sm_product_id = "..."
existing_ad_product_id = "..."
existing_ds_product_id = "..."
existing_ai_product_id = "..."
existing_ad_product_key = "..."
existing_ds_product_key = "..."
existing_ai_product_key = "..."
```

### Important Notes

- **Consistency Required**: Database names must match between infrastructure and application layers
- **Length Validation**: Database names must be between 1 and 128 characters
- **Connection Strings**: Automatically updated to use custom names throughout the deployment
- **Migration Containers**: Use custom database names when creating or migrating databases
- **Existing Databases**: Custom names must exactly match the database names on your SQL Server
- **Evaluation Mode**: Custom database names are fully supported with evaluation mode (`is_evaluation_mode = true`)

## ✅ Name Validation

The module enforces validation rules for company administrator names to prevent deployment issues and security vulnerabilities.

### Validation Rules

Both `company_admin_first_name` and `company_admin_last_name` variables must:
- **Start and end with an alphanumeric character**: A-Z, a-z, 0-9
- **May contain spaces or hyphens** in the middle (between alphanumeric characters)
- **Be between 1-50 characters** in length (after trimming whitespace)
- **NOT contain other special characters** (e.g., @, #, $, %, !, ', etc.)

Leading and trailing whitespace is automatically trimmed before validation.

### Username Generation

When the `company_admin_username` is not explicitly provided, it is automatically generated from the first and last names with the following transformations:

- **Spaces are replaced with dots** (`.`)
- **Hyphens are replaced with dots** (`.`)
- **Names are converted to lowercase**
- **Format**: `firstname.lastname@{company_name}.onxmpro.com`

#### Username Examples

```hcl
# Simple name
company_admin_first_name = "John"
company_admin_last_name = "Smith"
# Generated username: john.smith@mycompany.onxmpro.com

# Multi-part name with space
company_admin_first_name = "Mary Jane"
company_admin_last_name = "Smith"
# Generated username: mary.jane.smith@mycompany.onxmpro.com

# Hyphenated name
company_admin_first_name = "Jean-Pierre"
company_admin_last_name = "Dubois"
# Generated username: jean.pierre.dubois@mycompany.onxmpro.com

# Combined spaces and hyphens
company_admin_first_name = "Mary-Jane"
company_admin_last_name = "Van Der Berg"
# Generated username: mary.jane.van.der.berg@mycompany.onxmpro.com
```

### Valid Examples

```hcl
# Simple names
company_admin_first_name = "John"
company_admin_last_name = "Smith"

# Multi-part names with spaces
company_admin_first_name = "Mary Jane"
company_admin_last_name = "Van Der Berg"

# Hyphenated names
company_admin_first_name = "Jean-Pierre"
company_admin_last_name = "Smith-Jones"

# Alphanumeric names
company_admin_first_name = "Admin123"
company_admin_last_name = "User01"

# Single character (minimum)
company_admin_first_name = "J"
company_admin_last_name = "S"

# Whitespace is trimmed automatically
company_admin_first_name = "  John  "  # Becomes "John"
company_admin_last_name = "  Smith  " # Becomes "Smith"
```

### Invalid Examples

The following will **fail validation**:

```hcl
# Cannot start with space or hyphen
company_admin_first_name = " John"      # ❌ Starts with space
company_admin_first_name = "-Pierre"    # ❌ Starts with hyphen

# Cannot end with space or hyphen
company_admin_last_name = "Smith "      # ❌ Ends with space
company_admin_last_name = "Jones-"      # ❌ Ends with hyphen

# Apostrophes not allowed
company_admin_last_name = "O'Brien"     # ❌ Contains apostrophe

# Special characters not allowed
company_admin_first_name = "John@Admin" # ❌ Contains @
company_admin_last_name = "Smith#123"   # ❌ Contains #

# Email addresses not allowed
company_admin_first_name = "admin@company.com" # ❌ Contains @ and .

# Too long (over 50 characters)
company_admin_first_name = "ThisNameIsWayTooLongAndExceedsFiftyCharactersInLength" # ❌

# Only spaces or hyphens (no alphanumeric)
company_admin_first_name = "---"        # ❌ No alphanumeric characters
company_admin_first_name = "   "        # ❌ Only whitespace
```

### Error Messages

When validation fails, Terraform will display a clear error message:

```
Error: Invalid value for variable

First name must start and end with an alphanumeric character, may contain
spaces or hyphens in the middle, and must be 1-50 characters long (after
trimming whitespace). Special characters (except spaces and hyphens) are not allowed.
```

### Why These Restrictions?

- **Azure Resource Naming**: Prevents conflicts with Azure resource naming requirements
- **Database Safety**: Avoids potential SQL injection or command injection vulnerabilities
- **Deployment Reliability**: Ensures consistent deployment across environments
- **Username Generation**: Names are normalized to create valid email-format usernames
- **Security**: Eliminates attack vectors from special character handling

## 📤 Outputs

### Infrastructure Layer Outputs

| Name | Description |
|------|-------------|
| resource_group_name | Resource group name |
| location | Azure region |
| name_suffix | Resource naming suffix |
| storage_account_name | Storage account name |
| sql_server_fqdn | SQL Server FQDN |
| ad_service_plan_name | AD App Service plan name |
| ds_service_plan_name | DS App Service plan name |
| sm_service_plan_name | SM App Service plan name |
| ad_key_vault_name | AD Key Vault name |
| ds_key_vault_name | DS Key Vault name |
| sm_key_vault_name | SM Key Vault name |
| log_analytics_workspace_name | Log Analytics workspace name |
| app_insights_name | Application Insights name |
| app_insights_connection_string | Application Insights connection string |

### Application Layer Outputs

| Name | Description |
|------|-------------|
| sm_app_url | Subscription Manager URL |
| ad_app_url | App Designer URL |
| ds_app_url | Data Stream Designer URL |
| ai_app_url | AI Designer URL (if enabled) |
| stream_host_container_id | Stream Host container ID |
| company_details | Company admin details |

## 🔐 Evaluation vs Production Mode

### Evaluation Mode (`is_evaluation_mode = true`)

**Purpose**: Quick setup for demos, trials, and evaluation environments.

**Features**:
- Deploys licenses container with predefined evaluation product IDs and keys
- Uses standardized evaluation settings
- Includes built-in license provisioning
- Suitable for proof-of-concept scenarios

> ⚠️ **Known Limitation**
> Evaluation mode with custom `sm_database_name` (non-default "SM") currently does not work due to a bug in the licenses container (Work Item #21834).
> The licenses container has a hardcoded database name and will fail to write licenses when custom database names are used.
> **Workaround**: Use the default database name "SM" when deploying with `is_evaluation_mode = true`.

### Production Mode (`is_evaluation_mode = false`)

**Purpose**: Production deployments where you provide your own licensing.

**Features**:
- Skips licenses container deployment
- Uses hardcoded fallback product IDs and keys
- Customer manages their own license provisioning
- Requires external license management through SM interface

### Migration Between Modes

To switch from evaluation to production:

1. Set `is_evaluation_mode = false` in application layer
2. Provide your own product IDs and keys from XMPro
3. Set up external license management
4. Apply the Terraform configuration

## 🔐 Security Best Practices

### Credential Management

- **Never commit secrets to version control**
- Use Azure Key Vault for production secrets
- Use environment variables for local development
- Rotate secrets regularly
- Use managed identities where possible

### Example: Using Environment Variables

```bash
# Set sensitive variables via environment
export TF_VAR_db_admin_password="YourSecurePassword"
export TF_VAR_site_admin_password="YourSecurePassword"
export TF_VAR_company_admin_password="YourSecurePassword"

# Deploy without storing secrets in tfvars
terraform apply
```

### Example: Using Azure Key Vault Data Source

```hcl
# Retrieve secrets from Azure Key Vault
data "azurerm_key_vault_secret" "db_password" {
  name         = "db-admin-password"
  key_vault_id = var.secrets_key_vault_id
}

# Use in module
module "applications" {
  source = "github.com/XMPro/terraform-xmpro-azure-ykgw//_app?ref=main"

  db_admin_password = data.azurerm_key_vault_secret.db_password.value
  # ... other configuration
}
```

## 🚨 Troubleshooting

### Common Issues

#### Infrastructure Outputs Not Available

**Problem**: Application layer can't find infrastructure outputs

**Solution**:
```bash
cd examples/layered/infra
terraform output -json > ../app/infra-outputs.json

cd ../app
# Use outputs in variables or reference via data source
```

#### State File Conflicts

**Problem**: Concurrent modifications to state files

**Solution**: Use remote state with locking:
```hcl
terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-state-rg"
    storage_account_name = "tfstate"
    container_name       = "tfstate"
    key                  = "infra.terraform.tfstate"
  }
}
```

#### Resource Name Conflicts

**Problem**: Resources already exist with the same name

**Solution**: Change `name_suffix` to ensure uniqueness:
```hcl
name_suffix = "dev002"  # Use a different suffix
```

## 📄 License

This module is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support with this Terraform module:

1. **Documentation**: Review the [XMPro public documentation](https://documentation.xmpro.com)
2. **Enterprise Support**: Contact XMPro for commercial support options

---

**Terraform Module**: XMPro Azure Platform - Layered Architecture
**Version**: Compatible with XMPro 4.5.x and later

**Maintained By**: XMPro Platform Engineering Team
