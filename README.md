# Retail ERP Data Pipeline

An end-to-end data engineering pipeline that ingests raw retail transaction data, models it into a dimensional (star-schema) warehouse using dbt, validates it with automated data tests, and orchestrates the entire process with Apache Airflow.

Built as a portfolio project to demonstrate a realistic ELT workflow: messy source data → tested, analytics-ready marts, running on a fully containerized local stack.

---

## Architecture

```
CSV Files (customers, products, stores, employees, sales)
        │
        ▼
Python Ingestion (pandas + SQLAlchemy)
        │
        ▼
PostgreSQL — Raw Layer
  raw_customers · raw_products · raw_stores · raw_employees · raw_sales
        │
        ▼
dbt — Staging Layer (views, cleaned & typed)
  stg_customers · stg_products · stg_stores · stg_employees · stg_sales
        │
        ▼
dbt — Dimensions (tables)
  dim_customer · dim_products · dim_stores · dim_employees · dim_date
        │
        ▼
dbt — Fact Table
  fact_sales  (joins all dimensions, calculates net_revenue)
        │
        ▼
dbt — Business Marts
  sales_summary · product_summary · customer_summary
        │
        ▼
17 automated data tests (uniqueness, nulls, referential integrity, accepted values)
```

The whole pipeline is orchestrated by **Apache Airflow**, running in Docker, on a daily schedule:

```
ingest_csv_to_postgres  →  dbt_run  →  dbt_test
```

---

## Tech Stack

| Layer | Tool |
|---|---|
| Orchestration | Apache Airflow (Docker, standalone mode) |
| Data warehouse | PostgreSQL 16 (Docker) |
| Transformation | dbt-core 1.8.2 |
| Ingestion | Python (pandas, SQLAlchemy, psycopg2) |
| Infrastructure | Docker Compose |
| Version control | Git |

---

## Why this project exists

Most tutorial datasets are already clean. This one isn't, on purpose. The source CSVs were generated with realistic, deliberate data quality issues — duplicate transactions, invalid dates, negative quantities, missing discounts, inconsistent casing and whitespace — so that the staging layer has actual cleaning work to do, not just column renaming. That's the difference between a project that looks like a pipeline and one that behaves like one.

---

## Data Quality Handling

| Issue | Where it's handled | How |
|---|---|---|
| Duplicate transactions | `stg_sales` | `SELECT DISTINCT` |
| Invalid dates (e.g. `2025-02-30`) | `stg_sales` | Custom Postgres function `safe_to_date()` — returns `NULL` instead of erroring on unparseable dates |
| Negative quantities | `stg_sales` → `fact_sales` | Flagged in staging (`is_negative_quantity`), excluded at the fact layer, not silently deleted |
| Missing discounts | `fact_sales` | `COALESCE(discount_percent, 0)` |
| Inconsistent casing / whitespace | All staging models | `TRIM()`, `INITCAP()`, `LOWER()` |
| Referential integrity | `_facts__models.yml` | `relationships` tests against every dimension |

Bad data is **flagged and made visible**, not silently dropped — a design choice that keeps the pipeline auditable rather than just "clean-looking."

---

## Data Tests (17 total, all passing)

- `unique` + `not_null` on every primary key (`fact_sales`, all dimensions)
- `relationships` — every foreign key in `fact_sales` verified against its dimension table
- `accepted_values` — `order_status` constrained to `Completed`, `Returned`, `Cancelled`

Run with:
```bash
dbt test
```

---

## Project Structure

```
retail_erp_project/
├── data/raw/                    # Source CSVs
├── ingestion/
│   └── ingest_to_postgres.py    # Loads CSVs → Postgres raw tables (TRUNCATE + reload)
├── dbt/retail_erp/
│   └── models/
│       ├── staging/             # Cleaning, casting, deduping
│       ├── dimensions/          # dim_customer, dim_products, dim_stores, dim_employees, dim_date
│       ├── facts/               # fact_sales + relationship/uniqueness tests
│       └── marts/               # sales_summary, product_summary, customer_summary
├── dags/
│   └── retail_erp_dag.py        # Airflow DAG: ingest → dbt run → dbt test
├── airflow_profiles/
│   └── profiles.yml             # dbt connection profile (container-networked)
├── docker-compose.yml           # Postgres + Airflow, one command to bring up both
├── Dockerfile.airflow           # Airflow image with dbt-postgres installed
└── sql/create_raw_tables.sql
```

---

## Running It Yourself

**1. Start the stack:**
```bash
docker compose up -d --build
```
This brings up Postgres (port `5432`) and Airflow (port `8080`) on a shared Docker network.

**2. Get the Airflow admin password:**
```bash
docker exec -it airflow_retail_erp cat /opt/airflow/standalone_admin_password.txt
```

**3. Open the Airflow UI:** `http://localhost:8080` → log in as `admin` → unpause and trigger `retail_erp_pipeline`.

**4. Or run it manually, without Airflow:**
```bash
cd ingestion
python ingest_to_postgres.py

cd ../dbt/retail_erp
dbt run
dbt test
```

---

## Sample Business Questions This Pipeline Answers

- Revenue by city, by month (`sales_summary`)
- Best-selling products by units and revenue (`product_summary`)
- Top customers by lifetime revenue (`customer_summary`)
- Order status breakdown (completed vs. returned vs. cancelled)

---

## Notes

- `dbt-core` is intentionally pinned to `1.8.2` — a newer major version (dbt Fusion, `2.0.0-beta.1`) does not yet support the Postgres adapter.
- Airflow runs in `standalone` mode with SQLite/SequentialExecutor — appropriate for local development and portfolio demonstration, not a production configuration.
- Two separate `profiles.yml` files exist by design: one for local CLI use (`~/.dbt/profiles.yml`, `host: localhost`) and one for the Airflow container (`airflow_profiles/profiles.yml`, `host: postgres_retail_erp`) — containers reach each other by container name, not `localhost`.