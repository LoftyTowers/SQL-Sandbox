SET NOCOUNT ON;
USE [SandboxDb];

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SalesOrderLine_Quantity_Positive'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrderLine')
)
BEGIN
    ALTER TABLE dbo.SalesOrderLine WITH CHECK
        ADD CONSTRAINT CK_SalesOrderLine_Quantity_Positive
            CHECK (Quantity > 0);
    ALTER TABLE dbo.SalesOrderLine CHECK CONSTRAINT CK_SalesOrderLine_Quantity_Positive;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SalesOrderLine_UnitPrice_NonNegative'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrderLine')
)
BEGIN
    ALTER TABLE dbo.SalesOrderLine WITH CHECK
        ADD CONSTRAINT CK_SalesOrderLine_UnitPrice_NonNegative
            CHECK (UnitPrice >= 0);
    ALTER TABLE dbo.SalesOrderLine CHECK CONSTRAINT CK_SalesOrderLine_UnitPrice_NonNegative;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.check_constraints
    WHERE name = N'CK_SalesOrder_OrderNumber_NotBlank'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrder')
)
BEGIN
    ALTER TABLE dbo.SalesOrder WITH CHECK
        ADD CONSTRAINT CK_SalesOrder_OrderNumber_NotBlank
            CHECK (LTRIM(RTRIM(OrderNumber)) <> N'');
    ALTER TABLE dbo.SalesOrder CHECK CONSTRAINT CK_SalesOrder_OrderNumber_NotBlank;
END
