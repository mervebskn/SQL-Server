CREATE TABLE Banka
(
  MusteriNo int,
  MusteriAd varchar(40),
  Bakiye money,
  SonIslemTarihi DATETIME
  Primary Key(MusteriNo)
);

INSERT INTO Banka (MusteriNo,MusteriAd,Bakiye,SonIslemTarihi) VALUES (1234,'X',10000,getdate())
INSERT INTO Banka (MusteriNo,MusteriAd,Bakiye,SonIslemTarihi) VALUES (2341,'Y',20000,getdate())
INSERT INTO Banka (MusteriNo,MusteriAd,Bakiye,SonIslemTarihi) VALUES (3344,'Z',30000,getdate())
INSERT INTO Banka (MusteriNo,MusteriAd,Bakiye,SonIslemTarihi) VALUES (4575,'Z',5000,getdate())

Go

CREATE PROC sp_Havale
(
  @AliciHesapNo int,
  @GondericiHesapNo int,
  @GonderilecekTutar money,
  @returnvalue int OUT
)
AS
BEGIN
    DECLARE @Kontrol money;
    SELECT @Kontrol = Bakiye FROM Banka WHERE MusteriNo = @GondericiHesapNo;
    IF @Kontrol >= @GonderilecekTutar
    BEGIN
        BEGIN TRANSACTION
            UPDATE Banka
            SET Bakiye = Bakiye - @GonderilecekTutar
            WHERE MusteriNo = @GondericiHesapNo
        IF @@ERROR <> 0
        ROLLBACK
            UPDATE Banka
            SET Bakiye = Bakiye + @GonderilecekTutar
            WHERE MusteriNo = @AliciHesapNo
        IF @@ERROR <> 0
        ROLLBACK
        COMMIT
    END
    ELSE
    BEGIN
        SET @returnvalue = -1;  --iþlem baþarýsýz olursa -1 deðeri dönecek.
        RETURN @returnvalue;
    END
END;

DECLARE @rValue INT;
EXEC dbo.sp_Havale '1234','2341',500, @rValue out;
SELECT * FROM Banka;



