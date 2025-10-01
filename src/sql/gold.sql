-- Gold Layer - Business Aggregations
-- This SQL script creates aggregated business metrics from the silver layer data.

CREATE OR REFRESH LIVE TABLE gold_table
COMMENT "Aggregated sales metrics by category - Gold Layer"
TBLPROPERTIES ("quality" = "gold", "business_domain" = "sales_analytics")
AS SELECT
  category,
  COUNT(transaction_id) AS total_transactions,
  SUM(total_amount) AS total_sales,
  ROUND(AVG(total_amount), 2) AS avg_transaction_value,
  SUM(quantity) AS total_quantity_sold,
  COUNT(DISTINCT customer_id) AS unique_customers,
  MIN(transaction_date) AS first_transaction_date,
  MAX(transaction_date) AS last_transaction_date,
  current_timestamp() AS calculation_timestamp
FROM LIVE.silver_table
GROUP BY category
ORDER BY total_sales DESC;