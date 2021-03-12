-- To-Do: Write a SELECT query that returns all the prime numbers less than 100.
-- Solution: Trial Division − check if prime candidate % divisor = 0 for each divisor from {2 ... sqrt(prime candidate)}.
-- Issues: Query runtime.

WITH RECURSIVE numbers AS
(
  SELECT
    1 AS n
  UNION ALL
  SELECT
    n + 1
  FROM numbers
  WHERE n < 100
)

SELECT
  n AS prime
FROM numbers
WHERE n > 1
  AND NOT EXISTS (
SELECT 1
FROM numbers divisors
WHERE (divisors.n > 1 AND divisors.n <= SQRT(numbers.n))
  AND numbers.n % divisors.n = 0
);

-- T-SQL: set the number of recursion levels
-- OPTION (MAXRECURSION 0)
