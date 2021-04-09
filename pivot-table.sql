-- Pivoting Data in SQL

-- SQL Server
-- PIVOT
SELECT
  [writer],
  [composer],
  [painter],
  [poet],
  [playwright]
FROM (
  SELECT
    ROW_NUMBER() OVER(PARTITION BY occupation ORDER BY RIGHT(name, LEN(name) - CHARINDEX(' ', name))) AS rn,
    name,
    occupation
  FROM people
) source_table
PIVOT (
  MIN(name) FOR occupation IN ([writer], [composer], [painter], [poet], [playwright])
) pivot_table;

-- PostgreSQL
-- with CROSSTAB

-- without CROSSTAB
SELECT
  MIN(CASE WHEN occupation = 'writer' THEN name END) AS writer,
  MIN(CASE WHEN occupation = 'composer' THEN name END) AS composer,
  MIN(CASE WHEN occupation = 'painter' THEN name END) AS painter,
  MIN(CASE WHEN occupation = 'poet' THEN name END) AS poet,
  MIN(CASE WHEN occupation = 'playwright' THEN name END) AS playwright
FROM (
  SELECT
    ROW_NUMBER() OVER(PARTITION BY occupation ORDER BY SPLIT_PART(name, ' ', 2)) AS rn,
    name,
    occupation
  FROM people
) source_table
GROUP BY rn
ORDER BY rn;
