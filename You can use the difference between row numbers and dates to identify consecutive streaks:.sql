WITH daily_sales AS (
  SELECT
    DATE(order_date) AS order_day,
    SUM(gmv) AS daily_revenue
  FROM `project.dataset.sales`
  GROUP BY order_day
),
streaks AS (
  SELECT
    order_day,
    daily_revenue,
    DATE_DIFF(order_day, ROW_NUMBER() OVER (ORDER BY order_day), DAY) AS grp
  FROM daily_sales
)
SELECT
  order_day,
  AVG(daily_revenue) OVER (
    PARTITION BY grp
    ORDER BY order_day
    ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
  ) AS avg_revenue_3_days
FROM streaks
ORDER BY order_day
