-- Gold Report SQL - Summary Tables for Power BI
-- This SQL script creates summary and reporting tables optimized for Power BI and other BI tools.

CREATE OR REFRESH LIVE TABLE gold_report_sql
COMMENT "Summary sales report with totals and averages per category - Ready for Power BI"
TBLPROPERTIES ("quality" = "gold", "business_domain" = "executive_reporting")
AS SELECT
  category,
  total_sales,
  total_transactions,
  avg_transaction_value,
  total_quantity_sold,
  unique_customers,
  -- Additional calculated metrics for reporting
  ROUND(total_sales / SUM(total_sales) OVER() * 100, 2) AS sales_percentage,
  ROUND(total_transactions / SUM(total_transactions) OVER() * 100, 2) AS transaction_percentage,
  CASE 
    WHEN total_sales >= (SELECT AVG(total_sales) FROM LIVE.gold_table) 
    THEN 'High Performer'
    ELSE 'Standard Performer'
  END AS performance_category,
  -- Revenue per customer
  ROUND(total_sales / NULLIF(unique_customers, 0), 2) AS revenue_per_customer,
  -- Quantity per transaction
  ROUND(total_quantity_sold / NULLIF(total_transactions, 0), 2) AS avg_quantity_per_transaction,
  calculation_timestamp,
  current_timestamp() AS report_generated_at
FROM LIVE.gold_table
ORDER BY total_sales DESC;

CREATE OR REFRESH LIVE TABLE executive_summary
COMMENT "Executive summary with overall business metrics"
TBLPROPERTIES ("quality" = "gold", "business_domain" = "executive_dashboard")
AS SELECT
  'Overall Business Metrics' AS metric_group,
  SUM(total_sales) AS total_revenue,
  SUM(total_transactions) AS total_transactions_count,
  ROUND(AVG(avg_transaction_value), 2) AS avg_transaction_value_overall,
  SUM(unique_customers) AS total_unique_customers,
  SUM(total_quantity_sold) AS total_items_sold,
  COUNT(DISTINCT category) AS total_categories,
  ROUND(SUM(total_sales) / NULLIF(SUM(total_transactions), 0), 2) AS overall_avg_per_transaction,
  ROUND(SUM(total_sales) / NULLIF(SUM(unique_customers), 0), 2) AS overall_revenue_per_customer,
  current_timestamp() AS report_timestamp
FROM LIVE.gold_table;

CREATE OR REFRESH LIVE TABLE category_ranking
COMMENT "Category performance ranking for dashboards"
TBLPROPERTIES ("quality" = "gold", "business_domain" = "category_analytics")
AS SELECT
  category,
  total_sales,
  total_transactions,
  unique_customers,
  total_quantity_sold,
  RANK() OVER (ORDER BY total_sales DESC) AS revenue_rank,
  RANK() OVER (ORDER BY total_transactions DESC) AS transaction_rank,
  RANK() OVER (ORDER BY unique_customers DESC) AS customer_rank,
  ROUND(100.0 * total_sales / SUM(total_sales) OVER (), 2) AS revenue_percentage,
  ROUND(100.0 * total_transactions / SUM(total_transactions) OVER (), 2) AS transaction_percentage,
  calculation_timestamp
FROM LIVE.gold_table
ORDER BY revenue_rank;