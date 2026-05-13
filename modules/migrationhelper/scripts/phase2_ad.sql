SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

--
-- AD Database: Update XMGlobalSetting URL values
-- Variable: $(DS_URL) - target DS URL (without trailing slash)
--

DECLARE @target VARCHAR(500) = '$(DS_URL)/';
DECLARE @target_noslash VARCHAR(500) = '$(DS_URL)';

BEGIN TRAN;

DECLARE @setting_id INT, @setting_val VARCHAR(500);

DECLARE setting_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT SettingId, CONVERT(VARCHAR(500), [Value]) AS Val
    FROM [dbo].[XMGlobalSetting]
    WHERE CONVERT(VARCHAR(500), [Value]) LIKE 'https://%'
    AND CONVERT(VARCHAR(500), [Value]) <> @target
    AND CONVERT(VARCHAR(500), [Value]) <> @target_noslash;

OPEN setting_cursor;
FETCH NEXT FROM setting_cursor INTO @setting_id, @setting_val;

IF @@FETCH_STATUS <> 0
    PRINT 'OK: AD XMGlobalSetting already correct';

WHILE @@FETCH_STATUS = 0
BEGIN
    UPDATE [dbo].[XMGlobalSetting] SET [Value] = @target WHERE SettingId = @setting_id;
    PRINT 'UPDATED AD XMGlobalSetting id=' + CAST(@setting_id AS VARCHAR) + ': ' + @setting_val + ' -> ' + @target;

    FETCH NEXT FROM setting_cursor INTO @setting_id, @setting_val;
END

CLOSE setting_cursor;
DEALLOCATE setting_cursor;

COMMIT TRAN;
