SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
USE [SandboxDb]
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'UX_Customer_Email'
      AND object_id = OBJECT_ID(N'dbo.Customer')
)
BEGIN
    CREATE UNIQUE INDEX UX_Customer_Email
        ON dbo.Customer (Email)
        WHERE Email IS NOT NULL;
END
