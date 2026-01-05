SELECT
  d.year,
  d.month,
  d.month_name,
  SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_date d
  ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
