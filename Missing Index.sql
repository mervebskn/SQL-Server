--Missing Index , index oluþturup performansý artýrabiliriz.

USE AdventureWorks2017;
GO

SELECT * FROM Person.Address WHERE City='Dresden' AND PostalCode='01071'


---------------------------------------------------------------------------


SELECT DB_NAME(id.database_id) AS databaseName,
 id.statement AS TableName,
 id.equality_columns,
 id.inequality_columns,
 id.included_columns,
 gs.last_user_seek,
 gs.user_seeks,
 gs.last_user_scan,
 gs.user_scans,
 gs.avg_total_user_cost * gs.avg_user_impact * (gs.user_seeks + gs.user_scans)/100 AS ImprovementValue  
FROM sys.dm_db_missing_index_group_stats gs
INNER JOIN sys.dm_db_missing_index_groups ig ON gs.group_handle = ig.index_group_handle
INNER JOIN sys.dm_db_missing_index_details id ON id.index_handle = ig.index_handle
WHERE DB_NAME(id.database_id) = 'AdventureWorks2017'
ORDER BY avg_total_user_cost * avg_user_impact * (user_seeks + user_scans)/100 DESC

--sorguyu çalýþtýrdýktan sonra City,PostalCode ve City index'lerinin eksik olduðunu
--görebiliyoruz
---------------------------------------------------------------
SET STATISTICS IO ON
GO
SELECT * FROM Person.Address WHERE City='Dresden' and PostalCode='01071'
SET STATISTICS IO OFF
GO

------------------------------------------------------------------
CREATE NONCLUSTERED INDEX [IX_Address_City_PostalCode] ON [Person].[Address] ([City],[PostalCode]);

-------------------------------------------------------------------------
SET STATISTICS IO ON
GO
SELECT * FROM Person.Address WHERE City='Dresden' and PostalCode='01071'
SET STATISTICS IO OFF
GO

--ilk istatistik sonuçlarýndaki logical reads ile
--index oluþturdukdan sonra istatistik sonuçlarýndaki logical reads arasýndaki fark ile
--performans farkýný görebiliriz.