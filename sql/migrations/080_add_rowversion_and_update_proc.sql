SET NOCOUNT ON;
USE [SandboxDb];

IF COL_LENGTH(N'dbo.SalesOrder', N'RowVersion') IS NULL
BEGIN
    ALTER TABLE dbo.SalesOrder
        ADD RowVersion ROWVERSION NOT NULL;
END

CREATE OR ALTER PROCEDURE dbo.usp_UpdateSalesOrderNumber
    @SalesOrderId INT,
    @OrderNumber NVARCHAR(30),
    @ExpectedRowVersion VARBINARY(8)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE dbo.SalesOrder
    SET OrderNumber = @OrderNumber
    WHERE SalesOrderId = @SalesOrderId
      AND RowVersion = @ExpectedRowVersion;

    IF @@ROWCOUNT = 0
    BEGIN
        THROW 51000, 'Expected rowversion match for SalesOrder update.', 1;
    END
END
