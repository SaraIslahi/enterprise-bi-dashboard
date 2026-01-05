# Enterprise BI Data Warehouse

## Live Demo

👉 **[View the Enterprise BI Dashboard](https://enterprise-bi-dashboard-production.up.railway.app)**

## What is the project?

This project implements a **Business Intelligence (BI) data warehouse** designed to analyze a company’s sales performance over time.  
The database stores sales data in a structured format that supports analytical queries such as revenue trends, customer analysis, and product performance.  
It enables decision-makers to evaluate business performance using aggregated sales metrics across multiple dimensions.

---

## What schema is used and why?

The project uses a **star schema**.

A star schema consists of:

- One central **fact table** (`fact_sales`) that stores measurable business data such as quantity and revenue
- Multiple **dimension tables** (`dim_date`, `dim_customer`, `dim_product`) that provide descriptive context

This schema was chosen because it:

- Is optimized for analytical queries
- Simplifies joins between fact and dimensions
- Improves query performance for aggregations
- Is intuitive and widely used in BI and data warehousing systems

---

## How to run the project (commands)

### Connect to the database

```bash
psql enterprise_bi
```

### Create tables (schema)

```bash
psql enterprise_bi < sql/schema/01_create_dim_date.sql
psql enterprise_bi < sql/schema/02_create_dim_customer.sql
psql enterprise_bi < sql/schema/03_create_dim_product.sql
psql enterprise_bi < sql/schema/04_create_fact_sales.sql
```

### Insert data

```bash
psql enterprise_bi < sql/data/01_insert_dim_date.sql
psql enterprise_bi < sql/data/02_insert_dim_customer.sql
psql enterprise_bi < sql/data/03_insert_dim_product.sql
psql enterprise_bi < sql/data/04_insert_fact_sales.sql
```

---

## Project Structure

```text
bi_project/
├── sql/
│   ├── schema/     -- Table creation scripts
│   ├── data/       -- Data insertion scripts
│   ├── queries/    -- Analytical SQL queries
│   └── utils/      -- Utility scripts (truncate, drop)
├── docs/
│   ├── data_dictionary.md
│   └── project_report.md
├── dumps/
│   ├── enterprise_bi_schema.sql
│   └── enterprise_bi_full.sql
└── README.md
```

### Fact Table Grain

Each row in the fact_sales table represents a single sales event for one product sold to one customer on one specific date.

## Example analytics queries

### Total revenue by month

```sql
SELECT
  d.year,
  d.month_name,
  SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;
```

### Revenue by country

```sql
SELECT
  c.country,
  SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.country
ORDER BY total_revenue DESC;
```

### Top products by revenue

```sql
SELECT
  p.product_name,
  SUM(f.revenue) AS total_revenue
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;
```

---

## Technologies Used

- PostgreSQL

- SQL (DDL, DML, analytical queries)

- psql command-line interface

- VS Code for project organization

---

## Limitations and Assumptions

- The data represents a simplified sales model for analytical purposes.

- Historical changes in customer or product attributes are not tracked.

- The dataset size is limited and intended for learning and demonstration.

---

## Future Improvements

- Add additional dimensions such as location or sales channel

- Implement slowly changing dimensions for customers and products

- Connect the database to a BI tool such as Power BI or Tableau

- Automate data loading using an ETL pipeline

---

## Key Insights

Based on the analytical queries executed on the data warehouse, the following insights can be derived:

- **Sales performance over time:**
  Revenue can be analyzed by month and year, allowing the identification of sales trends and periods of growth or decline.

- **Customer contribution to revenue:**
  Analysis by customer attributes such as country, region, and segment highlights which customer groups contribute the most to total revenue.

- **Product performance:**
  Aggregation by product, category, or brand identifies top-performing products and supports decisions related to inventory and pricing.

- **Multi-dimensional analysis:**
  The star schema enables combining multiple dimensions in a single query, providing deeper insights such as identifying top products by region and time period.

---

📚 What I Learned

1. Star Schema Design for Business Intelligence

Through this project, I learned how to design and implement a star schema for analytical workloads.
I understood the importance of separating fact tables (quantitative measures such as revenue and quantity) from dimension tables (descriptive attributes such as date, customer, and product).
This design improved query performance and made analytical queries easier to write and understand.

---

2. Building KPI Views in SQL

I learned how to create KPI views directly in the database using SQL.
Instead of calculating metrics in the application layer, I implemented reusable views such as:

Total revenue

Total number of orders

Average order value

Revenue by country

Revenue over time

## This approach follows best practices in BI systems by centralizing business logic in the data warehouse and ensuring consistent metrics across tools.

3. Backend ↔ Frontend Data Flow

This project helped me understand the full data flow of a BI dashboard:

Data is stored and aggregated in PostgreSQL (fact & dimension tables)

KPI views expose analytical results

Django queries these views in the backend

Results are serialized into JSON

The frontend (Chart.js) consumes the JSON and renders interactive charts

This gave me a clear understanding of how backend systems and frontend visualization layers communicate in real-world analytics applications.

---

4. Debugging SQL and JavaScript Integration

I gained hands-on experience debugging real integration issues, including:

SQL errors caused by mismatched column names in views

Backend crashes due to incorrect queries

JSON serialization problems between Django and JavaScript

Chart rendering issues caused by mismatched HTML and JavaScript IDs

By resolving these issues, I learned how to systematically debug problems across database, backend, and frontend layers, which is an essential skill for data engineers and BI developers.

---

## KPI Design and Incremental Analytics Methodology

The Business Intelligence dashboard developed in this project follows an **incremental Key Performance Indicator (KPI) design methodology**, aligned with established data warehousing and Business Intelligence (BI) best practices.

Rather than implementing all analytical indicators simultaneously, the dashboard was developed in **progressive stages**, ensuring correctness, interpretability, and robustness of the analytical pipeline.

---

## Stage 1 — Financial Performance KPIs (Implemented)

The first stage of the dashboard focuses on **core financial KPIs**, which represent the foundational layer of analytical insight in most Business Intelligence systems.

### Implemented KPIs

- **Total Revenue**  
  Measures the aggregate monetary value generated by all recorded transactions.

- **Total Orders**  
  Represents the number of distinct transactional events within the dataset.

- **Average Order Value (AOV)**  
  Computes the mean revenue per transaction, providing insight into purchasing behavior and transaction value.

### Rationale for Stage 1

These KPIs were intentionally implemented as the initial analytical layer because they:

- Are universally applicable across sales-oriented datasets
- Depend only on transactional data, independent of complex dimensional modeling
- Enable early validation of data ingestion, aggregation logic, and query correctness
- Constitute the minimum analytical baseline commonly found in professional BI dashboards

---

## Stage 2 — Customer and Product-Level KPIs (Planned)

Upon validation of the financial KPI layer, the dashboard is designed to be extended with **customer- and product-oriented KPIs**, including:

- Number of unique customers
- Average revenue per customer
- Total quantity of items sold
- Product-level revenue rankings

These indicators rely on clearly defined dimensional attributes (e.g., customer and product dimensions) and therefore require a **stable and validated data model** before implementation.

---

## Stage 3 — Strategic and Temporal KPIs (Future Work)

The final stage of the analytical framework focuses on **strategic and time-based insights**, such as:

- Cumulative revenue trends
- Revenue growth analysis
- Seasonal patterns
- Longitudinal performance comparisons

These KPIs support **higher-level decision-making and long-term business planning**, extending beyond descriptive analytics into trend and performance evaluation.

---

## Design Rationale

The staged KPI implementation reflects **standard BI development practices**, where analytical systems are constructed incrementally:

1. **Financial validation of transactional data**
2. **Dimensional enrichment and behavioral analysis**
3. **Strategic and temporal performance assessment**

This methodology ensures analytical reliability, adaptability to varying dataset structures, and alignment with professional Business Intelligence system design principles.

---

## Summary

At its current state, the dashboard fully implements **Stage 1: Financial Performance KPIs**, establishing a solid analytical foundation that can be systematically expanded with additional customer, product, and strategic indicators.

---

## Course-to-Feature Mapping

| Course / Discipline                          | Concept Applied                            | Implementation in the Project                                                                                                                                    |
| -------------------------------------------- | ------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Performance Measurement**                  | Key Performance Indicators (KPIs)          | Definition and computation of financial KPIs such as Total Revenue, Total Orders, and Average Order Value (AOV) to measure business performance.                 |
| **Business Intelligence & Data Warehousing** | Star Schema Design                         | Use of a fact table (`fact_sales`) and dimension tables (`dim_date`, `dim_customer`, `dim_product`) to support analytical queries and multidimensional analysis. |
| **Statistics & Data Analysis**               | Aggregations and Trend Analysis            | Application of descriptive statistics through aggregation functions (SUM, COUNT, AVERAGE) and temporal grouping to analyze revenue trends and distributions.     |
| **Big Data Foundations**                     | Data Pipelines and Processing Stages       | Implementation of a data ingestion pipeline including CSV upload, data cleaning, staging tables, aggregation, and visualization layers.                          |
| **Digital Economics**                        | Enterprise Data Flows and Decision Support | Simulation of enterprise-scale data flows that transform raw operational sales data into structured information and actionable business insights.                |
