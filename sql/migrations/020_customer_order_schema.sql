SET NOCOUNT ON;
USE [SandboxDb];

IF OBJECT_ID(N'dbo.Customer', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Customer
    (
        CustomerId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_Customer PRIMARY KEY,
        CustomerName NVARCHAR(200) NOT NULL,
        Email NVARCHAR(320) NULL,
        CreatedAt DATETIME2(0) NOT NULL CONSTRAINT DF_Customer_CreatedAt DEFAULT (SYSUTCDATETIME())
    );
END

IF OBJECT_ID(N'dbo.SalesOrder', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SalesOrder
    (
        SalesOrderId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SalesOrder PRIMARY KEY,
        CustomerId INT NOT NULL,
        OrderNumber NVARCHAR(30) NOT NULL,
        OrderDate DATETIME2(0) NOT NULL CONSTRAINT DF_SalesOrder_OrderDate DEFAULT (SYSUTCDATETIME())
    );
END

IF OBJECT_ID(N'dbo.SalesOrderLine', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.SalesOrderLine
    (
        SalesOrderLineId INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_SalesOrderLine PRIMARY KEY,
        SalesOrderId INT NOT NULL,
        LineNumber SMALLINT NOT NULL,
        ItemName NVARCHAR(200) NOT NULL,
        Quantity INT NOT NULL,
        UnitPrice DECIMAL(12,2) NOT NULL
    );
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_SalesOrder_Customer'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrder')
)
BEGIN
    ALTER TABLE dbo.SalesOrder
        ADD CONSTRAINT FK_SalesOrder_Customer
            FOREIGN KEY (CustomerId)
            REFERENCES dbo.Customer(CustomerId);
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.foreign_keys
    WHERE name = N'FK_SalesOrderLine_SalesOrder'
      AND parent_object_id = OBJECT_ID(N'dbo.SalesOrderLine')
)
BEGIN
    ALTER TABLE dbo.SalesOrderLine
        ADD CONSTRAINT FK_SalesOrderLine_SalesOrder
            FOREIGN KEY (SalesOrderId)
            REFERENCES dbo.SalesOrder(SalesOrderId);
END
