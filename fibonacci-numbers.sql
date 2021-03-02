-- To-Do: Write a SELECT query that returns the first 90 Fibonacci numbers.
-- Solution: F(n) = F(0) + F(1) + ... + F(n-2) + 1 (the sum over the first (n-2) F's plus one).

WITH RECURSIVE fibonacci_generator AS
(
  SELECT
    1 AS i,
    0::bigint AS n,
    0::bigint AS sum
  UNION ALL
  SELECT
    i + 1,
    sum + 1,
    sum + n
  FROM fibonacci_generator
  WHERE i < 90
)

SELECT
  n AS number
FROM fibonacci_generator;
