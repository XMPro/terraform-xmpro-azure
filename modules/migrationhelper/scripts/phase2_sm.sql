SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

--
-- SM Database: Update ProductUrl and Product.LogOutURL
-- Variables: $(AD_URL), $(DS_URL), $(AI_URL)
--

BEGIN TRAN;

DECLARE @products TABLE (
    Name VARCHAR(50),
    TargetUrl VARCHAR(500)
);

INSERT INTO @products VALUES
    ('App Designer', '$(AD_URL)'),
    ('Data Stream Designer', '$(DS_URL)'),
    ('AI', '$(AI_URL)');

DECLARE @name VARCHAR(50), @target VARCHAR(500);
DECLARE @product_id UNIQUEIDENTIFIER;
DECLARE @url_id INT, @current_url VARCHAR(500), @current_logout VARCHAR(500);
DECLARE @target_logout VARCHAR(500);

DECLARE product_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT Name, TargetUrl FROM @products;

OPEN product_cursor;
FETCH NEXT FROM product_cursor INTO @name, @target;

WHILE @@FETCH_STATUS = 0
BEGIN
    -- Reset all variables to avoid stale values when a product is not found
    SET @product_id = NULL;
    SET @url_id = NULL;
    SET @current_url = NULL;
    SET @current_logout = NULL;

    SELECT @product_id = Id FROM [dbo].[Product] WHERE Name = @name;

    IF @product_id IS NULL
    BEGIN
        PRINT 'SKIP: Product ''' + @name + ''' not found';
    END
    ELSE IF @target = '' OR @target = '__NONE__'
    BEGIN
        -- No target URL provided, just report current values
        SELECT @current_url = Url
        FROM [dbo].[ProductUrl]
        WHERE ProductId = @product_id AND Base = 1;

        PRINT 'OK: ProductUrl for ' + @name + ' = ' + ISNULL(@current_url, '(empty)') + ' (no target provided)';

        SELECT @current_logout = LogOutURL FROM [dbo].[Product] WHERE Id = @product_id;
        PRINT 'OK: LogOutURL for ' + @name + ' = ' + ISNULL(@current_logout, '(empty)') + ' (no target provided)';
    END
    ELSE
    BEGIN
        -- Update ProductUrl (Base = 1)
        SELECT @url_id = Id, @current_url = Url
        FROM [dbo].[ProductUrl]
        WHERE ProductId = @product_id AND Base = 1;

        IF @url_id IS NOT NULL
        BEGIN
            -- Strip trailing slash from current value for comparison
            SET @current_url = CASE
                WHEN RIGHT(RTRIM(@current_url), 1) = '/'
                THEN LEFT(RTRIM(@current_url), LEN(RTRIM(@current_url)) - 1)
                ELSE RTRIM(@current_url)
            END;

            IF @current_url <> @target
            BEGIN
                UPDATE [dbo].[ProductUrl] SET Url = @target WHERE Id = @url_id;
                PRINT 'UPDATED ProductUrl for ' + @name + ': ' + @current_url + ' -> ' + @target;
            END
            ELSE
                PRINT 'OK: ProductUrl for ' + @name + ' already correct (' + @current_url + ')';
        END
        ELSE
        BEGIN
            INSERT INTO [dbo].[ProductUrl] (Url, ProductId, Base) VALUES (@target, @product_id, 1);
            PRINT 'INSERTED ProductUrl for ' + @name + ': ' + @target;
        END

        -- Update LogOutURL
        SELECT @current_logout = LogOutURL FROM [dbo].[Product] WHERE Id = @product_id;
        SET @target_logout = @target + '/server/logout';

        IF ISNULL(@current_logout, '') <> @target_logout
        BEGIN
            UPDATE [dbo].[Product] SET LogOutURL = @target_logout WHERE Id = @product_id;
            PRINT 'UPDATED LogOutURL for ' + @name + ': ' + ISNULL(@current_logout, '(null)') + ' -> ' + @target_logout;
        END
        ELSE
            PRINT 'OK: LogOutURL for ' + @name + ' already correct (' + @current_logout + ')';
    END

    FETCH NEXT FROM product_cursor INTO @name, @target;
END

CLOSE product_cursor;
DEALLOCATE product_cursor;

COMMIT TRAN;
