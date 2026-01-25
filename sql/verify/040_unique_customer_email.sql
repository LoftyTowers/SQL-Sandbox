SET NOCOUNT ON;
USE [SandboxDb];
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes i
    WHERE i.name = N'UX_Customer_Email'
      AND i.object_id = OBJECT_ID(N'dbo.Customer')
      AND i.is_unique = 1
      AND i.has_filter = 1
      AND REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(i.filter_definition, CHAR(13), ''), CHAR(10), ''), ' ', ''), '[', ''), ']', '')
          LIKE '%EmailISNOTNULL%'
)
BEGIN
    ;THROW 51000, 'Expected filtered unique index UX_Customer_Email on dbo.Customer(Email).', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes i
    JOIN sys.index_columns ic
        ON i.object_id = ic.object_id
       AND i.index_id = ic.index_id
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE i.name = N'UX_Customer_Email'
      AND i.object_id = OBJECT_ID(N'dbo.Customer')
      AND ic.key_ordinal = 1
      AND c.name = 'Email'
)
BEGIN
    ;THROW 51000, 'Expected UX_Customer_Email to use dbo.Customer.Email as key.', 1;
END

BEGIN TRANSACTION;

BEGIN TRY
    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'Unique Customer A', N'unique@example.test');

    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'Unique Customer B', N'unique@example.test');

    ;THROW 51000, 'Expected duplicate Email insert to fail.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() NOT IN (2601, 2627, 51000)
    BEGIN
        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END
        ;THROW;
    END
END CATCH

BEGIN TRY
    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'Unique Customer C', NULL);

    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'Unique Customer D', NULL);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    ;THROW 51000, 'Expected NULL Email inserts to succeed under filtered unique index.', 1;
END CATCH

ROLLBACK TRANSACTION;

PRINT 'Verification: unique email OK';
