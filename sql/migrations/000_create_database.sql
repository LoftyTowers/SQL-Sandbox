SET NOCOUNT ON;

IF DB_ID(N'SandboxDb') IS NULL
BEGIN
    PRINT 'Creating database SandboxDb';
    CREATE DATABASE [SandboxDb];
END
ELSE
BEGIN
    PRINT 'Database SandboxDb already exists';
END
