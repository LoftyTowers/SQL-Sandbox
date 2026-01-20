SET NOCOUNT ON;
USE [SandboxDb];

BEGIN TRANSACTION;

DECLARE @CustomerId INT;
DECLARE @Order1Id INT;
DECLARE @Order2Id INT;
DECLARE @Order3Id INT;
DECLARE @JoinCount INT;
DECLARE @FirstId INT;
DECLARE @SecondId INT;
DECLARE @ThirdId INT;

BEGIN TRY
    INSERT INTO dbo.Customer (CustomerName, Email)
    VALUES (N'T06 Customer', N't06-query@example.test');

    SET @CustomerId = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrder (CustomerId, OrderNumber, OrderDate)
    VALUES (@CustomerId, N'T06-001', CAST('2026-01-01T00:00:00' AS DATETIME2(0)));
    SET @Order1Id = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrder (CustomerId, OrderNumber, OrderDate)
    VALUES (@CustomerId, N'T06-002', CAST('2026-01-02T00:00:00' AS DATETIME2(0)));
    SET @Order2Id = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrder (CustomerId, OrderNumber, OrderDate)
    VALUES (@CustomerId, N'T06-003', CAST('2026-01-03T00:00:00' AS DATETIME2(0)));
    SET @Order3Id = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.SalesOrderLine (SalesOrderId, LineNumber, ItemName, Quantity, UnitPrice)
    VALUES
        (@Order1Id, 1, N'Item A', 1, 10.00),
        (@Order1Id, 2, N'Item B', 2, 5.00),
        (@Order2Id, 1, N'Item C', 1, 15.00),
        (@Order3Id, 1, N'Item D', 3, 2.00);

    SELECT @JoinCount = COUNT(*)
    FROM dbo.SalesOrder AS so
    JOIN dbo.SalesOrderLine AS sol
        ON sol.SalesOrderId = so.SalesOrderId
    WHERE so.CustomerId = @CustomerId;

    IF @JoinCount <> 4
    BEGIN
        THROW 51000, 'Expected join to return 4 rows for the test customer.', 1;
    END

    IF EXISTS
    (
        SELECT 1
        FROM dbo.SalesOrder AS so
        WHERE so.CustomerId = @CustomerId
          AND NOT EXISTS
          (
              SELECT 1
              FROM dbo.SalesOrderLine AS sol
              WHERE sol.SalesOrderId = so.SalesOrderId
          )
    )
    BEGIN
        THROW 51000, 'Expected all test orders to have at least one line.', 1;
    END

    WITH OrderedOrders AS
    (
        SELECT
            so.SalesOrderId,
            ROW_NUMBER() OVER (ORDER BY so.OrderDate, so.SalesOrderId) AS RowNum
        FROM dbo.SalesOrder AS so
        WHERE so.CustomerId = @CustomerId
    )
    SELECT
        @FirstId = MAX(CASE WHEN RowNum = 1 THEN SalesOrderId END),
        @SecondId = MAX(CASE WHEN RowNum = 2 THEN SalesOrderId END),
        @ThirdId = MAX(CASE WHEN RowNum = 3 THEN SalesOrderId END)
    FROM OrderedOrders;

    IF @FirstId <> @Order1Id OR @SecondId <> @Order2Id OR @ThirdId <> @Order3Id
    BEGIN
        THROW 51000, 'Expected deterministic ordering by OrderDate then SalesOrderId.', 1;
    END

    DECLARE @Page TABLE
    (
        RowNum INT IDENTITY(1,1) NOT NULL,
        SalesOrderId INT NOT NULL
    );

    INSERT INTO @Page (SalesOrderId)
    SELECT TOP (2)
        so.SalesOrderId
    FROM dbo.SalesOrder AS so
    WHERE so.CustomerId = @CustomerId
    ORDER BY so.OrderDate, so.SalesOrderId;

    IF EXISTS (SELECT 1 FROM @Page WHERE RowNum = 1 AND SalesOrderId <> @Order1Id)
       OR EXISTS (SELECT 1 FROM @Page WHERE RowNum = 2 AND SalesOrderId <> @Order2Id)
    BEGIN
        THROW 51000, 'Expected pagination to return the first two orders deterministically.', 1;
    END

    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0
    BEGIN
        ROLLBACK TRANSACTION;
    END
    THROW;
END CATCH

PRINT 'Verification: query correctness OK';
