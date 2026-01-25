SET NOCOUNT ON;
USE [SandboxDb];
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO

IF OBJECT_ID(N'dbo.v_OrderSummary', N'V') IS NULL
BEGIN
    ;THROW 51000, 'Expected view dbo.v_OrderSummary to exist.', 1;
END

IF EXISTS
(
    SELECT 1
    FROM sys.objects
    WHERE type = 'TR'
      AND is_ms_shipped = 0
)
BEGIN
    ;THROW 51000, 'Expected no user triggers to exist.', 1;
END

BEGIN TRANSACTION;

DECLARE @CustomerId INT;
DECLARE @SalesOrderId INT;

BEGIN TRY
    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'T09 Customer', N't09-view@example.test');

    SET @CustomerId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrder (CustomerId, OrderNumber, OrderDate)
    VALUES (@CustomerId, N'T09-001', CAST('2026-01-12T00:00:00' AS DATETIME2(0)));

    SET @SalesOrderId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrderLine (SalesOrderId, LineNumber, ItemName, Quantity, UnitPrice)
    VALUES
        (@SalesOrderId, 1, N'Item A', 2, 5.00),
        (@SalesOrderId, 2, N'Item B', 1, 3.50);

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.v_OrderSummary
        WHERE SalesOrderId = @SalesOrderId
          AND CustomerId = @CustomerId
          AND OrderNumber = N'T09-001'
          AND TotalQuantity = 3
          AND TotalAmount = 13.50
    )
    BEGIN
        ;THROW 51000, 'Expected v_OrderSummary to return correct totals.', 1;
    END

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    ;THROW;
END CATCH

PRINT 'Verification: order summary view OK';
