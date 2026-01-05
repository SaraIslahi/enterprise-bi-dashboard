INSERT INTO dim_date (
  date,
  day,
  month,
  year,
  day_name,
  month_name
)
SELECT
  d::date,
  EXTRACT(DAY FROM d)::INT,
  EXTRACT(MONTH FROM d)::INT,
  EXTRACT(YEAR FROM d)::INT,
  TRIM(TO_CHAR(d, 'Day')),
  TRIM(TO_CHAR(d, 'Month'))
FROM generate_series(
  '2024-01-01'::date,
  '2024-12-31'::date,
  '1 day'
) AS d;
