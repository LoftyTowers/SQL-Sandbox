SET NOCOUNT ON;
USE [SandboxDb];

SELECT TOP (0)
    so.SalesOrderId,
    so.OrderNumber,
    so.OrderDate
FROM dbo.SalesOrder AS so
WHERE so.CustomerId = 0
ORDER BY so.OrderDate;

SELECT TOP (0)
    sol.SalesOrderLineId,
    sol.LineNumber,
    sol.ItemName,
    sol.Quantity,
    sol.UnitPrice
FROM dbo.SalesOrderLine AS sol
WHERE sol.SalesOrderId = 0
ORDER BY sol.LineNumber;

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes i
    WHERE i.name = N'IX_SalesOrder_Customer_OrderDate'
      AND i.object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND i.type_desc = 'NONCLUSTERED'
)
BEGIN
    THROW 51000, 'Expected index IX_SalesOrder_Customer_OrderDate on dbo.SalesOrder.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND ic.index_id = INDEXPROPERTY(OBJECT_ID(N'dbo.SalesOrder'), 'IX_SalesOrder_Customer_OrderDate', 'IndexId')
      AND ic.key_ordinal = 1
      AND c.name = 'CustomerId'
)
BEGIN
    THROW 51000, 'Expected CustomerId as first key in IX_SalesOrder_Customer_OrderDate.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND ic.index_id = INDEXPROPERTY(OBJECT_ID(N'dbo.SalesOrder'), 'IX_SalesOrder_Customer_OrderDate', 'IndexId')
      AND ic.key_ordinal = 2
      AND c.name = 'OrderDate'
)
BEGIN
    THROW 51000, 'Expected OrderDate as second key in IX_SalesOrder_Customer_OrderDate.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND ic.index_id = INDEXPROPERTY(OBJECT_ID(N'dbo.SalesOrder'), 'IX_SalesOrder_Customer_OrderDate', 'IndexId')
      AND ic.is_included_column = 1
      AND c.name = 'OrderNumber'
)
BEGIN
    THROW 51000, 'Expected OrderNumber as INCLUDE in IX_SalesOrder_Customer_OrderDate.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.indexes i
    WHERE i.name = N'IX_SalesOrderLine_Order_LineNumber'
      AND i.object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND i.type_desc = 'NONCLUSTERED'
)
BEGIN
    THROW 51000, 'Expected index IX_SalesOrderLine_Order_LineNumber on dbo.SalesOrderLine.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND ic.index_id = INDEXPROPERTY(OBJECT_ID(N'dbo.SalesOrderLine'), 'IX_SalesOrderLine_Order_LineNumber', 'IndexId')
      AND ic.key_ordinal = 1
      AND c.name = 'SalesOrderId'
)
BEGIN
    THROW 51000, 'Expected SalesOrderId as first key in IX_SalesOrderLine_Order_LineNumber.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND ic.index_id = INDEXPROPERTY(OBJECT_ID(N'dbo.SalesOrderLine'), 'IX_SalesOrderLine_Order_LineNumber', 'IndexId')
      AND ic.key_ordinal = 2
      AND c.name = 'LineNumber'
)
BEGIN
    THROW 51000, 'Expected LineNumber as second key in IX_SalesOrderLine_Order_LineNumber.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND ic.index_id = INDEXPROPERTY(OBJECT_ID(N'dbo.SalesOrderLine'), 'IX_SalesOrderLine_Order_LineNumber', 'IndexId')
      AND ic.is_included_column = 1
      AND c.name = 'ItemName'
)
BEGIN
    THROW 51000, 'Expected ItemName as INCLUDE in IX_SalesOrderLine_Order_LineNumber.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND ic.index_id = INDEXPROPERTY(OBJECT_ID(N'dbo.SalesOrderLine'), 'IX_SalesOrderLine_Order_LineNumber', 'IndexId')
      AND ic.is_included_column = 1
      AND c.name = 'Quantity'
)
BEGIN
    THROW 51000, 'Expected Quantity as INCLUDE in IX_SalesOrderLine_Order_LineNumber.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.index_columns ic
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE ic.object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND ic.index_id = INDEXPROPERTY(OBJECT_ID(N'dbo.SalesOrderLine'), 'IX_SalesOrderLine_Order_LineNumber', 'IndexId')
      AND ic.is_included_column = 1
      AND c.name = 'UnitPrice'
)
BEGIN
    THROW 51000, 'Expected UnitPrice as INCLUDE in IX_SalesOrderLine_Order_LineNumber.', 1;
END

PRINT 'Verification: query indexes OK';
