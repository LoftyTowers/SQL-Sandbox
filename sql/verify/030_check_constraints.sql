SET NOCOUNT ON;
USE [SandboxDb];

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SalesOrderLine_Quantity_Positive'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND is_disabled = 0
      AND is_not_trusted = 0
)
BEGIN
    THROW 51000, 'Expected trusted, enabled CK_SalesOrderLine_Quantity_Positive.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SalesOrderLine_UnitPrice_NonNegative'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND is_disabled = 0
      AND is_not_trusted = 0
)
BEGIN
    THROW 51000, 'Expected trusted, enabled CK_SalesOrderLine_UnitPrice_NonNegative.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SalesOrder_OrderNumber_NotBlank'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND is_disabled = 0
      AND is_not_trusted = 0
)
BEGIN
    THROW 51000, 'Expected trusted, enabled CK_SalesOrder_OrderNumber_NotBlank.', 1;
END

BEGIN TRANSACTION;

DECLARE @CustomerId INT;
DECLARE @SalesOrderId INT;

BEGIN TRY
    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'Check Constraint Customer', N'check@example.test');

    SET @CustomerId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrder (CustomerId, OrderNumber, OrderDate)
    VALUES (@CustomerId, N'CHK-VALID-ORDER', SYSUTCDATETIME());

    SET @SalesOrderId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrderLine (SalesOrderId, LineNumber, ItemName, Quantity, UnitPrice)
    VALUES (@SalesOrderId, 1, N'Valid Item', 1, 1.00);
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    THROW 51000, 'Expected valid inserts to succeed under CHECK constraints.', 1;
END CATCH

BEGIN TRY
    INSERT INTO dbo.SalesOrderLine (SalesOrderId, LineNumber, ItemName, Quantity, UnitPrice)
    VALUES (@SalesOrderId, 2, N'Invalid Quantity', 0, 1.00);
    THROW 51000, 'Expected CHECK constraint to reject Quantity <= 0.', 1;
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

BEGIN TRY
    INSERT INTO dbo.SalesOrderLine (SalesOrderId, LineNumber, ItemName, Quantity, UnitPrice)
    VALUES (@SalesOrderId, 3, N'Invalid Price', 1, -1.00);
    THROW 51000, 'Expected CHECK constraint to reject UnitPrice < 0.', 1;
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

BEGIN TRY
    INSERT INTO dbo.SalesOrder (CustomerId, OrderNumber, OrderDate)
    VALUES (@CustomerId, N'   ', SYSUTCDATETIME());
    THROW 51000, 'Expected CHECK constraint to reject blank OrderNumber.', 1;
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

ROLLBACK TRANSACTION;

PRINT 'Verification: check constraints OK';
