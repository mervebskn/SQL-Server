
--Rebuilt or reorganize

--fragmentation oraný yüzde 5 ve 30 arasýnda ise Reorganize iþlemi uygulanýr
--deðer yüzde 30’un üzerindeyse Rebuilt Ýþlemi uygulanýr

USE AdventureWorks2017;
GO

SELECT s.name +'.'+t.name  AS table_name,
       i.NAME AS index_name,
	 index_type_desc,
	 ROUND(avg_fragmentation_in_percent,2) AS avg_fragmentation_in_percent,
	 record_count AS table_record_count,
 	 'ALTER INDEX ' + QUOTENAME(i.name) + 'ON' + QUOTENAME(object_name(i.object_id)) + 
CASE
WHEN ips.avg_fragmentation_in_percent > 30 THEN ' REBUILD ' 
WHEN ips.avg_fragmentation_in_percent BETWEEN 5 AND 30 THEN 'REORGANIZE'
ELSE NULL END AS [OPTION]
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'SAMPLED') ips
INNER JOIN sys.tables t on t.object_id = ips.object_id
INNER JOIN sys.schemas s on t.schema_id = s.schema_id
INNER JOIN sys.indexes i ON (ips.object_id = i.object_id) AND (ips.index_id = i.index_id)
ORDER BY avg_fragmentation_in_percent DESC

--Kullanýlmayan index

--Dm_db_index_usage_stats DMV, index kullanýmý hakkýnda bilgileri verir.

SELECT
    o.name AS table_name,
    i.name AS index_name,
    dm_db_index_usage_stats.user_seeks,
    dm_db_index_usage_stats.user_scans,
    dm_db_index_usage_stats.user_updates
FROM
    sys.dm_db_index_usage_stats
    INNER JOIN sys.objects AS o ON dm_db_index_usage_stats.object_id = o.object_id
    INNER JOIN sys.indexes AS i ON i.index_id = dm_db_index_usage_stats.index_id AND dm_db_index_usage_stats.object_id = i.object_id
WHERE
    i.is_primary_key = 0 -- birincil anahtar kýsýtlamasýný yok sayar
    AND
    i.is_unique = 0 -- benzersiz anahtar kýsýtlamasýný yok sayar
    AND 
    dm_db_index_usage_stats.user_updates <> 0 --SQL Server'ýn çalýþtýrmadýðý indexleri yok sayar
    AND
    dm_db_index_usage_stats. user_lookups = 0
    AND
    dm_db_index_usage_stats.user_seeks = 0
    AND
    dm_db_index_usage_stats.user_scans = 0
ORDER BY
    dm_db_index_usage_stats.user_updates DESC