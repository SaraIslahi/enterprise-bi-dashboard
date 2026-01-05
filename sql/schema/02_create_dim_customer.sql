CREATE TABLE public.dim_customer (
  customer_id    BIGSERIAL PRIMARY KEY,
  customer_name  VARCHAR(150) NOT NULL,
  country        VARCHAR(80),
  region         VARCHAR(80),
  segment        VARCHAR(80)
);