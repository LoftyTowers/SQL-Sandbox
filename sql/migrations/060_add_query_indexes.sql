SET NOCOUNT ON;
USE [SandboxDb];

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_SalesOrder_Customer_OrderDate'
      AND object_id = OBJECT_ID(N'dbo.SalesOrder')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_SalesOrder_Customer_OrderDate
        ON dbo.SalesOrder (CustomerId, OrderDate)
        INCLUDE (OrderNumber);
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_SalesOrderLine_Order_LineNumber'
      AND object_id = OBJECT_ID(N'dbo.SalesOrderLine')
)
BEGIN
    CREATE NONCLUSTERED INDEX IX_SalesOrderLine_Order_LineNumber
        ON dbo.SalesOrderLine (SalesOrderId, LineNumber)
        INCLUDE (ItemName, Quantity, UnitPrice);
END
