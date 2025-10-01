-- Bronze Layer - Data Ingestion
-- This SQL script ingests raw data from CSV files into the bronze table using Delta Live Tables.

CREATE OR REFRESH STREAMING LIVE TABLE bronze_table
COMMENT "Raw sales data ingested from CSV files - Bronze Layer"
TBLPROPERTIES ("quality" = "bronze", "pipelines.autoOptimize.zOrderCols" = "transaction_id")
AS SELECT
  transaction_id,
  date,
  category,
  product_name,
  CAST(sales_amount AS DOUBLE) AS sales_amount,
  CAST(quantity AS INT) AS quantity,
  customer_id,
  current_timestamp() AS ingestion_timestamp,
  'input.csv' AS source_file
FROM cloud_files(
  '/Volumes/main/default/demo/',
  'csv',
  map(
    'header', 'true',
    'inferSchema', 'true',
    'cloudFiles.inferColumnTypes', 'true'
  )
);