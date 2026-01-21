SET NOCOUNT ON;
USE [SandboxDb];

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
)
BEGIN
    ADD SENSITIVITY CLASSIFICATION TO dbo.Customer.Email
        WITH (LABEL = 'Confidential', INFORMATION_TYPE = 'Email Address');
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
)
BEGIN
    ADD SENSITIVITY CLASSIFICATION TO dbo.Customer.CustomerName
        WITH (LABEL = 'Confidential', INFORMATION_TYPE = 'Name');
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'app_reader'
      AND type = 'R'
)
BEGIN
    CREATE ROLE app_reader;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.database_principals
    WHERE name = N'app_reader_user'
      AND type = 'S'
)
BEGIN
    CREATE USER app_reader_user WITHOUT LOGIN;
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
    ALTER ROLE app_reader ADD MEMBER app_reader_user;
END

IF OBJECT_ID(N'dbo.v_OrderSummary', N'V') IS NOT NULL
   AND NOT EXISTS
(
    SELECT 1
    FROM sys.database_permissions p
    WHERE p.grantee_principal_id = DATABASE_PRINCIPAL_ID(N'app_reader')
      AND p.class = 1
      AND p.major_id = OBJECT_ID(N'dbo.v_OrderSummary')
      AND p.minor_id = 0
      AND p.permission_name = 'SELECT'
)
BEGIN
    GRANT SELECT ON dbo.v_OrderSummary TO app_reader;
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
    DENY SELECT ON dbo.Customer TO app_reader;
END
