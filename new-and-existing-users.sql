-- Calculate the share of new and existing users.
-- https://platform.stratascratch.com/coding/2028-new-and-existing-users

SELECT
  month,
  new / (new + existing) AS share_new_users,
  existing / (new + existing) AS share_existing_users
FROM (
  SELECT
    DATE_PART('month', c.time_id) AS month,
    COUNT(DISTINCT CASE WHEN p.user_id IS NULL THEN c.user_id END)::numeric AS new,
    COUNT(DISTINCT p.user_id)::numeric AS existing
  FROM fact_events c -- current
  LEFT JOIN fact_events p -- previous
    ON c.user_id = p.user_id
    AND DATE_PART('month', c.time_id) > DATE_PART('month', p.time_id)
  GROUP BY DATE_PART('month', c.time_id)
) user_count;
