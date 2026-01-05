-- truncate_all_tables.sql
-- Purpose: Remove all data from the data warehouse tables

TRUNCATE TABLE fact_sales RESTART IDENTITY CASCADE;

TRUNCATE TABLE dim_product RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_customer RESTART IDENTITY CASCADE;
TRUNCATE TABLE dim_date RESTART IDENTITY CASCADE;
