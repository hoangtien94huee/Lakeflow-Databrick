# 🚀 Setup dbt với Databricks - Hướng Dẫn Chi Tiết

## 📋 Bước 1: Cài Đặt dbt-databricks

```powershell
# Install dbt-databricks adapter
pip install dbt-databricks

# Verify installation
dbt --version
```

Expected output:
```
installed version: 1.7.0
   latest version: 1.7.0
```

## 📋 Bước 2: Tạo SQL Warehouse trên Databricks

1. Vào Databricks workspace: `https://dbc-489f4dbc-4095.cloud.databricks.com`
2. Click **SQL Warehouses** (left sidebar)
3. Click **Create SQL Warehouse**
4. Name: `dbt-warehouse`
5. Cluster size: **X-Small** (cho development)
6. **Create**
7. Copy **HTTP Path**: `/sql/1.0/warehouses/xxxxx`

## 📋 Bước 3: Cấu Hình profiles.yml

Update file `dbt_project/profiles.yml`:

```yaml
lakeflow_dbt:
  target: dev
  outputs:
    dev:
      type: databricks
      catalog: main
      schema: demo
      host: dbc-489f4dbc-4095.cloud.databricks.com  # ← Your workspace
      http_path: /sql/1.0/warehouses/YOUR_WAREHOUSE_ID  # ← Update this
      token: "{{ env_var('DATABRICKS_TOKEN') }}"
      threads: 4
```

## 📋 Bước 4: Set Token Environment Variable

```powershell
# Set token (replace with your token)
$env:DATABRICKS_TOKEN = "dapi_your_token_here"

# Verify
echo $env:DATABRICKS_TOKEN
```

## 📋 Bước 5: Test Connection

```powershell
cd dbt_project
dbt debug
```

Expected output:
```
✓ Connection test: OK connection ok
```

## 📋 Bước 6: Run dbt Models

```powershell
# Run all models
dbt run

# Expected output:
# Running with dbt=1.7.0
# Found 6 models, 15 tests, 0 snapshots
# 
# Completed successfully
# 
# Done. PASS=6 WARN=0 ERROR=0 SKIP=0 TOTAL=6
```

## 📋 Bước 7: Run Tests

```powershell
# Run data quality tests
dbt test

# Expected output:
# Completed successfully
# Done. PASS=15 WARN=0 ERROR=0 SKIP=0 TOTAL=15
```

## 📋 Bước 8: Generate Documentation

```powershell
# Generate docs
dbt docs generate

# Serve docs locally (opens browser)
dbt docs serve
```

Docs sẽ mở tại: `http://localhost:8080`

## 🎯 Full Workflow: DLT + dbt

### Option A: Manual (Development)

```powershell
# Step 1: Run DLT pipeline (bronze ingestion)
databricks bundle run report_pipeline_sql --refresh-all

# Step 2: Run dbt transformations
cd dbt_project
dbt run

# Step 3: Run tests
dbt test

# Step 4: Generate docs
dbt docs generate
```

### Option B: Automated Workflow (Production)

Deploy workflow:

```powershell
# Deploy DLT + dbt workflow
databricks bundle deploy -t dev

# Run combined workflow
databricks bundle run lakeflow_dlt_dbt_workflow
```

Workflow sẽ tự động:
1. ⏳ Run DLT bronze ingestion
2. ⏳ Run dbt silver models
3. ⏳ Run dbt gold models
4. ⏳ Run dbt report models
5. ⏳ Run dbt tests
6. ⏳ Generate documentation
7. ✅ Send email notification

## 📊 Verify Results

```sql
-- In Databricks SQL Editor

-- Check staging (silver) models
SELECT * FROM main.demo.stg_sales LIMIT 10;

-- Check gold models
SELECT * FROM main.demo.gold_sales_by_category;

-- Check reports
SELECT * FROM main.demo.rpt_executive_summary;
SELECT * FROM main.demo.rpt_category_ranking;
SELECT * FROM main.demo.rpt_gold_report;
```

## 🎨 dbt Project Structure

```
dbt_project/
├── dbt_project.yml          # Project configuration
├── profiles.yml             # Databricks connection
├── models/
│   ├── staging/            # Silver layer (cleaning)
│   │   ├── stg_sales.sql
│   │   └── schema.yml
│   ├── marts/              # Gold layer (aggregation)
│   │   ├── gold_sales_by_category.sql
│   │   └── schema.yml
│   └── reports/            # Report layer (BI ready)
│       ├── rpt_executive_summary.sql
│       ├── rpt_category_ranking.sql
│       ├── rpt_gold_report.sql
│       └── schema.yml
├── tests/                  # Custom tests
└── README.md
```

## 🔧 Troubleshooting

### Issue 1: Connection failed

**Error:**
```
Connection test: ERROR
```

**Solution:**
1. Verify `DATABRICKS_TOKEN` is set
2. Check `http_path` in `profiles.yml`
3. Ensure SQL Warehouse is running

### Issue 2: Table not found

**Error:**
```
Table or view 'bronze_table' not found
```

**Solution:**
Run DLT pipeline first:
```powershell
databricks bundle run report_pipeline_sql
```

### Issue 3: Permission denied

**Error:**
```
User does not have CREATE TABLE on Schema
```

**Solution:**
Grant permissions in Databricks:
```sql
GRANT CREATE TABLE ON SCHEMA main.demo TO `your-email@example.com`;
```

## 🎯 Next Steps

1. ✅ Setup CI/CD with GitHub Actions
2. ✅ Add more dbt tests
3. ✅ Create dbt snapshots for SCD
4. ✅ Add dbt macros for reusable logic
5. ✅ Connect Power BI to dbt models

## 📚 Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [dbt-databricks](https://docs.getdbt.com/reference/warehouse-setups/databricks-setup)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)
