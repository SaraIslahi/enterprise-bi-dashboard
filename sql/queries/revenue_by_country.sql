SELECT
  c.country,
  SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_customer c
  ON f.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;
