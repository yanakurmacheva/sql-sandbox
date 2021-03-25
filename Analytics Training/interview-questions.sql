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

-- #6: Multiple Join Conditions
-- Write a query to get the response time per email (id) sent to zach@g.com (subjects are unique).
SELECT
  e1.id,
  e1.from AS sender,
  MIN(e2.timestamp - e1.timestamp) AS response_time -- Zach wrote back in ...
FROM emails e1
JOIN emails e2
  ON e1.subject = e2.subject
  AND e1.to = e2.from AND e1.from = e2.to
  AND e1.timestamp < e2.timestamp
WHERE e1.to = 'zach@g.com'
GROUP BY e1.id, e1.from;


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
  DENSE_RANK() OVER(PARTITION BY depname ORDER BY salary DESC) AS salary_dep_rank
FROM salaries;


-- Other Medium/Hard SQL Practice Problems

-- #1: Histograms
-- Write a query to count the number of sessions that fall into bands of size 5.
SELECT
  CONCAT(lower_bound, '-', upper_bound) AS bucket,
  COUNT(*)
FROM (
  SELECT
    length_seconds,
    FLOOR(length_seconds / 5.0) * 5 AS lower_bound,
    FLOOR(length_seconds / 5.0) * 5 + 5 AS upper_bound
  FROM sessions
) labels
GROUP BY lower_bound, upper_bound
ORDER BY lower_bound;

-- #2: CROSS JOIN (multi-part)
-- Part 1. Write a query to get the pairs of states with total streaming amounts within 1000 of each other.
SELECT
  t1.state AS state_a,
  t2.state AS state_b
FROM state_streams t1
CROSS JOIN state_streams t2
WHERE t1.state <> t2.state
  AND ABS(t1.total_streams - t2.total_streams) < 1000;

-- Part 2. How could you modify the SQL from the solution to Part 1 of this question so that duplicates are removed?
SELECT
  t1.state AS state_a,
  t2.state AS state_b
FROM state_streams t1
CROSS JOIN state_streams t2
WHERE t1.state < t2.state
  AND ABS(t1.total_streams - t2.total_streams) < 1000;

-- #3: Advancing Counting
-- Write a query to count the number of users in each class (a user with both labels gets sorted into 'b').
WITH deduplicated_users AS
(
  SELECT
    DISTINCT user,
    class
  FROM table
)

SELECT
  class,
  COUNT(DISTINCT user)
FROM (
  SELECT
    user,
    CASE
      WHEN COUNT(*) OVER(PARTITION BY user) > 1 THEN 'b'
      ELSE class
    END AS class
  FROM deduplicated_users
) relabelled_users
GROUP BY class;
