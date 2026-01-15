SET NOCOUNT ON;

IF DB_ID(N'SandboxDb') IS NULL
BEGIN
    THROW 51000, 'Database SandboxDb does not exist.', 1;
END

USE [SandboxDb];

IF OBJECT_ID(N'dbo.Sample', N'U') IS NULL
BEGIN
    THROW 51000, 'Expected table dbo.Sample to exist.', 1;
END

IF NOT EXISTS (SELECT 1 FROM dbo.Sample WHERE Name = N'bootstrap')
BEGIN
    THROW 51000, 'Expected bootstrap row in dbo.Sample.', 1;
END

PRINT 'Verification: OK';
