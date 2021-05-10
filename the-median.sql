-- https://github.com/storydrivendatasets/white_house_salaries
-- The median annual salary of White House staffers in 2013.

CREATE TABLE Employees (
  [year] int,
  president char(10),
  last_name varchar(30),
  first_name varchar(20),
  middle_name char(2),
  suffix char(3),
  full_name varchar(50),
  [status] char(8),
  salary money,
  pay_basis char(10),
  position_title varchar(200),
  white_house_review char(20)
)
GO

BULK INSERT Employees
FROM 'full/path/to/sql-sandbox/datasets/white_house_salaries.csv'
WITH (
  FIRSTROW = 2,
  FORMAT = 'CSV'
)
GO

WITH wh13_salaries AS
(
  SELECT
    salary
  FROM Employees
  WHERE year = 2013 AND salary <> 0
)

SELECT
  AVG(value) AS median
FROM (
  SELECT
    MAX(salary) AS value
  FROM (
    SELECT
      PERCENT_RANK() OVER(ORDER BY salary) AS pct_rank,
      salary
    FROM wh13_salaries
  ) wh13_rank
  WHERE pct_rank <= 0.5
  UNION ALL
  SELECT
    MIN(salary)
  FROM (
    SELECT
      PERCENT_RANK() OVER(ORDER BY salary DESC) AS pct_rank,
      salary
    FROM wh13_salaries
  ) wh13_rank_desc
  WHERE pct_rank <= 0.5
) middle_values;
