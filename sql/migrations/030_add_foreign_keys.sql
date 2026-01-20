SET NOCOUNT ON;
USE [SandboxDb];

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_SalesOrder_Customer'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrder')
)
BEGIN
    ALTER TABLE dbo.SalesOrder WITH CHECK
        ADD CONSTRAINT FK_SalesOrder_Customer
            FOREIGN KEY (CustomerId)
            REFERENCES dbo.Customer(CustomerId)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION;
    ALTER TABLE dbo.SalesOrder CHECK CONSTRAINT FK_SalesOrder_Customer;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_SalesOrderLine_SalesOrder'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrderLine')
)
BEGIN
    ALTER TABLE dbo.SalesOrderLine WITH CHECK
        ADD CONSTRAINT FK_SalesOrderLine_SalesOrder
            FOREIGN KEY (SalesOrderId)
            REFERENCES dbo.SalesOrder(SalesOrderId)
            ON UPDATE NO ACTION
            ON DELETE NO ACTION;
    ALTER TABLE dbo.SalesOrderLine CHECK CONSTRAINT FK_SalesOrderLine_SalesOrder;
END
