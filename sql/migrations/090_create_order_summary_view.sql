SET NOCOUNT ON;
USE [SandboxDb];

IF OBJECT_ID(N'dbo.v_OrderSummary', N'V') IS NULL
BEGIN
    EXEC ('CREATE VIEW dbo.v_OrderSummary AS SELECT 1 AS Placeholder;');
END

ALTER VIEW dbo.v_OrderSummary
AS
    SELECT
        so.SalesOrderId,
        so.CustomerId,
        so.OrderNumber,
        so.OrderDate,
        SUM(sol.Quantity) AS TotalQuantity,
        SUM(sol.Quantity * sol.UnitPrice) AS TotalAmount
    FROM dbo.SalesOrder AS so
    JOIN dbo.SalesOrderLine AS sol
        ON sol.SalesOrderId = so.SalesOrderId
    GROUP BY
        so.SalesOrderId,
        so.CustomerId,
        so.OrderNumber,
        so.OrderDate;
