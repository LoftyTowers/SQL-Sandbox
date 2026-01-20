SET NOCOUNT ON;
USE [SandboxDb];

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_SalesOrder_Customer'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND referenced_object_id = OBJECT_ID(N'dbo.Customer')
      AND is_not_trusted = 0
      AND is_disabled = 0
      AND delete_referential_action_desc = 'NO_ACTION'
      AND update_referential_action_desc = 'NO_ACTION'
)
BEGIN
    THROW 51000, 'Expected trusted, enabled FK_SalesOrder_Customer with NO ACTION to dbo.Customer.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_SalesOrderLine_SalesOrder'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND referenced_object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND is_not_trusted = 0
      AND is_disabled = 0
      AND delete_referential_action_desc = 'NO_ACTION'
      AND update_referential_action_desc = 'NO_ACTION'
)
BEGIN
    THROW 51000, 'Expected trusted, enabled FK_SalesOrderLine_SalesOrder with NO ACTION to dbo.SalesOrder.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_key_columns fkc
    JOIN sys.columns pc
        ON fkc.parent_object_id = pc.object_id
       AND fkc.parent_column_id = pc.column_id
    JOIN sys.columns rc
        ON fkc.referenced_object_id = rc.object_id
       AND fkc.referenced_column_id = rc.column_id
    WHERE fkc.constraint_object_id = OBJECT_ID(N'FK_SalesOrder_Customer')
      AND pc.name = 'CustomerId'
      AND rc.name = 'CustomerId'
)
BEGIN
    THROW 51000, 'Expected FK_SalesOrder_Customer to reference dbo.Customer(CustomerId).', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_key_columns fkc
    JOIN sys.columns pc
        ON fkc.parent_object_id = pc.object_id
       AND fkc.parent_column_id = pc.column_id
    JOIN sys.columns rc
        ON fkc.referenced_object_id = rc.object_id
       AND fkc.referenced_column_id = rc.column_id
    WHERE fkc.constraint_object_id = OBJECT_ID(N'FK_SalesOrderLine_SalesOrder')
      AND pc.name = 'SalesOrderId'
      AND rc.name = 'SalesOrderId'
)
BEGIN
    THROW 51000, 'Expected FK_SalesOrderLine_SalesOrder to reference dbo.SalesOrder(SalesOrderId).', 1;
END

PRINT 'Verification: foreign keys OK';
