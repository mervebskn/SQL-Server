
--girilen string deðer arasýndan indexe göre istenen deðeri elde etmek için fonksiyon örneði...

CREATE FUNCTION func3
(@names varchar(100) , @sira int)
RETURNS varchar(10)
AS
BEGIN
DECLARE @string varchar(50),
@separator char(1) = ';';
SET @string = (SELECT S.value
FROM (SELECT * , ROW_NUMBER() OVER(ORDER BY @names) AS num
FROM string_split(@names,@separator)) AS S WHERE S.num = @sira)
RETURN @string
END
-------------------------------------------------------------------
SELECT dbo.func3('merve;baskan;lisans;matematik',4)