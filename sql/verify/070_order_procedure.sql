SET NOCOUNT ON;
USE [SandboxDb];

IF NOT EXISTS
(
    SELECT 1
    FROM sys.procedures
    WHERE name = N'usp_CreateOrder'
      AND schema_id = SCHEMA_ID(N'dbo')
)
BEGIN
    THROW 51000, 'Expected stored procedure dbo.usp_CreateOrder to exist.', 1;
END

BEGIN TRANSACTION;

DECLARE @CustomerId INT;
DECLARE @SalesOrderId INT;

BEGIN TRY
    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'T07 Customer', N't07-proc@example.test');

    SET @CustomerId = CONVERT(INT, SCOPE_IDENTITY());

    EXEC dbo.usp_CreateOrder
        @CustomerId = @CustomerId,
        @OrderNumber = N'T07-OK',
        @OrderDate = CAST('2026-01-05T00:00:00' AS DATETIME2(0)),
        @LineNumber = 1,
        @ItemName = N'Procedure Item',
        @Quantity = 1,
        @UnitPrice = 9.99;

    IF @@TRANCOUNT <> 1 OR XACT_STATE() <> 1
    BEGIN
        THROW 51000, 'Expected outer transaction to remain active after successful procedure call.', 1;
    END

    SELECT @SalesOrderId = SalesOrderId
    FROM dbo.SalesOrder
    WHERE OrderNumber = N'T07-OK'
      AND CustomerId = @CustomerId;

    IF @SalesOrderId IS NULL
    BEGIN
        THROW 51000, 'Expected SalesOrder to be created by usp_CreateOrder.', 1;
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM dbo.SalesOrderLine
        WHERE SalesOrderId = @SalesOrderId
          AND LineNumber = 1
    )
    BEGIN
        THROW 51000, 'Expected SalesOrderLine to be created by usp_CreateOrder.', 1;
    END

    BEGIN TRY
        EXEC dbo.usp_CreateOrder
            @CustomerId = @CustomerId,
            @OrderNumber = N'T07-FAIL',
            @OrderDate = CAST('2026-01-06T00:00:00' AS DATETIME2(0)),
            @LineNumber = 1,
            @ItemName = N'Invalid Item',
            @Quantity = 0,
            @UnitPrice = 5.00;

        THROW 51000, 'Expected usp_CreateOrder to fail for invalid Quantity.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() NOT IN (547, 51000)
        BEGIN
            IF XACT_STATE() <> 0
            BEGIN
                ROLLBACK TRANSACTION;
            END
            THROW;
        END
    END CATCH

    IF @@TRANCOUNT <> 1 OR XACT_STATE() <> 1
    BEGIN
        THROW 51000, 'Expected outer transaction to remain active after failed procedure call.', 1;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.SalesOrder
        WHERE OrderNumber = N'T07-FAIL'
          AND CustomerId = @CustomerId
    )
    BEGIN
        THROW 51000, 'Expected no SalesOrder row for failed procedure call.', 1;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.SalesOrderLine AS sol
        JOIN dbo.SalesOrder AS so
            ON sol.SalesOrderId = so.SalesOrderId
        WHERE so.OrderNumber = N'T07-FAIL'
          AND so.CustomerId = @CustomerId
    )
    BEGIN
        THROW 51000, 'Expected no SalesOrderLine rows for failed procedure call.', 1;
    END

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    THROW;
END CATCH

PRINT 'Verification: order procedure OK';
