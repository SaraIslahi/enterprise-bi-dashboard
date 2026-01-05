CREATE TABLE public.fact_sales (
  sale_id      BIGSERIAL PRIMARY KEY,

  date_id      INTEGER NOT NULL,
  customer_id  BIGINT  NOT NULL,
  product_id   BIGINT  NOT NULL,

  order_id     BIGINT,
  quantity     INTEGER NOT NULL CHECK (quantity >= 0),
  unit_price   NUMERIC(12,2) NOT NULL CHECK (unit_price >= 0),

  -- Option A (recommended): revenue computed automatically (prevents bad data)
  revenue      NUMERIC(14,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,

  CONSTRAINT fk_fact_date
    FOREIGN KEY (date_id) REFERENCES public.dim_date(date_id),

  CONSTRAINT fk_fact_customer
    FOREIGN KEY (customer_id) REFERENCES public.dim_customer(customer_id),

  CONSTRAINT fk_fact_product
    FOREIGN KEY (product_id) REFERENCES public.dim_product(product_id)
);
