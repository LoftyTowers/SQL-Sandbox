SET NOCOUNT ON;
USE [SandboxDb];
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.sensitivity_classifications sc
    JOIN sys.columns c
        ON sc.major_id = c.object_id
       AND sc.minor_id = c.column_id
    JOIN sys.tables t
        ON c.object_id = t.object_id
    JOIN sys.schemas s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
      AND t.name = 'Customer'
      AND c.name = 'Email'
      AND sc.label = 'Confidential'
      AND sc.information_type = 'Email Address'
)
BEGIN
    ;THROW 51000, 'Expected classification on dbo.Customer.Email.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.sensitivity_classifications sc
    JOIN sys.columns c
        ON sc.major_id = c.object_id
       AND sc.minor_id = c.column_id
    JOIN sys.tables t
        ON c.object_id = t.object_id
    JOIN sys.schemas s
        ON t.schema_id = s.schema_id
    WHERE s.name = 'dbo'
      AND t.name = 'Customer'
      AND c.name = 'CustomerName'
      AND sc.label = 'Confidential'
      AND sc.information_type = 'Name'
)
BEGIN
    ;THROW 51000, 'Expected classification on dbo.Customer.CustomerName.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'app_reader'
      AND type = 'R'
)
BEGIN
    ;THROW 51000, 'Expected database role app_reader to exist.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'app_reader_user'
      AND type = 'S'
)
BEGIN
    ;THROW 51000, 'Expected database user app_reader_user to exist.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_role_members drm
    JOIN sys.database_principals r
        ON drm.role_principal_id = r.principal_id
    JOIN sys.database_principals m
        ON drm.member_principal_id = m.principal_id
    WHERE r.name = N'app_reader'
      AND m.name = N'app_reader_user'
)
BEGIN
    ;THROW 51000, 'Expected app_reader_user to be a member of app_reader.', 1;
END

IF OBJECT_ID(N'dbo.v_OrderSummary', N'V') IS NULL
BEGIN
    ;THROW 51000, 'Expected view dbo.v_OrderSummary to exist.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_permissions p
    WHERE p.grantee_principal_id = DATABASE_PRINCIPAL_ID(N'app_reader')
      AND p.class = 1
      AND p.major_id = OBJECT_ID(N'dbo.v_OrderSummary')
      AND p.minor_id = 0
      AND p.permission_name = 'SELECT'
      AND p.state_desc = 'GRANT'
)
BEGIN
    ;THROW 51000, 'Expected SELECT on dbo.v_OrderSummary granted to app_reader.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_permissions p
    WHERE p.grantee_principal_id = DATABASE_PRINCIPAL_ID(N'app_reader')
      AND p.class = 1
      AND p.major_id = OBJECT_ID(N'dbo.Customer')
      AND p.minor_id = 0
      AND p.permission_name = 'SELECT'
      AND p.state_desc = 'DENY'
)
BEGIN
    ;THROW 51000, 'Expected SELECT on dbo.Customer denied to app_reader.', 1;
END

EXECUTE AS USER = N'app_reader_user';

BEGIN TRY
    SELECT TOP (1) SalesOrderId
    FROM dbo.v_OrderSummary;
END TRY
BEGIN CATCH
    REVERT;
    ;THROW 51000, 'Expected app_reader_user to SELECT from dbo.v_OrderSummary.', 1;
END CATCH

BEGIN TRY
    SELECT TOP (1) Email
    FROM dbo.Customer;
    REVERT;
    ;THROW 51000, 'Expected app_reader_user to be denied SELECT on dbo.Customer.', 1;
END TRY
BEGIN CATCH
    DECLARE @Err INT = ERROR_NUMBER();
    REVERT;
    IF @Err NOT IN (229, 51000)
    BEGIN
        ;THROW;
    END
END CATCH

PRINT 'Verification: least privilege and PII handling OK';
