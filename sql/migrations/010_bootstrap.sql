SET NOCOUNT ON;
USE [SandboxDb];

IF OBJECT_ID(N'dbo.Sample', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Sample
    (
        SampleId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Sample PRIMARY KEY,
        Name NVARCHAR(100) NOT NULL,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Sample_CreatedAt DEFAULT (SYSUTCDATETIME())
    );
END

IF NOT EXISTS (SELECT 1 FROM dbo.Sample WHERE Name = N'bootstrap')
BEGIN
    INSERT INTO dbo.Sample (Name) VALUES (N'bootstrap');
END
