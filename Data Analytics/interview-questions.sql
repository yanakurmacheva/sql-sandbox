-- Self-Join Practice Problems (*some of these were solved using window functions or CASE statements)

-- #1: Month-over-Month Percent Change
-- Find the month-over-month percentage change for monthly active users (MAU).
SELECT
  month,
  mau,
  ROUND(100.0 * (mau - LAG(mau) OVER(ORDER BY month)) / LAG(mau) OVER(ORDER BY month), 2) AS percent_change
FROM (
  SELECT
    DATE_TRUNC('month', date) AS month,
    COUNT(DISTINCT user_id) AS mau
  FROM logins
  GROUP BY DATE_TRUNC('month', date)
) m;

-- #2: Tree Structure Labeling
-- Write SQL such that we label each node as 'leaf', 'inner', or 'root'.
SELECT
  node,
  CASE
    WHEN parent IS NULL THEN 'root'
    WHEN node IN (SELECT parent FROM tree) THEN 'inner'
    ELSE 'leaf'
  END AS label
FROM tree;

-- #3: Retained Users Per Month (multi-part)
-- Part 1. Write a query that gets the number of retained users per month.
WITH unique_logins AS
(
  SELECT
    DISTINCT user_id,
    DATE_TRUNC('month', date) AS month
  FROM logins
)

SELECT
  c.month,
  COUNT(*) AS retained_users
FROM unique_logins c -- current month
JOIN unique_logins p -- previous month
  ON c.user_id = p.user_id
  AND c.month = p.month + '1 month'::interval
GROUP BY c.month;

-- #4: Cumulative Sums
-- Write a query to get cumulative cash flow for each day.
SELECT
  date,
  SUM(cash_flow) OVER(ORDER BY date) AS cumulative_cf
FROM transactions;

-- #5: Rolling Averages
-- Write a query to get 7-day rolling average of daily signups.
SELECT
  date,
  sign_ups,
  AVG(sign_ups) OVER(ORDER BY date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS avg_over_7_days
FROM signups;


-- Window Function Practice Problems

-- #1: Get the ID with the highest value
-- Write a query to get the empno with the highest salary.
SELECT
  empno
FROM (
  SELECT
    empno,
    salary,
    RANK() OVER(ORDER BY salary DESC) AS rnk
  FROM salaries
) ranked_by_salary
WHERE rnk = 1;

-- #2: Average and rank with a window function (multi-part)
-- Part 1. Write a query that returns the same table, but with a new column that has average salary per depname.
SELECT
  depname,
  empno,
  salary,
  ROUND(AVG(salary) OVER(PARTITION BY depname), 0) AS avg_dep_salary
FROM salaries;

-- Part 2. Write a query that adds a column with the rank of each employee based on their salary within their department.
SELECT
  depname,
  empno,
  salary,
  DENSE_RANK() OVER(PARTITION BY depname ORDER BY salary DESC) AS salary_rank
FROM salaries;
