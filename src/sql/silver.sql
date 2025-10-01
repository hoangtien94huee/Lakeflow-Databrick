-- Silver Layer - Data Cleaning & Validation
-- This SQL script cleans and validates bronze data, applying data quality rules and transformations.

CREATE OR REFRESH STREAMING LIVE TABLE silver_table (
  CONSTRAINT valid_sales_amount EXPECT (sales_amount > 0) ON VIOLATION DROP ROW,
  CONSTRAINT valid_quantity EXPECT (quantity > 0) ON VIOLATION DROP ROW,
  CONSTRAINT valid_date EXPECT (transaction_date IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_category EXPECT (category IS NOT NULL) ON VIOLATION DROP ROW,
  CONSTRAINT valid_product EXPECT (product_name IS NOT NULL) ON VIOLATION DROP ROW
)
COMMENT "Cleaned and validated sales data - Silver Layer"
TBLPROPERTIES ("quality" = "silver", "pipelines.autoOptimize.zOrderCols" = "category,transaction_date")
AS SELECT
  transaction_id,
  TO_DATE(date, 'yyyy-MM-dd') AS transaction_date,
  UPPER(TRIM(category)) AS category,
  TRIM(product_name) AS product_name,
  sales_amount,
  quantity,
  customer_id,
  sales_amount * quantity AS total_amount,
  ingestion_timestamp,
  current_timestamp() AS processed_timestamp
FROM STREAM(LIVE.bronze_table)
WHERE 
  sales_amount > 0
  AND quantity > 0
  AND date IS NOT NULL
  AND category IS NOT NULL
  AND product_name IS NOT NULL;
-- MAGIC 
-- MAGIC ## Transformations Applied
-- MAGIC 
-- MAGIC - Date string converted to DATE type
-- MAGIC - Category normalized to uppercase
-- MAGIC - Whitespace trimmed from text fields
-- MAGIC - Calculated field: total_amount = sales_amount * quantity
-- MAGIC - Added processed_timestamp for auditing