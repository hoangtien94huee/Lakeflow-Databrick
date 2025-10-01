# 🚀 Lakeflow Report Demo - Databricks Asset Bundles

**Demo project hoàn chỉnh** về Databricks Asset Bundles với Delta Live Tables để tạo pipeline xử lý dữ liệu end-to-end: Ingestion → Transformation → Reporting → Power BI.

---

## 📋 Mục Lục

1. [Tổng Quan](#-tổng-quan)
2. [Quick Start - 5 Phút](#-quick-start---5-phút)
3. [Cài Đặt Chi Tiết](#-cài-đặt-chi-tiết)
4. [Giải Quyết DBFS Disabled](#-giải-quyết-dbfs-disabled)
5. [Databricks CLI Commands](#-databricks-cli-commands)
6. [Architecture & Data Flow](#-architecture--data-flow)
7. [Test & Validation](#-test--validation)
8. [Power BI Integration](#-power-bi-integration)
9. [Troubleshooting](#-troubleshooting)
10. [Advanced Topics](#-advanced-topics)

---

## 📦 Tổng Quan

### Cấu Trúc Project

```
lakeflow-demo/
├── 📄 databricks.yml                  # Bundle configuration
├── 📂 resources/
│   └── pipeline.yml                   # 2 pipeline definitions
├── 📂 src/
│   # SQL Files - Pure SQL Pipeline (RECOMMENDED)
│   ├── bronze.sql                     # Ingest CSV → Bronze
│   ├── silver.sql                     # Clean & validate → Silver
│   ├── gold.sql                       # Aggregate → Gold
│   ├── gold_report_sql.sql            # Report tables
│   # Python Notebooks - Alternative Pipeline
│   ├── bronze_to_silver.ipynb
│   ├── silver_to_gold.ipynb
│   └── gold_report_python.ipynb
├── 🐍 generate_sample_data.py         # Test data generator
├── 📊 test_queries.sql                # Validation SQL
└── 📖 README.md                       # This file
```

### Pipeline Versions

| Version | Files | Recommended For |
|---------|-------|-----------------|
| **SQL Pipeline** | `bronze.sql` → `silver.sql` → `gold.sql` → `gold_report_sql.sql` | ✅ Production, pure SQL workflows |
| **Python Pipeline** | `*.ipynb` notebooks | Data science, visualizations |

### Data Flow

```
CSV File → Bronze (Raw) → Silver (Cleaned) → Gold (Aggregated) → Reports (Power BI Ready)
```

### Tables Created

| Layer | Table Name | Description |
|-------|------------|-------------|
| 🥉 Bronze | `main.demo.bronze_table` | Raw CSV data |
| 🥈 Silver | `main.demo.silver_table` | Cleaned & validated |
| 🥇 Gold | `main.demo.gold_table` | Aggregated by category |
| 📊 Report | `main.demo.gold_report_sql` | Power BI metrics |
| 📈 Report | `main.demo.executive_summary` | Executive KPIs |
| 🏆 Report | `main.demo.category_ranking` | Performance ranks |

---

## ⚡ Quick Start - 5 Phút

### Bước 1: Cài Databricks CLI (1 phút)

```bash
# Install
pip install databricks-cli

# Verify
databricks -v
# Expected: Databricks CLI v0.270.0
```

### Bước 2: Authenticate (1 phút)

```bash
# Method 1: Browser login (Recommended for v0.270.0+)
databricks auth login --host https://community.cloud.databricks.com

# Method 2: Token-based (Traditional)
databricks configure --token
# Host: https://community.cloud.databricks.com
# Token: <your-personal-access-token>

# Verify connection
databricks current-user me
```

**Tạo Personal Access Token:**
1. Login Databricks → User Settings (góc phải trên)
2. Developer → Access tokens → Generate new token
3. Copy token (chỉ hiển thị 1 lần!)

### Bước 3: Upload Dữ Liệu (1 phút)

```bash
# Generate sample data
python generate_sample_data.py
```

**⚠️ QUAN TRỌNG: Nếu gặp lỗi "Public DBFS root is disabled"**

Sử dụng Unity Catalog Volumes (xem [Section 4](#-giải-quyết-dbfs-disabled)):

```sql
-- Trong Databricks SQL Editor
CREATE SCHEMA IF NOT EXISTS main.demo;
CREATE VOLUME IF NOT EXISTS main.demo.data_volume;
```

Sau đó upload qua UI: **Catalog → main → demo → data_volume → Upload files**

**Nếu DBFS enabled:**
```bash
databricks fs mkdirs dbfs:/FileStore/demo/
databricks fs cp sample_sales_data.csv dbfs:/FileStore/demo/input.csv
```

### Bước 4: Deploy Pipeline (1 phút)

```bash
# Validate
databricks bundle validate

# Deploy
databricks bundle deploy -t dev
```

### Bước 5: Run Pipeline (1 phút)

```bash
# Run SQL pipeline
databricks bundle run report_pipeline_sql --monitor

# Or Python pipeline
databricks bundle run report_pipeline --monitor
```

### Bước 6: Verify Results

```sql
-- Trong Databricks SQL Editor
SELECT * FROM main.demo.gold_table;
SELECT * FROM main.demo.gold_report_sql;
SELECT * FROM main.demo.executive_summary;
```

✅ **Done! Pipeline đã chạy thành công!**

---

## 🔧 Cài Đặt Chi Tiết

### Prerequisites

- Python 3.8+
- Databricks workspace (Community Edition OK)
- Databricks CLI v0.270.0+
- Internet connection

### Step 1: Clone/Download Project

```bash
cd c:\inter-k\lakeflow-demo
# Or your project directory
```

### Step 2: Install Dependencies

```bash
# Install Databricks CLI
pip install databricks-cli

# Verify installation
databricks --version
```

### Step 3: Configure Authentication

#### Option A: Browser Login (New CLI v0.270.0+)

```bash
databricks auth login --host https://community.cloud.databricks.com
```

Browser sẽ mở và bạn login qua Databricks UI.

#### Option B: Token Configuration (Traditional)

```bash
databricks configure --token
```

Nhập:
- **Databricks Host**: `https://community.cloud.databricks.com`
- **Token**: `dapi_xxxxxxxxxxxx` (from User Settings)

#### Option C: Environment Variables

```powershell
# PowerShell
$env:DATABRICKS_HOST = "https://community.cloud.databricks.com"
$env:DATABRICKS_TOKEN = "dapi_your_token"
```

### Step 4: Generate Test Data

```bash
# Run Python script
python generate_sample_data.py
```

Output: `sample_sales_data.csv` với 100 transactions.

Sample data structure:
```csv
transaction_id,date,category,product_name,sales_amount,quantity,customer_id
TXN0001,2024-01-01,ELECTRONICS,Laptop,1200.00,1,CUST001
TXN0002,2024-01-02,CLOTHING,T-Shirt,25.99,2,CUST002
```

Categories: Electronics, Clothing, Books, Home & Garden, Sports

### Step 5: Upload Data

Chọn 1 trong các options:

#### Option A: Unity Catalog Volumes (RECOMMENDED - works everywhere)

```sql
-- 1. Create schema and volume (Databricks SQL Editor)
CREATE SCHEMA IF NOT EXISTS main.demo;
CREATE VOLUME IF NOT EXISTS main.demo.data_volume;
```

```bash
-- 2. Upload via CLI
databricks fs cp sample_sales_data.csv /Volumes/main/demo/data_volume/input.csv

-- 3. Verify
databricks fs ls /Volumes/main/demo/data_volume/
```

Or upload via UI:
1. Databricks → **Catalog**
2. Navigate: **main** → **demo** → **data_volume**
3. Click **Upload files**
4. Select `sample_sales_data.csv`

#### Option B: DBFS FileStore (if enabled)

```bash
databricks fs mkdirs dbfs:/FileStore/demo/
databricks fs cp sample_sales_data.csv dbfs:/FileStore/demo/input.csv
databricks fs ls dbfs:/FileStore/demo/
```

#### Option C: Create Table from CSV

1. Databricks UI → **Data** → **Create Table**
2. Upload `sample_sales_data.csv`
3. Table name: `main.demo.temp_sales_data`

Then modify `bronze.sql` to read from table instead of CSV.

### Step 6: Validate Bundle Configuration

```bash
# Navigate to project directory
cd c:\inter-k\lakeflow-demo

# Validate
databricks bundle validate
```

Expected output:
```
✓ Configuration valid
✓ Bundle name: lakeflow-report-demo
✓ Target: dev
```

### Step 7: Deploy Pipeline

```bash
# Deploy to dev environment
databricks bundle deploy -t dev
```

Expected output:
```
✓ Uploading bundle files...
✓ Deploying resources...
✓ Pipeline 'lakeflow-report-demo-pipeline-sql' created
✓ Deployment complete
```

### Step 8: Run Pipeline

```bash
# Run SQL pipeline with monitoring
databricks bundle run report_pipeline_sql --monitor
```

Pipeline stages:
1. ⏳ Bronze: Ingesting CSV → bronze_table
2. ⏳ Silver: Cleaning & validating → silver_table
3. ⏳ Gold: Aggregating → gold_table
4. ⏳ Reports: Creating summary tables

### Step 9: Check Pipeline Status

```bash
# List all pipelines
databricks pipelines list

# Get pipeline details
databricks pipelines get lakeflow-report-demo-pipeline-sql

# View pipeline updates/logs
databricks pipelines list-updates lakeflow-report-demo-pipeline-sql
```

### Step 10: Verify Data

```sql
-- In Databricks SQL Editor

-- Check all tables
SHOW TABLES IN main.demo;

-- Count records per layer
SELECT 'Bronze' as layer, COUNT(*) as records FROM main.demo.bronze_table
UNION ALL
SELECT 'Silver', COUNT(*) FROM main.demo.silver_table
UNION ALL
SELECT 'Gold', COUNT(*) FROM main.demo.gold_table;

-- View gold table
SELECT * FROM main.demo.gold_table ORDER BY total_sales DESC;

-- View reports
SELECT * FROM main.demo.gold_report_sql;
SELECT * FROM main.demo.executive_summary;
SELECT * FROM main.demo.category_ranking;
```

---

## 🛡️ Giải Quyết DBFS Disabled

### Vấn Đề

Nếu gặp lỗi:
```
Error: Public DBFS root is disabled. Access is denied on path: /FileStore/demo
```

Đây là do Databricks Community Edition hoặc workspace của bạn đã disable DBFS public root vì security reasons.

### Giải Pháp: Unity Catalog Volumes

Unity Catalog Volumes là cách hiện đại và secure để lưu files trong Databricks.

#### Solution 1: Tạo Volume qua UI (EASIEST)

**Bước 1: Tạo Volume**
1. Vào Databricks workspace
2. Click **"Catalog"** trên left sidebar
3. Navigate: **main** → **demo**
4. Click **"Create"** → **"Volume"**
5. Volume Name: `data_volume`
6. Volume Type: `MANAGED`
7. Click **"Create"**

**Bước 2: Upload File**
1. Click vào volume `data_volume`
2. Click **"Upload files"**
3. Select `sample_sales_data.csv`
4. Upload

**Bước 3: Verify**
```sql
SELECT * FROM csv.`/Volumes/main/demo/data_volume/input.csv` LIMIT 10;
```

✅ **Done!** File `bronze.sql` đã được config sẵn để đọc từ Volumes.

#### Solution 2: Tạo Volume qua SQL

```sql
-- Create schema
CREATE SCHEMA IF NOT EXISTS main.demo;

-- Create volume
CREATE VOLUME IF NOT EXISTS main.demo.data_volume;

-- Verify
SHOW VOLUMES IN main.demo;

-- Describe volume
DESCRIBE VOLUME main.demo.data_volume;
```

Upload file qua CLI:
```bash
databricks fs cp sample_sales_data.csv /Volumes/main/demo/data_volume/input.csv
databricks fs ls /Volumes/main/demo/data_volume/
```

#### Solution 3: Tạo Volume qua Python Notebook

```python
# In Databricks notebook
from pyspark.sql import SparkSession

# Create schema
spark.sql("CREATE SCHEMA IF NOT EXISTS main.demo")

# Create volume
spark.sql("CREATE VOLUME IF NOT EXISTS main.demo.data_volume")

# Upload data
df = spark.read.csv(
    "file:/Workspace/Users/your-email/sample_sales_data.csv",
    header=True
)
df.write.mode("overwrite").csv(
    "/Volumes/main/demo/data_volume/input.csv",
    header=True
)

print("✅ Data uploaded to Volume!")
```

#### Solution 4: Sử dụng Workspace Files

Upload qua **Workspace → Your folder → Upload**

Path sẽ là: `/Workspace/Users/<your-email>/sample_sales_data.csv`

Modify `bronze.sql` để đọc từ workspace path.

#### Solution 5: Direct Table Upload

1. **Data** → **Create Table**
2. Upload CSV
3. Table: `main.demo.temp_sales_data`
4. Modify `bronze.sql` để đọc từ table:

```sql
CREATE OR REFRESH LIVE TABLE bronze_table
AS SELECT
  transaction_id,
  date,
  category,
  product_name,
  sales_amount,
  quantity,
  customer_id,
  current_timestamp() AS ingestion_timestamp,
  'uploaded_table' AS source_file
FROM main.demo.temp_sales_data;
```

### Storage Options Comparison

| Method | Works with DBFS Disabled? | Security | Best For |
|--------|---------------------------|----------|----------|
| **Unity Catalog Volumes** | ✅ Yes | 🔒 High | Production (RECOMMENDED) |
| DBFS FileStore | ❌ No | ⚠️ Medium | Legacy only |
| Workspace Files | ✅ Yes | 🔒 Medium | Development |
| Direct Tables | ✅ Yes | 🔒 High | Simple use cases |

### Default Configuration

File `bronze.sql` đã được config để sử dụng Unity Catalog Volumes:

```sql
-- Default: Unity Catalog Volumes
FROM cloud_files(
  '/Volumes/main/demo/data_volume/',
  'csv',
  map('header', 'true', ...)
);
```

Nếu cần dùng DBFS, uncomment option 2 trong file.

---

## 💻 Databricks CLI Commands

### CLI Version

Project này hỗ trợ **Databricks CLI v0.270.0+**

```bash
# Check version
databricks -v

# Update if needed
pip install --upgrade databricks-cli
```

### Command Changes in v0.270.0+

| Old CLI | New CLI v0.270.0+ |
|---------|-------------------|
| `databricks configure --token` | `databricks auth login --host <host>` |
| `databricks workspace ls /` | `databricks workspace list /` |
| `databricks pipelines get --pipeline-id <id>` | `databricks pipelines get <id>` |
| `databricks pipelines get-events --pipeline-id <id>` | `databricks pipelines list-updates <id>` |

### Essential Commands

#### Authentication
```bash
# Login (new method)
databricks auth login --host https://community.cloud.databricks.com

# Configure (traditional - still works)
databricks configure --token

# Check current user
databricks current-user me

# List profiles
databricks auth profiles
```

#### Bundle Commands
```bash
# Validate bundle
databricks bundle validate

# Deploy to dev
databricks bundle deploy -t dev

# Run pipeline
databricks bundle run report_pipeline_sql
databricks bundle run report_pipeline_sql --monitor

# Destroy bundle
databricks bundle destroy -t dev
```

#### Pipeline Commands
```bash
# List all pipelines
databricks pipelines list

# Get pipeline details
databricks pipelines get <pipeline-name-or-id>

# List pipeline updates (logs/events)
databricks pipelines list-updates <pipeline-id>

# Get specific update details
databricks pipelines get-update <pipeline-id> <update-id>

# Start pipeline
databricks pipelines start <pipeline-id>

# Stop pipeline
databricks pipelines stop <pipeline-id>

# Delete pipeline
databricks pipelines delete <pipeline-id>
```

#### File System (DBFS/Volumes)
```bash
# List files
databricks fs ls /Volumes/main/demo/data_volume/
databricks fs ls dbfs:/FileStore/demo/

# Copy file to DBFS/Volume
databricks fs cp local.csv /Volumes/main/demo/data_volume/file.csv
databricks fs cp local.csv dbfs:/path/

# Remove file
databricks fs rm /Volumes/main/demo/data_volume/old.csv

# Create directory
databricks fs mkdirs dbfs:/FileStore/demo/

# Read file content
databricks fs cat /Volumes/main/demo/data_volume/input.csv
databricks fs head dbfs:/FileStore/demo/input.csv
```

#### Workspace Commands
```bash
# List workspace items
databricks workspace list /
databricks workspace list /Users/

# Upload file
databricks workspace upload file.py /Users/me/file.py

# Download file
databricks workspace download /Users/me/file.py local-file.py

# Delete item
databricks workspace delete /Users/me/old-file.py
```

#### Cluster Commands
```bash
# List clusters
databricks clusters list

# Get cluster details
databricks clusters get <cluster-id>

# Start/Stop cluster
databricks clusters start <cluster-id>
databricks clusters stop <cluster-id>
```

### Environment Variables

```powershell
# PowerShell
$env:DATABRICKS_HOST = "https://community.cloud.databricks.com"
$env:DATABRICKS_TOKEN = "dapi_your_token_here"
$env:DATABRICKS_BUNDLE_TARGET = "dev"

# Then run commands (automatically uses env vars)
databricks bundle deploy
```

---

## 🏗️ Architecture & Data Flow

### Medallion Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     DATA SOURCE                              │
│  CSV: /Volumes/main/demo/data_volume/input.csv              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  BRONZE LAYER (Raw)                          │
│  Table: main.demo.bronze_table                               │
│  - Cloud Files auto-loader                                   │
│  - Schema validation only                                    │
│  - All data ingested (no filtering)                          │
│  File: bronze.sql                                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                 SILVER LAYER (Cleaned)                       │
│  Table: main.demo.silver_table                               │
│  ✓ Data Quality Checks:                                      │
│    - sales_amount > 0                                        │
│    - quantity > 0                                            │
│    - date IS NOT NULL                                        │
│    - category IS NOT NULL                                    │
│  ✓ Transformations:                                          │
│    - Date conversion, UPPER(category), TRIM()                │
│    - Calculate: total_amount = sales × quantity              │
│  ✓ Invalid rows → DROPPED                                    │
│  File: silver.sql                                            │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│                  GOLD LAYER (Aggregated)                     │
│  Table: main.demo.gold_table                                 │
│  📊 Aggregations by Category:                                │
│    - total_transactions, total_sales                         │
│    - avg_transaction_value                                   │
│    - total_quantity_sold                                     │
│    - unique_customers (COUNT DISTINCT)                       │
│    - first/last_transaction_date                             │
│  File: gold.sql                                              │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│               REPORTING LAYER (Analytics)                    │
│  📈 gold_report_sql - Detailed KPIs per category             │
│  📊 executive_summary - Overall business metrics             │
│  🏆 category_ranking - Performance rankings                  │
│  File: gold_report_sql.sql                                   │
└────────────┬───────────┬────────────────────┬────────────────┘
             │           │                    │
             ▼           ▼                    ▼
      ┌──────────┐ ┌──────────┐      ┌──────────┐
      │Power BI  │ │ Tableau  │      │  Python  │
      │Dashboard │ │ Reports  │      │ Notebooks│
      └──────────┘ └──────────┘      └──────────┘
```

### Data Quality Framework

| Layer | Quality Level | Validations | Invalid Rows |
|-------|---------------|-------------|--------------|
| Bronze | Low | Schema only | All kept |
| Silver | Medium | 5 constraints | Dropped |
| Gold | High | Business logic | N/A (aggregated) |
| Report | Very High | KPI calculations | N/A |

### Technology Stack

- **Delta Live Tables (DLT)**: Declarative ETL pipeline
- **Delta Lake**: ACID transactions, time travel, schema evolution
- **Unity Catalog**: Data governance, permissions, lineage
- **Databricks Asset Bundles**: Infrastructure as Code, CI/CD
- **Cloud Files**: Auto file discovery, incremental processing

---

## ✅ Test & Validation

### Run Test Queries

File `test_queries.sql` chứa comprehensive test queries.

```sql
-- Bronze layer tests
SELECT COUNT(*) as total_records FROM main.demo.bronze_table;

SELECT category, COUNT(*) as count 
FROM main.demo.bronze_table 
GROUP BY category;

-- Silver layer tests
SELECT 
    'Bronze' as layer,
    COUNT(*) as records
FROM main.demo.bronze_table
UNION ALL
SELECT 
    'Silver',
    COUNT(*)
FROM main.demo.silver_table;

-- Gold layer tests
SELECT * FROM main.demo.gold_table
ORDER BY total_sales DESC;

-- Report tests
SELECT * FROM main.demo.gold_report_sql;
SELECT * FROM main.demo.executive_summary;
SELECT * FROM main.demo.category_ranking;

-- Data quality checks
SELECT 
    COUNT(*) as total_rows,
    SUM(CASE WHEN category IS NULL THEN 1 ELSE 0 END) as null_categories,
    SUM(CASE WHEN total_sales IS NULL THEN 1 ELSE 0 END) as null_sales
FROM main.demo.gold_table;

-- Verify calculations
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
```

### Expected Results

**Bronze Table:**
- All 100 records from CSV
- Includes invalid/dirty data
- Has metadata columns (ingestion_timestamp, source_file)

**Silver Table:**
- ≤ 100 records (invalid rows dropped)
- All data quality constraints passed
- Cleaned and standardized data

**Gold Table:**
- 5 rows (one per category)
- Aggregated metrics per category
- Sorted by total_sales DESC

**Report Tables:**
- `gold_report_sql`: Detailed KPIs with percentages
- `executive_summary`: Single row with overall metrics
- `category_ranking`: Ranked categories with ranks

---

## 📊 Power BI Integration

### Prerequisites

1. Databricks SQL Warehouse (create in Databricks UI)
2. Server Hostname & HTTP Path (from SQL Warehouse)
3. Power BI Desktop installed

### Setup Steps

#### Step 1: Create SQL Warehouse

1. Databricks UI → **SQL Warehouses**
2. Click **"Create SQL Warehouse"**
3. Name: `reporting-warehouse`
4. Cluster size: `X-Small` (for dev)
5. **Create**

#### Step 2: Get Connection Details

1. Click on SQL Warehouse
2. **Connection Details** tab
3. Copy:
   - **Server hostname**: `your-workspace.cloud.databricks.com`
   - **HTTP path**: `/sql/1.0/warehouses/xxxxx`

#### Step 3: Connect from Power BI

1. Open **Power BI Desktop**
2. **Get Data** → **More** → Search "Databricks"
3. Select **"Azure Databricks"**
4. Enter:
   - **Server hostname**: (from step 2)
   - **HTTP path**: (from step 2)
5. **OK**
6. Authentication:
   - **Personal Access Token**
   - Enter your Databricks token
7. **Connect**

#### Step 4: Select Tables

Navigator window will show:
1. Expand **main** → **demo**
2. Select tables:
   - ✅ `gold_report_sql`
   - ✅ `executive_summary`
   - ✅ `category_ranking`
   - ✅ `gold_table` (optional)
3. **Load**

#### Step 5: Create Visualizations

**Recommended Visuals:**

| Visual Type | Data Source | Fields |
|-------------|-------------|--------|
| **KPI Card** | executive_summary | total_revenue, total_transactions_count |
| **Bar Chart** | gold_report_sql | category (axis), total_sales (values) |
| **Pie Chart** | gold_report_sql | category (legend), sales_percentage (values) |
| **Table** | category_ranking | All fields |
| **Line Chart** | gold_table | category (legend), total_sales (values) |
| **Gauge** | gold_report_sql | avg_transaction_value |

**Sample Dashboard Layout:**

```
┌─────────────────────────────────────────────────────┐
│  Total Revenue      Total Transactions    Avg Value │
│  [$XX,XXX]         [XXX]                 [$XX.XX]   │ ← KPI Cards
├─────────────────────────────────────────────────────┤
│                                                       │
│    Sales by Category (Bar Chart)                     │ ← Bar Chart
│    ▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂▂               │
│                                                       │
├──────────────────────────┬──────────────────────────┤
│  Revenue Distribution    │   Category Rankings      │
│  (Pie Chart)             │   (Table)                │ ← Pie + Table
│       📊                  │   Rank  Category  Sales  │
└──────────────────────────┴──────────────────────────┘
```

### Power BI Query Examples

```powerquery
// Filter high performers
= Table.SelectRows(gold_report_sql, each [performance_category] = "High Performer")

// Calculate custom metrics
= Table.AddColumn(gold_report_sql, "Profit Margin", each [total_sales] * 0.3)

// Sort by sales
= Table.Sort(gold_report_sql,{{"total_sales", Order.Descending}})
```

### Refresh Data

**Manual Refresh:**
- Power BI → **Home** → **Refresh**

**Scheduled Refresh:**
1. Publish to Power BI Service
2. **Settings** → **Scheduled refresh**
3. Configure refresh schedule (e.g., daily at 6 AM)

---

## 🐛 Troubleshooting

### Issue 1: Public DBFS Root Disabled

**Error:**
```
Error: Public DBFS root is disabled. Access is denied on path: /FileStore/demo
```

**Solution:**
Use Unity Catalog Volumes (see [Section 4](#-giải-quyết-dbfs-disabled))

Quick fix:
```sql
CREATE SCHEMA IF NOT EXISTS main.demo;
CREATE VOLUME IF NOT EXISTS main.demo.data_volume;
```

Upload via UI: Catalog → main → demo → data_volume → Upload

### Issue 2: File Not Found

**Error:**
```
FileNotFoundException: /Volumes/main/demo/data_volume/input.csv
```

**Solution:**
```bash
# Verify volume exists
databricks fs ls /Volumes/main/demo/data_volume/

# Re-upload if missing
databricks fs cp sample_sales_data.csv /Volumes/main/demo/data_volume/input.csv
```

### Issue 3: Permission Denied

**Error:**
```
Error: You don't have permission to access this resource
```

**Solution:**
1. Verify correct token in auth
2. Check workspace permissions
3. For Unity Catalog: Check schema/volume permissions
4. Re-authenticate:
   ```bash
   databricks auth login --host https://community.cloud.databricks.com
   ```

### Issue 4: Pipeline Validation Errors

**Error:**
```
Validation failed: Invalid table reference
```

**Solution:**
- Verify catalog: `main`
- Verify schema: `demo`
- Check SQL files use `LIVE.` prefix
- Ensure volume exists:
  ```sql
  SHOW VOLUMES IN main.demo;
  ```

### Issue 5: Empty Tables

**Error:**
Tables created but have 0 rows

**Solution:**
```bash
# Check pipeline logs
databricks pipelines list-updates lakeflow-report-demo-pipeline-sql

# Verify source data
databricks fs ls /Volumes/main/demo/data_volume/

# Check bronze table
# In SQL Editor: SELECT COUNT(*) FROM main.demo.bronze_table

# Re-run pipeline
databricks bundle run report_pipeline_sql
```

### Issue 6: Bundle Deployment Fails

**Error:**
```
Error: Failed to deploy bundle
```

**Solution:**
```bash
# Clean up previous deployment
databricks bundle destroy -t dev

# Validate first
databricks bundle validate

# Re-deploy
databricks bundle deploy -t dev
```

### Issue 7: CLI Version Issues

**Error:**
```
Error: unknown command "auth" for "databricks"
```

**Solution:**
Old CLI version. Update:
```bash
pip install --upgrade databricks-cli
databricks -v
```

Expected: `Databricks CLI v0.270.0` or higher

### Issue 8: Schema/Catalog Not Found

**Error:**
```
Schema not found: main.demo
```

**Solution:**
```sql
-- Create schema first
CREATE SCHEMA IF NOT EXISTS main.demo;

-- Verify
SHOW SCHEMAS IN main;

-- Create volume
CREATE VOLUME IF NOT EXISTS main.demo.data_volume;
```

### Common Error Patterns

| Error Message | Most Likely Cause | Quick Fix |
|---------------|-------------------|-----------|
| "DBFS root disabled" | DBFS security restriction | Use Unity Catalog Volumes |
| "File not found" | Data not uploaded | Upload CSV to volume |
| "Permission denied" | Invalid token/permissions | Re-authenticate |
| "Schema not found" | Schema doesn't exist | CREATE SCHEMA main.demo |
| "Pipeline failed" | Data quality issue | Check bronze table data |

---

## 🚀 Advanced Topics

### Scheduling Pipeline

Add to `resources/pipeline.yml`:

```yaml
configuration:
  "pipelines.trigger.interval": "cron"
  "pipelines.cron.expression": "0 0 * * *"  # Daily at midnight
```

### Email Notifications

```yaml
notifications:
  - email_recipients:
      - your-email@example.com
    alerts:
      - on-update-failure
      - on-update-success
```

### Multi-Environment Deployment

```bash
# Deploy to staging
databricks bundle deploy -t staging

# Deploy to production
databricks bundle deploy -t prod
```

Add to `databricks.yml`:
```yaml
targets:
  dev:
    mode: development
  staging:
    mode: development
    workspace:
      host: https://staging-workspace.databricks.com
  prod:
    mode: production
    workspace:
      host: https://prod-workspace.databricks.com
```

### Performance Optimization

**Z-Ordering:**
```sql
-- Already implemented in bronze.sql
TBLPROPERTIES ("pipelines.autoOptimize.zOrderCols" = "transaction_id")
```

**Partitioning (for large datasets):**
```sql
PARTITION BY (transaction_date)
```

**Auto Optimize:**
```yaml
configuration:
  "spark.databricks.delta.autoOptimize.optimizeWrite": "true"
  "spark.databricks.delta.autoOptimize.autoCompact": "true"
```

### Adding More Data Sources

**From S3:**
```sql
FROM cloud_files(
  's3://your-bucket/path/',
  'csv',
  map('header', 'true')
);
```

**From Delta Table:**
```sql
FROM delta.`/path/to/delta/table`
```

**From JDBC:**
```sql
FROM jdbc(
  'jdbc:mysql://host:port/database',
  'table_name',
  map('user', 'username', 'password', 'password')
)
```

### Data Lineage

View in Databricks UI:
1. **Data Explorer** → **main.demo.gold_table**
2. **Lineage** tab
3. See upstream/downstream dependencies

### Custom Transformations

Add to `silver.sql`:
```sql
CASE 
  WHEN category = 'ELECTRONICS' THEN 'Tech'
  WHEN category = 'CLOTHING' THEN 'Fashion'
  ELSE 'Other'
END as category_group
```

### Testing in Notebooks

Create notebook:
```python
# Test bronze table
df_bronze = spark.table("main.demo.bronze_table")
print(f"Bronze records: {df_bronze.count()}")

# Test silver table
df_silver = spark.table("main.demo.silver_table")
print(f"Silver records: {df_silver.count()}")

# Verify data quality
df_silver.filter("sales_amount <= 0").count()  # Should be 0
```

---

## 📚 Resources

### Databricks Documentation
- [Delta Live Tables](https://docs.databricks.com/delta-live-tables/)
- [Asset Bundles](https://docs.databricks.com/dev-tools/bundles/)
- [Databricks CLI](https://docs.databricks.com/dev-tools/cli/)
- [Unity Catalog](https://docs.databricks.com/data-governance/unity-catalog/)

### Community
- [Databricks Community](https://community.databricks.com/)
- [Stack Overflow - Databricks](https://stackoverflow.com/questions/tagged/databricks)

### Sample Data Schema

```
transaction_id: String       # TXN0001, TXN0002, ...
date: String                 # 2024-01-01, 2024-01-02, ...
category: String             # Electronics, Clothing, Books, Home & Garden, Sports
product_name: String         # Laptop, T-Shirt, Python Guide, ...
sales_amount: Double         # 1200.00, 25.99, 45.00, ...
quantity: Integer            # 1, 2, 3, ...
customer_id: String          # CUST001, CUST002, ...
```

---

## 🎉 Summary

### What You Get

✅ **Complete ETL Pipeline**: Bronze → Silver → Gold → Reports  
✅ **2 Pipeline Versions**: SQL (production) + Python (development)  
✅ **Data Quality**: 5 validation rules in Silver layer  
✅ **6 Tables Created**: bronze, silver, gold, + 3 report tables  
✅ **Power BI Ready**: Pre-calculated KPIs and rankings  
✅ **DBFS Workaround**: Unity Catalog Volumes solution  
✅ **CLI v0.270.0+**: Updated for latest Databricks CLI  
✅ **Sample Data**: 100 transactions across 5 categories  
✅ **Test Queries**: Comprehensive validation SQL  
✅ **Production Ready**: Error handling, monitoring, documentation  

### Next Steps

1. ✅ **Run the Quick Start** (5 minutes)
2. ✅ **Verify all tables** created successfully
3. ✅ **Connect Power BI** and build dashboards
4. ✅ **Schedule pipeline** for automatic runs
5. ✅ **Customize** for your data and business logic

---

## 📞 Support

**Need Help?**

1. Check **[Troubleshooting](#-troubleshooting)** section
2. Review pipeline logs: `databricks pipelines list-updates <pipeline-id>`
3. Verify data: Run queries from `test_queries.sql`
4. Check Databricks documentation

**Common Issues:**
- **DBFS disabled** → Use Unity Catalog Volumes (Section 4)
- **File not found** → Verify upload (Section 3)
- **Pipeline failed** → Check logs (Section 9)
- **Empty tables** → Verify source data

---

**🎯 Ready to Deploy!**

Your complete Lakeflow pipeline is ready to run on Databricks! 🚀

*Last Updated: October 2025 | Compatible with Databricks CLI v0.270.0+*# Lakeflow-Databrick
