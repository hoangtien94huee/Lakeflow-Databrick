-- Sample Queries for Testing Lakeflow Pipeline Results
-- Run these queries in Databricks SQL Editor after pipeline completes

-- ============================================================================
-- BRONZE LAYER QUERIES
-- ============================================================================

-- Check bronze table data
SELECT * FROM main.demo.bronze_table LIMIT 10;

-- Count records in bronze
SELECT COUNT(*) as total_records FROM main.demo.bronze_table;

-- Check data quality in bronze
SELECT 
    category,
    COUNT(*) as record_count
FROM main.demo.bronze_table
GROUP BY category
ORDER BY record_count DESC;

-- ============================================================================
-- SILVER LAYER QUERIES
-- ============================================================================

-- Check silver table data
SELECT * FROM main.demo.silver_table LIMIT 10;

-- Compare bronze vs silver record counts (to see rejected records)
SELECT 
    'Bronze' as layer,
    COUNT(*) as record_count
FROM main.demo.bronze_table
UNION ALL
SELECT 
    'Silver' as layer,
    COUNT(*) as record_count
FROM main.demo.silver_table;

-- Check silver data quality metrics
SELECT 
    category,
    COUNT(*) as transactions,
    SUM(total_amount) as total_sales,
    AVG(total_amount) as avg_transaction,
    MIN(transaction_date) as first_date,
    MAX(transaction_date) as last_date
FROM main.demo.silver_table
GROUP BY category
ORDER BY total_sales DESC;

-- ============================================================================
-- GOLD LAYER QUERIES
-- ============================================================================

-- View gold table summary
SELECT * FROM main.demo.gold_table
ORDER BY total_sales DESC;

-- Top performing category
SELECT 
    category,
    total_sales,
    total_transactions,
    unique_customers
FROM main.demo.gold_table
ORDER BY total_sales DESC
LIMIT 1;

-- Category comparison
SELECT 
    category,
    CONCAT('$', FORMAT_NUMBER(total_sales, 2)) as revenue,
    total_transactions,
    CONCAT('$', FORMAT_NUMBER(avg_transaction_value, 2)) as avg_value,
    unique_customers,
    ROUND(total_sales / SUM(total_sales) OVER() * 100, 1) as revenue_share_pct
FROM main.demo.gold_table
ORDER BY total_sales DESC;

-- ============================================================================
-- GOLD REPORT SQL QUERIES (Power BI Ready)
-- ============================================================================

-- View full report with performance categories
SELECT * FROM main.demo.gold_report_sql
ORDER BY sales_percentage DESC;

-- Executive summary metrics
SELECT * FROM main.demo.executive_summary;

-- Category rankings
SELECT 
    category,
    revenue_rank,
    transaction_rank,
    customer_rank,
    CONCAT(revenue_percentage, '%') as revenue_share,
    CONCAT('$', FORMAT_NUMBER(total_sales, 2)) as revenue
FROM main.demo.category_ranking
ORDER BY revenue_rank;

-- ============================================================================
-- ADVANCED ANALYTICS QUERIES
-- ============================================================================

-- High performers vs standard performers
SELECT 
    performance_category,
    COUNT(*) as category_count,
    SUM(total_sales) as combined_sales,
    AVG(avg_transaction_value) as avg_transaction
FROM main.demo.gold_report_sql
GROUP BY performance_category;

-- Customer efficiency by category (revenue per customer)
SELECT 
    category,
    revenue_per_customer,
    unique_customers,
    total_sales,
    RANK() OVER (ORDER BY revenue_per_customer DESC) as efficiency_rank
FROM main.demo.gold_report_sql
ORDER BY revenue_per_customer DESC;

-- Transaction density (items per transaction)
SELECT 
    category,
    avg_quantity_per_transaction,
    total_transactions,
    total_quantity_sold
FROM main.demo.gold_report_sql
ORDER BY avg_quantity_per_transaction DESC;

-- ============================================================================
-- DATA VALIDATION QUERIES
-- ============================================================================

-- Check for any null values in gold layer
SELECT 
    COUNT(*) as total_rows,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) as null_categories,
    SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) as null_sales,
    SUM(CASE WHEN total_transactions IS NULL THEN 1 ELSE 0 END) as null_transactions
FROM main.demo.gold_table;

-- Verify calculations are correct
SELECT 
    category,
    total_sales,
    total_transactions,
    avg_transaction_value,
    ROUND(total_sales / total_transactions, 2) as calculated_avg,
    CASE 
        WHEN ABS(avg_transaction_value - (total_sales / total_transactions)) < 0.01 
        THEN 'PASS' 
        ELSE 'FAIL' 
    END as validation_status
FROM main.demo.gold_table;

-- Check timestamp freshness
SELECT 
    category,
    calculation_timestamp,
    DATEDIFF(CURRENT_TIMESTAMP(), calculation_timestamp) as age_in_days
FROM main.demo.gold_table
ORDER BY calculation_timestamp DESC;

-- ============================================================================
-- EXPORT QUERIES FOR POWER BI
-- ============================================================================

-- Simple view for Power BI import
CREATE OR REPLACE VIEW main.demo.powerbi_sales_summary AS
SELECT 
    category,
    total_sales as Revenue,
    total_transactions as Transactions,
    avg_transaction_value as AvgTransactionValue,
    unique_customers as Customers,
    sales_percentage as RevenueShare,
    performance_category as PerformanceLevel
FROM main.demo.gold_report_sql;

-- Executive KPIs for Power BI cards
CREATE OR REPLACE VIEW main.demo.powerbi_kpis AS
SELECT 
    total_revenue,
    total_transactions_count,
    avg_transaction_value_overall,
    total_unique_customers,
    total_items_sold,
    overall_revenue_per_customer
FROM main.demo.executive_summary;

-- Show the Power BI ready views
SELECT * FROM main.demo.powerbi_sales_summary;
SELECT * FROM main.demo.powerbi_kpis;