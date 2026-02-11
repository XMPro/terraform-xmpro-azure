# URL/DNS Migration Guide

This guide covers the required changes when migrating XMPro product URLs (e.g., changing from `*.azurewebsites.net` to custom domains).

## Overview

When changing URLs for XMPro services, multiple components need updating:
- App Service configurations
- Database records
- Stream Host configurations
- Notebook/JupyterHub configurations (if applicable)
- IIS redirects (optional, for seamless transition)

## Pre-Migration Checklist

### 1. Document Connected Stream Hosts

Query the DS database to identify all connected Stream Hosts before making changes:

```sql
-- Get connected devices
SELECT
    d.timestamp,
    ec.CompanyId,
    ec.Id as CollectionId,
    d.Id as DeviceId,
    d.name as DeviceName
FROM dbo.EdgeContainer ec
INNER JOIN dbo.Device d ON d.EdgeContainerId = ec.id
ORDER BY [Timestamp] DESC

-- Get published streams and their devices
SELECT
    uc.Name,
    uc.DefaultCollectionId,
    ec.CompanyId,
    d.name as DeviceName
FROM dbo.Device d
INNER JOIN dbo.EdgeContainer ec ON ec.id = d.EdgeContainerId
INNER JOIN dbo.UseCase uc ON uc.DefaultCollectionId = ec.Id
INNER JOIN dbo.Stream s ON s.UseCaseId = uc.Id
WHERE s.Published = 1
ORDER BY DeviceName, Name
```

### 2. Stop All Stream Hosts

Stop all Stream Hosts that can be stopped before proceeding.

## Migration Steps

### Step 1: Update App Service Configurations

Update these app settings for each service:

| Service | Settings to Update |
|---------|-------------------|
| AD | `xmpro__xmidentity__client__baseUrl`, `xmpro__xmidentity__client__serverUrl` |
| DS | `xmpro__xmidentity__client__baseUrl`, `xmpro__xmidentity__client__serverUrl` |
| AI | `xmpro__xmidentity__client__baseUrl`, `xmpro__xmidentity__client__serverUrl` |
| SM | `xmpro__xmidentity__client__serverUrl` |

Example values:
```
xmpro__xmidentity__client__baseUrl = https://ad.yourdomain.com
xmpro__xmidentity__client__serverUrl = https://sm.yourdomain.com
```

### Step 2: Update Health Check URLs (Optional)

If using health checks, update the URLs in each app's configuration:

```json
{
  "name": "xmpro__healthChecks__urls__0__url",
  "value": "https://sm.yourdomain.com/health/ping"
},
{
  "name": "xmpro__healthChecks__urls__1__url",
  "value": "https://ds.yourdomain.com/health/ping"
}
```

### Step 3: Add Custom Domains to App Services

For each App Service (AD, DS, SM, AI):

1. Go to **App Service > Settings > Custom domains**
2. Click **Add Custom Domain**
3. Configure:
   - Domain Provider: All Other
   - TLS/SSL certificate: App Service Managed
   - TLS/SSL type: SNI SSL
   - Domain: `ad.yourdomain.com` (etc.)
4. Validate and Add

### Step 4: Update SM Database

Update product URLs in the Subscription Manager database:

```sql
USE [SM]

-- Update ProductUrl table
UPDATE [dbo].[ProductUrl]
    SET [Url] = 'https://ad.yourdomain.com/'
    WHERE [Url] = 'https://old-ad-url.azurewebsites.net/'

UPDATE [dbo].[ProductUrl]
    SET [Url] = 'https://ds.yourdomain.com/'
    WHERE [Url] = 'https://old-ds-url.azurewebsites.net/'

UPDATE [dbo].[ProductUrl]
    SET [Url] = 'https://ai.yourdomain.com/'
    WHERE [Url] = 'https://old-ai-url.azurewebsites.net/'

-- Update Product logout URLs
UPDATE [dbo].[Product]
    SET [LogOutUrl] = 'https://ad.yourdomain.com/server/logout'
    WHERE [LogOutUrl] = 'https://old-ad-url.azurewebsites.net/server/logout'

UPDATE [dbo].[Product]
    SET [LogOutUrl] = 'https://ds.yourdomain.com/server/logout'
    WHERE [LogOutUrl] = 'https://old-ds-url.azurewebsites.net/server/logout'

UPDATE [dbo].[Product]
    SET [LogOutUrl] = 'https://ai.yourdomain.com/server/logout'
    WHERE [LogOutUrl] = 'https://old-ai-url.azurewebsites.net/server/logout'
```

### Step 5: Update DS Database

Update any parameters referencing AD URLs:

```sql
USE [DS]  -- or your DS database name

-- Check existing values
SELECT * FROM [dbo].[Parameter]
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%old-ad-url%'
SELECT * FROM [dbo].[ServerVariables]
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%old-ad-url%'

-- Update Parameter table
UPDATE [dbo].[Parameter]
    SET [Value] = 'https://ad.yourdomain.com/'
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%old-ad-url%'

-- Update ServerVariables table
UPDATE [dbo].[ServerVariables]
    SET [Value] = 'https://ad.yourdomain.com/'
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%old-ad-url%'
```

### Step 6: Update AD Database

Update DS URL references in App Designer:

```sql
USE [AD]  -- or your AD database name

-- Check existing values
SELECT * FROM [dbo].[XMGlobalSetting]
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%old-ds-url%'

-- Update settings
UPDATE [dbo].[XMGlobalSetting]
    SET [Value] = 'https://ds.yourdomain.com'
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE '%old-ds-url%'
```

### Step 7: Update Stream Host Configurations

Update each Stream Host's configuration to point to the new DS URL:

```yaml
xmpro:
  gateway:
    serverurl: "https://ds.yourdomain.com"
```

Restart all Stream Hosts after updating.

### Step 8: Configure Redirects (Optional)

Add IIS redirects on old App Services to redirect to new URLs:

```xml
<configuration>
  <system.webServer>
    <rewrite>
      <rules>
        <rule name="Redirect to new domain" stopProcessing="true">
          <match url="(.*)" />
          <conditions logicalGrouping="MatchAny">
            <add input="{HTTP_HOST}" pattern="^old-site\.azurewebsites\.net$" />
          </conditions>
          <action type="Redirect" redirectType="Found" url="https://new-site.yourdomain.com/{R:0}" />
        </rule>
      </rules>
    </rewrite>
  </system.webServer>
</configuration>
```

### Step 9: Update Notebook/JupyterHub (If Applicable)

Update Helm values for JupyterHub:

```yaml
hub:
  config:
    GenericOAuthenticator:
      authorize_url: https://sm.yourdomain.com/identity/connect/authorize
      token_url: https://sm.yourdomain.com/identity/connect/token
      userdata_url: https://sm.yourdomain.com/identity/connect/userinfo
  extraConfig:
    hub: |
      c.JupyterHub.tornado_settings = {
        "headers": {
          "Content-Security-Policy": "frame-ancestors https://ai.yourdomain.com"
        },
        "cookie_options": {"SameSite": "None", "Secure": True}
      }
```

## Post-Migration Verification

### Smoke Tests

1. **SM**: Log in at `https://sm.yourdomain.com`, browse subscriptions
2. **AD**: Log in at `https://ad.yourdomain.com`, browse apps, recommendations
3. **DS**: Log in at `https://ds.yourdomain.com`, browse datastreams, verify Stream Hosts online
4. **AI**: Log in at `https://ai.yourdomain.com`, test chat and notebooks

### Verify Stream Hosts

Re-run the Stream Host query from pre-migration to confirm all hosts reconnected.

### Test Redirects

If configured, verify old URLs redirect to new URLs properly.

## Rollback Procedure

If issues occur, reverse the steps:

1. Remove IIS redirects from old sites
2. Restore app settings to previous URLs
3. Run reverse database scripts (swap old/new URLs)
4. Restore Stream Host configurations
5. Restart all services

## Terraform Considerations

When using this Terraform module with existing databases:

1. The `use_existing_database = true` flag skips SQL Server/database creation
2. Database name variables (`sm_database_name`, `ad_database_name`, etc.) must match existing databases
3. Connection strings are built using `existing_sql_server_fqdn`
4. Product IDs must be provided via `existing_*_product_id` variables

The database migration scripts above are **not** automated by Terraform and must be run manually when changing URLs.
