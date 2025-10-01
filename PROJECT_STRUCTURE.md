# 📁 Lakeflow Demo - DLT + dbt Hybrid Architecture

## Project Structure

```
lakeflow-demo/
├── 📄 databricks.yml                    # Databricks Asset Bundle config
├── 📄 .gitignore
├── 📄 README.md
│
├── 📂 resources/                        # Databricks resources
│   ├── pipeline.yml                     # DLT pipelines (ingestion only)
│   ├── dbt_job.yml                      # dbt transformation job
│   └── workflow.yml                     # Combined workflows
│
├── 📂 src/
│   ├── 📂 sql/                          # DLT SQL (ingestion only)
│   │   └── bronze.sql                   # Streaming ingestion
│   │
│   └── 📂 python/                       # DLT Python notebooks (ingestion)
│       └── bronze_to_silver.ipynb       # Alternative ingestion
│
├── 📂 dbt_project/                      # ← NEW: dbt project
│   ├── dbt_project.yml                  # dbt project config
│   ├── profiles.yml                     # Databricks connection
│   │
│   ├── 📂 models/
│   │   ├── 📂 staging/                  # Silver layer
│   │   │   ├── schema.yml               # Tests & docs
│   │   │   └── stg_sales.sql            # Clean bronze → silver
│   │   │
│   │   ├── 📂 marts/                    # Gold layer
│   │   │   ├── schema.yml
│   │   │   └── gold_sales_by_category.sql
│   │   │
│   │   └── 📂 reports/                  # Report layer
│   │       ├── schema.yml
│   │       ├── rpt_executive_summary.sql
│   │       ├── rpt_category_ranking.sql
│   │       └── rpt_gold_report.sql
│   │
│   ├── 📂 tests/                        # Data quality tests
│   │   └── assert_positive_sales.sql
│   │
│   ├── 📂 macros/                       # Reusable SQL functions
│   │   └── generate_schema_name.sql
│   │
│   ├── 📂 snapshots/                    # Slowly changing dimensions
│   │   └── snapshot_categories.sql
│   │
│   └── 📂 seeds/                        # Static reference data
│       └── category_mapping.csv
│
├── 📂 tests/                            # Integration tests
│   └── test_pipeline.py
│
└── 📂 docs/                             # Documentation
    ├── ARCHITECTURE.md
    └── DBT_GUIDE.md
```

## Data Flow

### Option 1: DLT Ingestion → dbt Transformation (RECOMMENDED)

```
CSV → DLT Bronze (streaming) → dbt Silver → dbt Gold → dbt Reports → Power BI
      ^^^^^^^^^^^^^^^^^^^^^^    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      Auto-loader, fast          Full testing, docs, version control
```

**Responsibilities:**
- **DLT**: Ingestion only (bronze layer with streaming)
- **dbt**: All transformations (silver, gold, reports)

### Option 2: Full dbt (Alternative)

```
CSV → dbt Bronze → dbt Silver → dbt Gold → dbt Reports → Power BI
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
      Pure dbt, simpler but no streaming
```

### Option 3: Hybrid with both DLT pipelines (Current + dbt)

```
Option A: CSV → DLT SQL Pipeline → Catalog Tables
Option B: CSV → DLT Python Pipeline → Catalog Tables
Option C: CSV → dbt Pipeline → Catalog Tables
```

Choose based on use case!

## Workflows

### Workflow 1: DLT Ingestion + dbt Transform
```yaml
1. Run DLT bronze pipeline (streaming ingestion)
2. Wait for completion
3. Run dbt (transformations)
4. dbt test (data quality)
5. dbt docs generate
```

### Workflow 2: Full dbt (Simpler)
```yaml
1. dbt seed (load reference data)
2. dbt run (all models)
3. dbt test (data quality)
4. dbt docs generate
```

## Next Steps

1. ✅ Setup dbt project structure
2. ✅ Configure dbt-databricks adapter
3. ✅ Migrate SQL transformations to dbt models
4. ✅ Add data quality tests
5. ✅ Setup dbt workflow in Databricks
6. ✅ Generate documentation
