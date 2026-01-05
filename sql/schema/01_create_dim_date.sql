DROP TABLE IF EXISTS dim_date CASCADE;
CREATE TABLE dim_date (
  date_id     INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  date        DATE NOT NULL UNIQUE,

  day         SMALLINT NOT NULL CHECK (day BETWEEN 1 AND 31),
  month       SMALLINT NOT NULL CHECK (month BETWEEN 1 AND 12),
  year        SMALLINT NOT NULL CHECK (year BETWEEN 1900 AND 2100),

  day_name    VARCHAR(10) NOT NULL,
  month_name  VARCHAR(10) NOT NULL
);

-- Optional: indexes for common filters/group-bys (date is already UNIQUE)
CREATE INDEX idx_dim_date_year  ON dim_date(year);
CREATE INDEX idx_dim_date_month ON dim_date(month);