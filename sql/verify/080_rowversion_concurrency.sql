SET NOCOUNT ON;
USE [SandboxDb];
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF COL_LENGTH(N'dbo.SalesOrder', N'RowVersion') IS NULL
BEGIN
    ;THROW 51000, 'Expected dbo.SalesOrder.RowVersion to exist.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.columns
    WHERE object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND name = N'RowVersion'
      AND system_type_id = 189
)
BEGIN
    ;THROW 51000, 'Expected dbo.SalesOrder.RowVersion to be rowversion.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.procedures
    WHERE name = N'usp_UpdateSalesOrderNumber'
      AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    ;THROW 51000, 'Expected stored procedure dbo.usp_UpdateSalesOrderNumber to exist.', 1;
END

BEGIN TRANSACTION;

DECLARE @CustomerId INT;
DECLARE @SalesOrderId INT;
DECLARE @RowVersion VARBINARY(8);
DECLARE @NewRowVersion VARBINARY(8);

BEGIN TRY
    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'T08 Customer', N't08-rowversion@example.test');

    SET @CustomerId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrder (CustomerId, OrderNumber, OrderDate)
    VALUES (@CustomerId, N'T08-001', CAST('2026-01-10T00:00:00' AS DATETIME2(0)));

    SET @SalesOrderId = CONVERT(INT, SCOPE_IDENTITY());

    SELECT @RowVersion = RowVersion
    FROM dbo.SalesOrder
    WHERE SalesOrderId = @SalesOrderId;

    EXEC dbo.usp_UpdateSalesOrderNumber
        @SalesOrderId = @SalesOrderId,
        @OrderNumber = N'T08-002',
        @ExpectedRowVersion = @RowVersion;

    SELECT @NewRowVersion = RowVersion
    FROM dbo.SalesOrder
    WHERE SalesOrderId = @SalesOrderId;

    IF @NewRowVersion = @RowVersion
    BEGIN
        ;THROW 51000, 'Expected rowversion to change after update.', 1;
    END

    BEGIN TRY
        EXEC dbo.usp_UpdateSalesOrderNumber
            @SalesOrderId = @SalesOrderId,
            @OrderNumber = N'T08-STALE',
            @ExpectedRowVersion = @RowVersion;

        THROW 51000, 'Expected stale rowversion update to fail.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (51000)
        BEGIN
            IF XACT_STATE() <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END
            ;THROW;
        END
    END CATCH

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    ;THROW;
END CATCH

PRINT 'Verification: rowversion concurrency OK';
