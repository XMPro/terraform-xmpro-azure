SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

--
-- DS Database: Update known XMPro-related URL references only.
-- Variable: $(AD_URL) - target AD URL (without trailing slash)
--
-- IMPORTANT: Only update ServerVariables whose name clearly references
-- the App Designer URL. Do NOT blindly replace all https:// URLs,
-- as the DS database stores many third-party service URLs (GitHub,
-- Azure Digital Twins, OpenAI, InfluxDB, etc.) in both Parameter
-- and ServerVariables tables.
--

DECLARE @target VARCHAR(500) = '$(AD_URL)/';
DECLARE @target_noslash VARCHAR(500) = '$(AD_URL)';

BEGIN TRAN;

-- Update only ServerVariables whose NAME indicates an AD/App Designer URL.
-- Common patterns: 'ADUrl', 'AD_URL', 'App Designer URL', 'AD URL', etc.
DECLARE @company_id BIGINT, @var_name VARCHAR(200), @var_val VARCHAR(500);

DECLARE sv_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT CompanyId, VariableName, CONVERT(VARCHAR(500), [Value]) AS Val
    FROM [dbo].[ServerVariables]
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE 'https://%'
    AND CONVERT(VARCHAR(500), [Value]) <> @target
    AND CONVERT(VARCHAR(500), [Value]) <> @target_noslash
    AND (
        VariableName LIKE '%AD%URL%'
        OR VariableName LIKE '%AD%Url%'
        OR VariableName LIKE '%App Designer%'
        OR VariableName LIKE '%AppDesigner%'
        OR VariableName LIKE '%ADUrl%'
    );

OPEN sv_cursor;
FETCH NEXT FROM sv_cursor INTO @company_id, @var_name, @var_val;

IF @@FETCH_STATUS <> 0
    PRINT 'OK: DS ServerVariables already correct (no AD URL variables to update)';

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE [dbo].[ServerVariables] SET [Value] = @target
    WHERE CompanyId = @company_id AND VariableName = @var_name;
    PRINT 'UPDATED DS ServerVariables (' + CAST(@company_id AS VARCHAR(20)) + ', ' + @var_name + '): ' + @var_val + ' -> ' + @target;

    FETCH NEXT FROM sv_cursor INTO @company_id, @var_name, @var_val;
END

CLOSE sv_cursor;
DEALLOCATE sv_cursor;

-- NOTE: We intentionally do NOT update Parameter values in the DS database.
-- Parameter values contain agent-specific configuration URLs (GitHub repos,
-- Azure DT endpoints, OpenAI endpoints, etc.) that must not be changed.
-- Only the ServerVariables AD URL entries are safe to update.
PRINT 'OK: DS Parameter values intentionally not modified (contain agent-specific URLs)';

COMMIT TRAN;
