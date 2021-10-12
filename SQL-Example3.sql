

--S:1 Titleları Mr. olan personellerin meslekleri,evlilik durumu ve cinsiyetleri nedir
--HumanResources.Employee, Person.Person
SELECT H.JobTitle,H.MaritalStatus,H.Gender
FROM HumanResources.Employee AS H
WHERE H.BusinessEntityID IN
(SELECT P.BusinessEntityID FROM Person.Person AS P WHERE Title='Mr.')

--S2: insan kaynakları ve personel tablosunda aynı AYda (yılı göz ardı edelim) güncellenen personellerin mesleki bilgilerini getirelim
--HumanResources.Employee, Person.Person
SELECT H.JobTitle
FROM HumanResources.Employee H
WHERE H.BusinessEntityID IN
(SELECT P.BusinessEntityID FROM Person.Person P WHERE MONTH(P.ModifiedDate) = MONTH(H.ModifiedDate))

--S3: birden fazla sipariş verilen ürünler hangileri
--Production.Product, Sales.SalesOrderDetail (OrderQty)
SELECT P.ProductID,P.Name,P.Color,P.ListPrice
FROM Production.Product AS P
WHERE P.ProductID IN(SELECT ProductID FROM Sales.SalesOrderDetail WHERE OrderQty > 1)

--S4: İki tarih arasındaki tüm günler için her satırda ISO formatında tarih, tarih, gün,ay, yıl, çeyrek, hafta, haftaiçimi sonumu kolonları olan tablo üretelim. Bunun için CTE ve WHILE kullanarak iki örnek yapalım.
--OPTION (MAXRECURSION 0)

--CTE

DECLARE @Date_1 DATE = '2020-01-01';
DECLARE @Date_2 DATE = GETDATE();

;WITH CTE_DATE
AS
(
   SELECT @Date_1 AS NDate
   UNION ALL
   SELECT DATEADD(DAY,1,NDate) AS NDate FROM CTE_DATE WHERE DATEADD(DAY,1,NDate) <= @Date_2
)

SELECT NDate, CONVERT(varchar,NDate,112) AS 'ISO_FORMAT',
DAY(NDate) AS 'Day',
MONTH(NDate) AS 'Month',
YEAR(NDate) AS 'Year',
DATEPART(Quarter,NDate) AS 'Quarter',
DATEPART(Week,NDate) 'Week',
CASE WHEN DATEPART(WEEKDAY,NDate) IN (7,1) THEN 'WEEKEND' ELSE 'WEEKDAY' END AS Weekday_Or_Weekend
FROM CTE_DATE
OPTION (MAXRECURSION 0)
----------------------------------
--WHILE

DECLARE @Date_1 DATE = '2020-01-01';
DECLARE @Date_2 DATE = GETDATE();
DECLARE @t int

CREATE TABLE Dates
(
NDate DATE,
Day int,
Month int,
Year int,
Quarter int,
Weekday_Or_Weekend varchar(10)
)

WHILE
   @Date_1 <= @Date_2
BEGIN 
SELECT @t = Month(@Date_1)
SELECT @t = Choose (@t,1,1,1,2,2,2,3,3,3,4,4,4) 

INSERT INTO dbo.Dates VALUES (@Date_1, day(@Date_1), MONTH(@Date_1), Year(@Date_1), @t , IIF(DATEPART(DW, @Date_1) = 1 or DATEPART(DW, @Date_1)=7, 'Weekend', 'Weekday'))  
SELECT @Date_1 = DATEADD(day, 1, @Date_1)

END 

SELECT * FROM dbo.Dates

---*-*-*-*- Aşaağıdaki soruları Hesap Özeti tablosuna insert ettiğimiz veriler yardımıyla çözelim.*-*-*-*--*-*-
--DROP TABLE HesapOzeti
CREATE TABLE HesapOzeti
(
	Id int identity(1,1),
	Kategori nvarchar(50),
	Tutar money
)

GO
--truncate table Hesapozeti
--Gelir gider kayýd
INSERT INTO HesapOzeti(Kategori,Tutar) VALUES('Yakit',-100),
											('Alacak',200),
											('Kira Alacak',500),
											('Giyecek',-150),
											('Yakit',-400),
											('Yakit',-200)

SELECT * FROM HesapOzeti

 -Id, Kategor, Tutar kolonları ile birlikte Son durum kolonu/kolonları oluşturalım..
 son durum kolonunda şu soruların cevabını verelim:

 --S5: Kategorinin tüm tutarı nedir?
 SELECT SUM(Tutar) FROM dbo.HesapOzeti;

-- S6: Kategorinin Id sırasına göre son tutarı nedir?
SELECT TOP(1) Tutar FROM dbo.HesapOzeti
ORDER BY Id DESC;

 --S7: Satır kategorideki toplam harcamanın % kaçını oluşturmakta?
SELECT Kategori,(Tutar*100)/SUM(Tutar) OVER(PARTITION BY Kategori) AS YuzdeTutar 
FROM HesapOzeti

 --S8: Hesap Özetini Id ye göre sıralayarak baktığımızda baştan sona satır satır tutardaki değişim nedir?
SELECT Id,Kategori,Tutar,SUM(Tutar) OVER (ORDER BY Id ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS Degisim
FROM dbo.HesapOzeti; 
  
 --S9: Hesap Özetini Id ye göre sıralayarak baktığımızda sondan başa satır satır tutardaki değişim nedir?
SELECT Id,Kategori,Tutar,SUM(Tutar) OVER (ORDER BY Id ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) AS Degisim
FROM dbo.HesapOzeti; 



---*-*-*-*- Aşaağıdaki soruları Ticaret tablosuna insert ettiğimiz veriler yardımıyla çözelim.*-*-*-*--*-*-
--Bir ki?inin ?imdiki ve önceki y?ldaki borcu neler.
--DROP TABLE Ticaret
CREATE TABLE Ticaret
		(
			Musteri nvarchar(50),
			Yil int,
			Tutar money
		)

INSERT INTO Ticaret VALUES ('X',2001,100),
						  ('X',2002,120),
						  ('X',2003,140),
						  ('Y',2001,10),
						  ('Y',2002,12),
						  ('Y',2003,14)

-- Tüm kolonlarla birlike yeni kolon/kolonlar oluşturarak aşağıdaki soruların cevabını elde edelim
	
--S10: Musterinin önceki yil Tutar
SELECT Musteri,Yil,Tutar,LAG(Tutar, 1) OVER (PARTITION BY Musteri ORDER BY Yil) AS OncekiYilTutar
FROM dbo.Ticaret ORDER BY Musteri, Yil 

--S11: Musterinin sonraki yil Tutar
SELECT Musteri,Yil,Tutar,LEAD(Tutar, 1) OVER (PARTITION BY Musteri ORDER BY Yil) AS SonrakiYilTutar
FROM dbo.Ticaret ORDER BY Musteri, Yil 

--S12: Musterinin ilk yildaki Tutar 
SELECT Musteri,Yil,Tutar FROM(SELECT Musteri,Yil,Tutar,
DENSE_RANK() OVER(PARTITION BY Musteri ORDER BY Yil) AS D_Rank FROM dbo.Ticaret) AS IlkYilTutar 
WHERE D_Rank=1

--S13: Musterinin son yildaki Tutar
SELECT Musteri,Yil,Tutar FROM(SELECT Musteri,Yil,Tutar,
DENSE_RANK() OVER(PARTITION BY Musteri ORDER BY Yil DESC) AS D_Rank FROM dbo.Ticaret) AS IlkYilTutar 
WHERE D_Rank=1

--NOT: ikinci parametre offset, ücüncü parametre bulamazsa ne yazaca??.
--mü?terilerin bir sonraki borcu




--S14:Ticaret tablosunu "Musteri 2001, 2002, 2003" şeklinde görelim.
SELECT Musteri, [2001],[2002],[2003]
FROM ( SELECT Musteri,Yil,Tutar FROM dbo.Ticaret) AS D
PIVOT(SUM(Tutar) FOR Yil IN ([2001],[2002],[2003])) AS PVT; 

--Yukarıdaki ticaret tablosuna aşağıdaki kayıtları da ekleyerek soruya cevap verelim.
INSERT INTO Ticaret VALUES ('X',2001,50),
						  ('X',2003,220),
						  ('Y',2001,100),
						  ('Y',2002,130),
						  ('Y',2003,80)


--S15: Yukarıdaki sorgudan elde edilen tabloyu tablo tipinden bir değişkene atalım. ve bu değişkendeki pivot tabloyu tekrar ticaret tablosu gibi unpivot hale getirelim.
DECLARE @PVT table (Musteri nvarchar(50) ,[2001] money,[2002] money,[2003] money)

INSERT INTO @PVT
SELECT Musteri,[2001],[2002],[2003] FROM dbo.Ticaret
PIVOT(SUM(Tutar) FOR Yil IN ([2001],[2002],[2003])) as P_Table

SELECT * FROM @PVT as P UNPIVOT(Tutar FOR Yil IN ([2001],[2002],[2003]))AS UP_Table


