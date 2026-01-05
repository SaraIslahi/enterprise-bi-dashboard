/* ============================================================
   CLEANED KPI VIEWS (Null handling + Revenue validation + Dedup)
   Notes:
   - Null handling: COALESCE for dimensions + revenue
   - Revenue consistency: filter out negative revenue
   - Deduplication: keep only one row per (order_id, product_id, customer_id, date_id)
     Adjust the PARTITION BY if your notion of "duplicate" differs.
   ============================================================ */


/* KPI: Total Revenue */
CREATE OR REPLACE VIEW kpi_total_revenue AS
WITH fact_dedup AS (
  SELECT
    f.*,
    ROW_NUMBER() OVER (
      PARTITION BY f.order_id, f.product_id, f.customer_id, f.date_id
      ORDER BY f.order_id
    ) AS rn
  FROM fact_sales f
  WHERE f.revenue IS NOT NULL
    AND f.revenue >= 0
)
SELECT
  SUM(COALESCE(revenue, 0)) AS total_revenue
FROM fact_dedup
WHERE rn = 1;


/* KPI: Number of Orders */
CREATE OR REPLACE VIEW kpi_orders AS
WITH fact_dedup AS (
  SELECT
    f.*,
    ROW_NUMBER() OVER (
      PARTITION BY f.order_id, f.product_id, f.customer_id, f.date_id
      ORDER BY f.order_id
    ) AS rn
  FROM fact_sales f
  WHERE f.order_id IS NOT NULL
)
SELECT
  COUNT(DISTINCT order_id) AS orders
FROM fact_dedup
WHERE rn = 1;


/* KPI: Average Order Value (AOV) */
CREATE OR REPLACE VIEW kpi_aov AS
WITH fact_dedup AS (
  SELECT
    f.*,
    ROW_NUMBER() OVER (
      PARTITION BY f.order_id, f.product_id, f.customer_id, f.date_id
      ORDER BY f.order_id
    ) AS rn
  FROM fact_sales f
  WHERE f.order_id IS NOT NULL
    AND f.revenue IS NOT NULL
    AND f.revenue >= 0
)
SELECT
  SUM(COALESCE(revenue, 0)) / NULLIF(COUNT(DISTINCT order_id), 0) AS aov
FROM fact_dedup
WHERE rn = 1;


/* KPI: Revenue by day */
CREATE OR REPLACE VIEW kpi_revenue_daily AS
WITH fact_dedup AS (
  SELECT
    f.*,
    ROW_NUMBER() OVER (
      PARTITION BY f.order_id, f.product_id, f.customer_id, f.date_id
      ORDER BY f.order_id
    ) AS rn
  FROM fact_sales f
  WHERE f.revenue IS NOT NULL
    AND f.revenue >= 0
)
SELECT
  COALESCE(d.date, DATE '1900-01-01') AS date,
  SUM(COALESCE(f.revenue, 0)) AS revenue
FROM fact_dedup f
LEFT JOIN dim_date d ON d.date_id = f.date_id
WHERE f.rn = 1
GROUP BY COALESCE(d.date, DATE '1900-01-01')
ORDER BY date;


/* KPI: Revenue by product */
CREATE OR REPLACE VIEW kpi_revenue_by_product AS
WITH fact_dedup AS (
  SELECT
    f.*,
    ROW_NUMBER() OVER (
      PARTITION BY f.order_id, f.product_id, f.customer_id, f.date_id
      ORDER BY f.order_id
    ) AS rn
  FROM fact_sales f
  WHERE f.revenue IS NOT NULL
    AND f.revenue >= 0
)
SELECT
  COALESCE(p.product_name, 'Unknown product') AS product_name,
  SUM(COALESCE(f.revenue, 0)) AS revenue
FROM fact_dedup f
LEFT JOIN dim_product p ON p.product_id = f.product_id
WHERE f.rn = 1
GROUP BY COALESCE(p.product_name, 'Unknown product')
ORDER BY revenue DESC;


/* KPI: Revenue by region (country) */
CREATE OR REPLACE VIEW kpi_revenue_by_region AS
WITH fact_dedup AS (
  SELECT
    f.*,
    ROW_NUMBER() OVER (
      PARTITION BY f.order_id, f.product_id, f.customer_id, f.date_id
      ORDER BY f.order_id
    ) AS rn
  FROM fact_sales f
  WHERE f.revenue IS NOT NULL
    AND f.revenue >= 0
)
SELECT
  COALESCE(c.country, 'Unknown') AS country,
  SUM(COALESCE(f.revenue, 0)) AS revenue
FROM fact_dedup f
LEFT JOIN dim_customer c ON c.customer_id = f.customer_id
WHERE f.rn = 1
GROUP BY COALESCE(c.country, 'Unknown')
ORDER BY revenue DESC;
