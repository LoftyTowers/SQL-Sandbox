SET NOCOUNT ON;
USE [SandboxDb];

IF OBJECT_ID(N'dbo.Customer', N'U') IS NULL
BEGIN
    THROW 51000, 'Expected table dbo.Customer to exist.', 1;
END

IF OBJECT_ID(N'dbo.SalesOrder', N'U') IS NULL
BEGIN
    THROW 51000, 'Expected table dbo.SalesOrder to exist.', 1;
END

IF OBJECT_ID(N'dbo.SalesOrderLine', N'U') IS NULL
BEGIN
    THROW 51000, 'Expected table dbo.SalesOrderLine to exist.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'Customer'
      AND COLUMN_NAME = 'CustomerId'
      AND DATA_TYPE = 'int'
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.Customer.CustomerId INT NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'Customer'
      AND COLUMN_NAME = 'CustomerName'
      AND DATA_TYPE = 'nvarchar'
      AND CHARACTER_MAXIMUM_LENGTH = 200
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.Customer.CustomerName NVARCHAR(200) NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'Customer'
      AND COLUMN_NAME = 'Email'
      AND DATA_TYPE = 'nvarchar'
      AND CHARACTER_MAXIMUM_LENGTH = 320
      AND IS_NULLABLE = 'YES'
)
BEGIN
    THROW 51000, 'Expected dbo.Customer.Email NVARCHAR(320) NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'Customer'
      AND COLUMN_NAME = 'CreatedAt'
      AND DATA_TYPE = 'datetime2'
      AND DATETIME_PRECISION = 0
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.Customer.CreatedAt DATETIME2(0) NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrder'
      AND COLUMN_NAME = 'SalesOrderId'
      AND DATA_TYPE = 'int'
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrder.SalesOrderId INT NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrder'
      AND COLUMN_NAME = 'CustomerId'
      AND DATA_TYPE = 'int'
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrder.CustomerId INT NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrder'
      AND COLUMN_NAME = 'OrderNumber'
      AND DATA_TYPE = 'nvarchar'
      AND CHARACTER_MAXIMUM_LENGTH = 30
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrder.OrderNumber NVARCHAR(30) NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrder'
      AND COLUMN_NAME = 'OrderDate'
      AND DATA_TYPE = 'datetime2'
      AND DATETIME_PRECISION = 0
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrder.OrderDate DATETIME2(0) NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrderLine'
      AND COLUMN_NAME = 'SalesOrderLineId'
      AND DATA_TYPE = 'int'
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrderLine.SalesOrderLineId INT NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrderLine'
      AND COLUMN_NAME = 'SalesOrderId'
      AND DATA_TYPE = 'int'
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrderLine.SalesOrderId INT NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrderLine'
      AND COLUMN_NAME = 'LineNumber'
      AND DATA_TYPE = 'smallint'
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrderLine.LineNumber SMALLINT NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrderLine'
      AND COLUMN_NAME = 'ItemName'
      AND DATA_TYPE = 'nvarchar'
      AND CHARACTER_MAXIMUM_LENGTH = 200
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrderLine.ItemName NVARCHAR(200) NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrderLine'
      AND COLUMN_NAME = 'Quantity'
      AND DATA_TYPE = 'int'
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrderLine.Quantity INT NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'SalesOrderLine'
      AND COLUMN_NAME = 'UnitPrice'
      AND DATA_TYPE = 'decimal'
      AND NUMERIC_PRECISION = 12
      AND NUMERIC_SCALE = 2
      AND IS_NULLABLE = 'NO'
)
BEGIN
    THROW 51000, 'Expected dbo.SalesOrderLine.UnitPrice DECIMAL(12,2) NOT NULL.', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints kc
    JOIN sys.index_columns ic
        ON kc.parent_object_id = ic.object_id
       AND kc.unique_index_id = ic.index_id
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE kc.type = 'PK'
      AND kc.parent_object_id = OBJECT_ID(N'dbo.Customer')
      AND c.name = 'CustomerId'
      AND ic.key_ordinal = 1
)
BEGIN
    THROW 51000, 'Expected primary key on dbo.Customer(CustomerId).', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints kc
    JOIN sys.index_columns ic
        ON kc.parent_object_id = ic.object_id
       AND kc.unique_index_id = ic.index_id
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE kc.type = 'PK'
      AND kc.parent_object_id = OBJECT_ID(N'dbo.SalesOrder')
      AND c.name = 'SalesOrderId'
      AND ic.key_ordinal = 1
)
BEGIN
    THROW 51000, 'Expected primary key on dbo.SalesOrder(SalesOrderId).', 1;
END

IF NOT EXISTS
(
    SELECT 1
    FROM sys.key_constraints kc
    JOIN sys.index_columns ic
        ON kc.parent_object_id = ic.object_id
       AND kc.unique_index_id = ic.index_id
    JOIN sys.columns c
        ON ic.object_id = c.object_id
       AND ic.column_id = c.column_id
    WHERE kc.type = 'PK'
      AND kc.parent_object_id = OBJECT_ID(N'dbo.SalesOrderLine')
      AND c.name = 'SalesOrderLineId'
      AND ic.key_ordinal = 1
)
BEGIN
    THROW 51000, 'Expected primary key on dbo.SalesOrderLine(SalesOrderLineId).', 1;
END

PRINT 'Verification: Customer/Order schema OK';
