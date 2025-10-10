# XMPro Existing Database Deployment Example

Deploy XMPro platform using your existing SQL Server infrastructure while preserving your data.

## 🎯 Purpose

This example demonstrates how to deploy XMPro applications to connect with existing databases, perfect for:
- Version upgrades without data migration
- Development environments with persistent data
- Disaster recovery scenarios

## 📋 Prerequisites

Before you begin, ensure you have:

✅ **Existing SQL Server** with these databases:
- `AD` - Application Designer
- `DS` - Data Stream Designer  
- `SM` - Subscription Manager
- `AI` - AI Services (optional)

✅ **Network connectivity** between Azure resources and your SQL Server

✅ **Product IDs and Keys** from your existing XMPro installation
   - Found in SM → Products section
   - [Detailed guide on retrieving Product IDs and Keys](https://documentation.xmpro.com/4.5/src/installation/deployment/azure-terraform/existing-database.html#how-to-retrieve-product-ids-and-keys)

## 🚀 Quick Start

### 1. Configure Your Deployment

Create a `terraform.tfvars` file with your existing infrastructure details:

```hcl
# Core Configuration
use_existing_database    = true
existing_sql_server_fqdn = "my-existing-server.database.windows.net"

# Product IDs (from SM → Products → [Product Name])
existing_sm_product_id = "f239d3d4-6d77-4e36-a740-e4eb3091efb9"  # Replace with your SM Product ID
existing_ad_product_id = "9a2e17d3-33cc-4034-80de-50a1898a7467"  # Replace with your AD Product ID
existing_ds_product_id = "e6e5ac1f-31b2-4a4f-a607-a79e309cd9b1"  # Replace with your DS Product ID
existing_ai_product_id = "2cf2bb72-ec7d-430a-a383-b7f6c956b237"  # Optional: AI Product ID

# Product Keys (from SM → Products → [Product Name])
existing_ad_product_key = "cc72a497-baa2-4f7f-af07-e065682a18b4"  # Replace with your AD Product Key
existing_ds_product_key = "7569167d-10f0-4de4-9347-95c1c93e184f"  # Replace with your DS Product Key
existing_ai_product_key = "1f6b18eb-7dbb-4c7e-9b27-f8a81f0e6ae8"  # Optional: AI Product Key

# SMTP Configuration (Required)
# SMTP settings are mandatory as they are stored in Key Vault for application use
smtp_server = "smtp.office365.com"
smtp_port = 587
smtp_from_address = "notifications@mycompany.com"
smtp_username = "notifications@mycompany.com"
smtp_password = "your-smtp-password-here"
smtp_enable_ssl = true
```

### 2. Deploy

Run these commands to deploy:

```bash
terraform init
terraform apply
```

## 🔧 What Happens During Deployment

### ✅ What Gets Created
- App Services for AD, DS, SM (and AI if configured)
- App Service Plans
- Key Vault for secrets
- Storage Account
- Application Insights

### ⏭️ What Gets Skipped
- SQL Server creation
- Database creation
- Licenses container deployment

### 📝 Important Notes

**Database Migration**: Migration containers (`sm-dbmigrate`, `ad-dbmigrate`, etc.) will run to update your database schemas to the latest version.

**Licensing**: When using existing databases, the licenses container is skipped. You'll need to manage licenses through the SM interface after deployment.

**SMTP Configuration**: SMTP settings are mandatory for existing database deployments as they are stored in Azure Key Vault and used by the applications for email notifications. All SMTP variables must be provided.

## 🔐 Licensing with Existing Databases

⚠️ **Important**: The `is_evaluation_mode` variable is **intentionally not included** in this existing database example because it has no effect when `use_existing_database = true`.

**Why Evaluation Mode is Not Relevant:**
- The licenses container is **never deployed** when using existing databases
- Licensing must always be managed manually through the SM interface
- Including `is_evaluation_mode` would be misleading and serve no purpose

**Licensing Management:**
1. Deploy the infrastructure using this example
2. Access the SM (Subscription Manager) interface after deployment
3. Upload your licenses manually through the SM admin panel
4. Configure licensing for AD, DS, and AI services as needed

## 🔧 Troubleshooting

### SMTP Configuration Issues

#### Scenario 1: Forgot to Configure SMTP During Initial Deployment

**Problem**: Deployed without SMTP configuration, now email notifications don't work

**Symptoms**:
- No email notifications being sent from XMPro applications
- Default/example SMTP values are being used
- Email functionality appears disabled

**Solution**: 
1. Add all required SMTP variables to your `terraform.tfvars`:
   ```hcl
   smtp_server       = "smtp.office365.com"
   smtp_from_address = "notifications@yourdomain.com"
   smtp_username     = "your-smtp-username"
   smtp_password     = "your-smtp-password"
   smtp_port         = 587
   smtp_enable_ssl   = true
   ```

2. Re-run Terraform to update the Key Vault secrets:
   ```bash
   terraform apply
   ```

3. The App Services will automatically restart and load the updated SMTP configuration from Key Vault

#### Scenario 2: SMTP Configuration Not Working

**Problem**: SMTP is configured but email notifications still not working

**Symptoms**:
- SMTP settings appear correct in terraform.tfvars
- Still no email notifications
- Possible authentication errors in logs

**Solution**:
1. Verify SMTP credentials are correct and account has permission to send emails
2. Test SMTP settings outside of XMPro to confirm they work
3. Check Azure Key Vault to confirm SMTP secrets were properly stored:
   - Navigate to your Key Vault in Azure Portal
   - Verify secrets: SMTPSERVER, SMTPUSER, SMTPPASS, etc.
4. If Key Vault secrets are incorrect, update `terraform.tfvars` and run `terraform apply` again

**Note**: SMTP settings are stored in Azure Key Vault and are essential for email functionality. The applications read these values from Key Vault at startup.

## 📚 Additional Resources

- [Main Module Documentation](https://github.com/XMPro/terraform-xmpro-azure)
- [Detailed Configuration Guide](https://github.com/XMPro/terraform-xmpro-azure#existing-database-support)
- [Troubleshooting Guide](https://documentation.xmpro.com/4.5/src/installation/deployment/azure-terraform/troubleshooting.html)

## 💡 Tips

- Always backup your databases before running migrations
- Test in a non-production environment first
- Ensure your SQL Server firewall allows connections from Azure services
- Keep your Product IDs and Keys secure - don't commit them to version control