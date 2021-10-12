
--Inline TVFs ( iki tarih arasýnda sipariþlerin verilerini getirdiðim fonkisyon)

USE AdventureWorks2017
GO

CREATE FUNCTION DifDate
(@firstdate datetime, @enddate datetime)
RETURNS TABLE
AS
RETURN (SELECT top(50) SalesOrderID,ModifiedDate FROM Sales.SalesOrderDetail
WHERE ModifiedDate >= @firstdate AND ModifiedDate <= @enddate order by SalesOrderID );
GO

SELECT * FROM dbo.DifDate('2014-01-01','2014-02-01')

select ModifiedDate from Sales.SalesOrderDetail;




--multi-statement TVFs

USE AdventureWorks2017
GO

CREATE FUNCTION multi_stat(@dtOrderMonth datetime)
RETURNS @orderDetail TABLE
(
   ProductID INT,
   SalesOrderID INT,
   SalesOrderNumber nvarchar(30),
   CustomerID INT,
   AccountNumber nvarchar(30),
   OrderDate datetime,
   ChrFlag char(1)

)
AS
BEGIN
INSERT INTO @orderDetail
SELECT TOP(20) sod.ProductID,
          soh.SalesOrderID,
          soh.SalesOrderNumber,
          soh.CustomerID,
          soh.AccountNumber,
          soh.OrderDate,
          'N'
FROM Sales.SalesOrderHeader soh
       inner join Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
WHERE  YEAR(soh.OrderDate) = YEAR(@dtOrderMonth) ORDER BY sod.ProductID

UPDATE @orderDetail
SET ChrFlag = 'Y'
WHERE OrderDate < Cast(DATEADD(DAY,-1,GETUTCDATE()) AS DATE)
RETURN;
END

SELECT * FROM dbo.multi_stat('2014-01-01')



