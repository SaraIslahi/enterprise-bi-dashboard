CREATE TABLE public.dim_product (
  product_id    BIGSERIAL PRIMARY KEY,
  product_name  VARCHAR(150) NOT NULL,
  category      VARCHAR(80),
  brand         VARCHAR(80)          
);