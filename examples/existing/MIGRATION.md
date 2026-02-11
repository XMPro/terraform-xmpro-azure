# URL Migration Guide for Existing Database Deployments

When deploying XMPro to new infrastructure while connecting to existing databases, the database records containing URLs must be updated manually. This guide covers those required database changes.

## What Terraform Handles

The Terraform module automatically configures:
- App Service app settings (identity URLs, connection strings)
- Custom domains (when `enable_custom_domain = true`)
- Health check endpoints
- Key Vault secrets

**No manual app configuration is needed** - Terraform handles this via variables.

## What Requires Manual Migration

Database tables store URLs that must be updated to match your new deployment:

| Database | Tables | Purpose |
|----------|--------|---------|
| SM | `ProductUrl`, `Product` | Product URLs and logout URLs |
| DS | `Parameter`, `ServerVariables` | AD URL references in streams |
| AD | `XMGlobalSetting` | DS URL reference |

## Pre-Migration: Document Stream Hosts

Before making changes, record connected Stream Hosts:

```sql
SELECT
    ec.CompanyId,
    ec.Id as CollectionId,
    d.Id as DeviceId,
    d.name as DeviceName
FROM dbo.EdgeContainer ec
INNER JOIN dbo.Device d ON d.EdgeContainerId = ec.id
ORDER BY d.timestamp DESC
```

## Database Migration Scripts

### SM Database

Update product URLs to match your new deployment:

```sql
-- Replace OLD_URL and NEW_URL with your actual URLs
-- Example: OLD_URL = 'https://old-ad.azurewebsites.net/'
--          NEW_URL = 'https://ad.yourdomain.com/'

UPDATE [dbo].[ProductUrl]
    SET [Url] = 'NEW_AD_URL'
    WHERE [Url] = 'OLD_AD_URL'

UPDATE [dbo].[ProductUrl]
    SET [Url] = 'NEW_DS_URL'
    WHERE [Url] = 'OLD_DS_URL'

UPDATE [dbo].[ProductUrl]
    SET [Url] = 'NEW_AI_URL'
    WHERE [Url] = 'OLD_AI_URL'

UPDATE [dbo].[Product]
    SET [LogOutUrl] = 'NEW_AD_URL/server/logout'
    WHERE [LogOutUrl] = 'OLD_AD_URL/server/logout'

UPDATE [dbo].[Product]
    SET [LogOutUrl] = 'NEW_DS_URL/server/logout'
    WHERE [LogOutUrl] = 'OLD_DS_URL/server/logout'

UPDATE [dbo].[Product]
    SET [LogOutUrl] = 'NEW_AI_URL/server/logout'
    WHERE [LogOutUrl] = 'OLD_AI_URL/server/logout'
```

### DS Database

Update AD URL references:

```sql
-- Find records to update
SELECT * FROM [dbo].[Parameter]
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%OLD_AD_URL%'
SELECT * FROM [dbo].[ServerVariables]
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%OLD_AD_URL%'

-- Update records
UPDATE [dbo].[Parameter]
    SET [Value] = 'NEW_AD_URL'
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%OLD_AD_URL%'

UPDATE [dbo].[ServerVariables]
    SET [Value] = 'NEW_AD_URL'
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%OLD_AD_URL%'
```

### AD Database

Update DS URL reference:

```sql
-- Find records to update
SELECT * FROM [dbo].[XMGlobalSetting]
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%OLD_DS_URL%'

-- Update records
UPDATE [dbo].[XMGlobalSetting]
    SET [Value] = 'NEW_DS_URL'
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%OLD_DS_URL%'
```

## Post-Migration: Update Stream Hosts

Stream Hosts deployed outside Terraform must be updated to point to the new DS URL:

```yaml
xmpro:
  gateway:
    serverurl: "https://ds.yourdomain.com"
```

Restart Stream Hosts after updating configuration.

## Verification

1. Log into SM and verify product URLs in admin settings
2. Log into AD and verify DS connection works
3. Log into DS and verify Stream Hosts reconnect
4. Run a test data stream to confirm end-to-end functionality

## Rollback

To rollback, run the database scripts with OLD/NEW URLs swapped.
