-- H2_CEVAPLAR
-- AdventureWorks veritabında


--S1: Ürünlerde kaç farklı renk kullanılmıştır? (Production.Product)
SELECT count(Distinct Color)
FROM Production.Product;

--S2: Hangi renkten kaç ürün vardır? (Production.Product)
SELECT P.Color , 
COUNT(Color) AS [Number] 
FROM Production.Product AS P 
GROUP BY Color ORDER BY Number;

--S3: Ürünlerin liste fiyatı ve %18 zam yapıldığındaki liste fiyatını yan yana görelim. (Production.Product tablosunda Name, ListPrice, ListPriceZamli)
SELECT P.Name , P.ListPrice , P.ListPrice + P.ListPrice * 0.18 AS [ListeZamli] 
FROM Production.Product AS P
WHERE ListPrice != 0;

--S4: Hangi meslekten kaç erkek kaç kadın var (HumanResources.Employee)
SELECT HR.JobTitle ,
COUNT(CASE WHEN GENDER = 'M' THEN 1 END) AS [Male], 
COUNT(CASE WHEN Gender = 'F' THEN 1 END) AS [FEMALE] 
FROM HumanResources.Employee AS HR GROUP BY JobTitle;




--S5: Şirkette bekar kaç erkek, kaç kadın çalışanımız var. 35 yaşından küçük (HumanResources.Employee)
SELECT HR.MaritalStatus ,
COUNT(CASE WHEN Gender = 'M' THEN 1 END) AS [S_Male],
COUNT(CASE WHEN Gender = 'F' THEN 1 END) AS [S_Female] 
FROM HumanResources.Employee AS HR
WHERE MaritalStatus = 'S'and DATEDIFF(YYYY, BirthDate , GETDATE()) < 35  
GROUP BY HR.MaritalStatus;

/*
	S6: Person.Person tablosunda aşağıdaki şartlara uyan hangi FirstName'ler mevcut.
		- 1. karakter a olsun
		- 2. keyfi
		- 3. a ile k arasındakiler olmasın.
		- 4. keyfi
		- 5. m olsun.
		Sonrakiler keyfi
*/
SELECT DISTINCT FirstName
FROM Person.Person 
WHERE FirstName LIKE 'A_[^A-K]_M%';

--S7: HumanResource.Employee tablosundan en genç 5 kişinin: Yaşı,jobtitle,gender,maritialstatus.
SELECT top 5  DATEDIFF(YYYY, BirthDate ,GETDATE()) AS Age, JobTitle, Gender, MaritalStatus 
FROM HumanResources.Employee
ORDER BY Age;

--S8: Humanresource.Employee tablosunda hangi yaşta kaç tane insan var?
SELECT DATEDIFF(YYYY, BirthDate ,GETDATE()) AS Age, COUNT(*) AS [Numb_Human]
FROM  HumanResources.Employee 
GROUP BY DATEDIFF(YYYY, BirthDate ,GETDATE()) ORDER BY Numb_Human DESC ;

--S9: Hangi ayda kaç kişinin doğum günü var. (Humanresource.Employee)
SELECT MONTH(BirthDate) AS Month, COUNT(LoginID) AS NUM
FROM HumanResources.Employee
GROUP BY MONTH(BirthDate);

--S10: Şirkette en fazla tekrar eden 5 FirstName (Person.Person)
SELECT DISTINCT TOP 5 FirstName,
COUNT(FirstName) AS NUM
FROM Person.Person
GROUP BY FirstName HAVING COUNT(FirstName) >1 ORDER BY NUM DESC;

--S11: Hangi kategoride kaç ürün var? (Production.Product, Production.ProductSubcategory Production.ProductCategory)
SELECT C.Name AS [CATEGORY],
COUNT(PP.ProductID) AS [NUMBPRO] 
FROM Production.ProductCategory AS C
INNER JOIN Production.ProductSubcategory AS SC
ON C.ProductCategoryID = SC.ProductCategoryID
RIGHT OUTER JOIN Production.Product AS PP
ON SC.ProductSubcategoryID = PP.ProductSubcategoryID
WHERE C.Name IS NOT NULL
GROUP BY C.Name;

--S12: HumanResources.Employee tablosuna bakarak. 0-19, 20-49, 50+ yaş gruplarında kaçar kişi olduğunu listeleyelim.

--S13: Person.Person tablosunda "Sanchez" LastName'i aratıldığında "Sánchez" olanlarda gelecek şekilde sorgu yazalım. FirstName ve LastName gelsin.
SELECT FirstName, LastName 
FROM Person.Person
WHERE LastName = 'Sanchez'
COLLATE Turkish_CI_AI

--S14: Bugünün tarihini kullanarak, gün, ay, yıl, çeyrek bilgisini ve tarihi ISO formatında (20191231 biçiminde) yazdıralım.
SELECT CONVERT(datetime2,GETDATE(),112)

--S15: Bu ay doğan kişilerin bilgileri (Humanresource.Employee)(Person.Person)
SELECT P.FirstName,P.PersonType,H.BirthDate
FROM Person.Person AS P,Humanresources.Employee AS H
WHERE MONTH(BirthDate) = MONTH(GETDATE()) AND P.BusinessEntityID=H.BusinessEntityID
ORDER BY FirstName;

--S16: En yeni personellerin bilgileri  (Humanresource.Employee)(Person.Person)
SELECT TOP 5 * 
FROM Humanresources.Employee AS H,Person.Person AS P
WHERE H.BusinessEntityID = P.BusinessEntityID 
ORDER BY H.HireDate DESC;

--S17: En pahalı ikinci 5 ürün gelsin. (Production.Product)
SELECT DISTINCT TOP 5 P.Name,P.ListPrice
FROM Production.Product AS P ORDER BY ListPrice DESC;

--S18: En genc Tool Designer Kac yasýndadýr? (Humanresource.Employee)
SELECT TOP 1 DATEDIFF(YYYY, BirthDate ,GETDATE()) AS Age
FROM Humanresources.Employee
WHERE JobTitle = 'Tool Designer'
ORDER BY DATEDIFF(YYYY, BirthDate ,GETDATE());

--S19: Soyadýnda iki veya daha fazla a harfi gecen ve ikinci adý olmayan personeller gelsin
SELECT FirstName,LastName,MiddleName
FROM Person.Person
WHERE MiddleName IS NULL AND  LastName LIKE '%a%a%';

--S20: Toplam Degeri 100 000 uzerinde olan sipariþleri listeleyelim (Sales.SalesOrderDetail tablousunda SalesOrderID,OrderQty, UnitPrice, UnitPriceDiscount kolonları)
SELECT SalesOrderID,OrderQty, UnitPrice, UnitPriceDiscount,LineTotal 
FROM Sales.SalesOrderDetail
WHERE LineTotal > 100.000;

--S21: char, nchar, varchar, nvarchar veri tiplerinin farklarını anlayabileceğimiz bir örnek script paylaşalım
DECLARE @text char(15) = 'раÅaвств12',
        @text1 varchar(15) = 'раÅaвств12',
	  @text2 nchar(15) = 'раÅaвств12',
	  @text3 nvarchar(15) = 'раÅaвств12'

SELECT @text,
LEN(@text),DATALENGTH(@text)

SELECT @text1,
LEN(@text1),DATALENGTH(@text1)

SELECT @text2,
LEN(@text2),DATALENGTH(@text2)

SELECT @text3,
LEN(@text3),DATALENGTH(@text3)
