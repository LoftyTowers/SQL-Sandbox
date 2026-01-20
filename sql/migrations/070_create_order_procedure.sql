SET NOCOUNT ON;
USE [SandboxDb];

CREATE OR ALTER PROCEDURE dbo.usp_CreateOrder
    @CustomerId INT,
    @OrderNumber NVARCHAR(30),
    @OrderDate DATETIME2(0),
    @LineNumber SMALLINT,
    @ItemName NVARCHAR(200),
    @Quantity INT,
    @UnitPrice DECIMAL(12,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StartTranCount INT = @@TRANCOUNT;
    DECLARE @StartedTran BIT = 0;

    BEGIN TRY
        IF @StartTranCount = 0
        BEGIN
            BEGIN TRANSACTION;
            SET @StartedTran = 1;
        END
        ELSE
        BEGIN
            SAVE TRANSACTION usp_CreateOrder_Savepoint;
        END

        INSERT INTO dbo.SalesOrder (CustomerId, OrderNumber, OrderDate)
        VALUES (@CustomerId, @OrderNumber, @OrderDate);

        DECLARE @SalesOrderId INT = CONVERT(INT, SCOPE_IDENTITY());

        INSERT INTO dbo.SalesOrderLine (SalesOrderId, LineNumber, ItemName, Quantity, UnitPrice)
        VALUES (@SalesOrderId, @LineNumber, @ItemName, @Quantity, @UnitPrice);

        IF @StartedTran = 1
        BEGIN
            COMMIT TRANSACTION;
        END
    END TRY
    BEGIN CATCH
        IF XACT_STATE() = -1
        BEGIN
            ROLLBACK TRANSACTION;
        END
        ELSE IF XACT_STATE() = 1
        BEGIN
            IF @StartedTran = 1
            BEGIN
                ROLLBACK TRANSACTION;
            END
            ELSE
            BEGIN
                ROLLBACK TRANSACTION usp_CreateOrder_Savepoint;
            END
        END
        THROW;
    END CATCH
END
