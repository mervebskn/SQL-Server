
--yazdýðýmýz tarihteki ayýn kaçýncý iþ günü olduðunu hesaplayan fonksiyon. 

CREATE FUNCTION WorkingDays(@Date DATETIME2)
RETURNS INT
AS
BEGIN

DECLARE @LastDayofPrevMonth DATETIME2,
@Return INT

SET @LastDayofPrevMonth = CAST(YEAR(@Date) as VARCHAR(4))+RIGHT('00'+CAST(MONTH(@Date) as VARCHAR(2)),2)+'01'
SET @LastDayofPrevMonth = DATEADD (day, -1, CAST(@LastDayofPrevMonth AS DATE))

SELECT @Return = CASE
WHEN DATENAME(dw, @Date) = 'Sunday' OR DATENAME(dw, @Date) = 'Saturday' THEN 0
ELSE (DATEDIFF(dd, @LastDayofPrevMonth, @Date))-(DATEDIFF(wk, @LastDayofPrevMonth, @Date) * 2)
-(CASE WHEN DATENAME(dw, @Date) IN ('Saturday', 'Sunday') THEN 1 ELSE 0 END)
END
RETURN @Return
END;
GO
---
SELECT dbo.WorkingDays('2021-10-12');

--------------------------------------------------------------------------------------------------------------
