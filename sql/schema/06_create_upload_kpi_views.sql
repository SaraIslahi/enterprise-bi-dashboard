/* ============================================================
   CLEANED UPLOAD KPI VIEWS (staging_sales)
   - Null handling: COALESCE for dimensions + revenue
   - Revenue consistency: filter negative/NULL revenue
   - Deduplication: keep 1 row per (order_id, order_date::date, country)
     Adjust PARTITION BY based on CSV columns.
   ============================================================ */


/* KPI: Total Revenue */
CREATE OR REPLACE VIEW upload_kpi_total_revenue AS
WITH staging_dedup AS (
  SELECT
    s.*,
    ROW_NUMBER() OVER (
      PARTITION BY s.order_id, (s.order_date::date), COALESCE(s.country, 'Unknown')
      ORDER BY s.order_id
    ) AS rn
  FROM staging_sales s
  WHERE s.revenue IS NOT NULL
    AND s.revenue >= 0
)
SELECT
  COALESCE(SUM(COALESCE(revenue, 0)), 0) AS total_revenue
FROM staging_dedup
WHERE rn = 1;


/* KPI: Number of Orders */
CREATE OR REPLACE VIEW upload_kpi_orders AS
WITH staging_dedup AS (
  SELECT
    s.*,
    ROW_NUMBER() OVER (
      PARTITION BY s.order_id, (s.order_date::date), COALESCE(s.country, 'Unknown')
      ORDER BY s.order_id
    ) AS rn
  FROM staging_sales s
  WHERE s.order_id IS NOT NULL
)
SELECT
  COUNT(DISTINCT order_id) AS orders
FROM staging_dedup
WHERE rn = 1;


/* KPI: Average Order Value (AOV) */
CREATE OR REPLACE VIEW upload_kpi_aov AS
WITH staging_dedup AS (
  SELECT
    s.*,
    ROW_NUMBER() OVER (
      PARTITION BY s.order_id, (s.order_date::date), COALESCE(s.country, 'Unknown')
      ORDER BY s.order_id
    ) AS rn
  FROM staging_sales s
  WHERE s.order_id IS NOT NULL
    AND s.revenue IS NOT NULL
    AND s.revenue >= 0
)
SELECT
  COALESCE(
    SUM(COALESCE(revenue, 0)) / NULLIF(COUNT(DISTINCT order_id), 0),
    0
  ) AS aov
FROM staging_dedup
WHERE rn = 1;


/* KPI: Revenue by country */
CREATE OR REPLACE VIEW upload_kpi_revenue_by_country AS
WITH staging_dedup AS (
  SELECT
    s.*,
    ROW_NUMBER() OVER (
      PARTITION BY s.order_id, (s.order_date::date), COALESCE(s.country, 'Unknown')
      ORDER BY s.order_id
    ) AS rn
  FROM staging_sales s
  WHERE s.revenue IS NOT NULL
    AND s.revenue >= 0
)
SELECT
  COALESCE(country, 'Unknown') AS country,
  SUM(COALESCE(revenue, 0)) AS revenue
FROM staging_dedup
WHERE rn = 1
GROUP BY COALESCE(country, 'Unknown')
ORDER BY revenue DESC;


/* KPI: Revenue daily */
CREATE OR REPLACE VIEW upload_kpi_revenue_daily AS
WITH staging_dedup AS (
  SELECT
    s.*,
    ROW_NUMBER() OVER (
      PARTITION BY s.order_id, (s.order_date::date), COALESCE(s.country, 'Unknown')
      ORDER BY s.order_id
    ) AS rn
  FROM staging_sales s
  WHERE s.revenue IS NOT NULL
    AND s.revenue >= 0
    AND s.order_date IS NOT NULL
)
SELECT
  (order_date::date) AS date,
  SUM(COALESCE(revenue, 0)) AS revenue
FROM staging_dedup
WHERE rn = 1
GROUP BY (order_date::date)
ORDER BY date;
