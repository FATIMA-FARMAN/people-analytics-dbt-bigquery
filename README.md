# People Analytics dbt on BigQuery + Airflow Orchestration

## Overview
This repository demonstrates an analytics engineering workflow using **dbt** on **BigQuery** and orchestration via an **Airflow DAG**.

## Key artifacts
- `dags/dag_dbt_payments_domain.py` — Airflow DAG that triggers dbt runs
- `models/` — dbt models (staging → intermediate → marts)
- `tests/` — dbt tests (not_null / unique / relationships / accepted_values)

## How to run (local)
1. Configure BigQuery credentials for dbt (service account JSON).
2. Install dependencies in a virtual environment.
3. Run:
   - `dbt debug`
   - `dbt run`
   - `dbt test`
4. Start Airflow and trigger the DAG from the UI.

## Proof screenshots
Add screenshots into `docs/screenshots/` and reference them here (Airflow UI run, dbt run graph, BigQuery tables/views).
## Proof (Git Clean State)
![git status clean](docs/screenshots/01_git_status_clean.png)

## Airflow Orchestration Proof

**Airflow DAGs registered**
![Airflow DAGs list](docs/screenshots/02_airflow_dags_list.png)

**Successful run**
![Airflow run success](docs/screenshots/03_airflow_run_success.png)

## Airflow Orchestration Proof (Local)

Airflow DAG executed successfully (dbt deps → dbt run → dbt test):

![Airflow DAG Proof](docs/screenshots/08_airflow_ui_dag_loaded.png)

![dbt CI (PR checks)](https://github.com/FATIMA-FARMAN/people-analytics-dbt-bigquery/actions/workflows/ci.yml/badge.svg)
![dbt CI (PR checks)](https://github.com/FATIMA-FARMAN/people-analytics-dbt-bigquery/actions/workflows/ci.yml/badge.svg)
![dbt CI (PR checks)](https://github.com/FATIMA-FARMAN/people-analytics-dbt-bigquery/actions/workflows/ci.yml/badge.svg)

## Cost-aware warehouse notes (BigQuery)

This project is structured to demonstrate cost-aware analytics engineering patterns on BigQuery:

- **Materialization strategy**
  - **Staging models** are kept lightweight (typically **views**) to avoid unnecessary storage duplication.
  - **Intermediate models** are materialized as **tables** only where it reduces repeated compute (reused joins/transformations).
  - **Mart models (dim/fct)** are designed for BI consumption and can be **views** (low-storage) or **tables** (faster BI) depending on use-case.

- **Query efficiency**
  - Prefer selecting only required columns (avoid `SELECT *`) in marts to reduce scanned bytes.
  - Build reusable intermediate tables for expensive joins to prevent repeated recomputation across multiple marts.

- **Partitioning & clustering (recommended for production scale)**
  - For large facts (e.g., `fct_*`), partition by a date column (e.g., `event_date`, `snapshot_date`) and cluster by common filter/join keys (e.g., `employee_id`, `department_id`) to reduce scan cost and improve performance.

- **Sandbox / billing note**
  - BigQuery Sandbox can restrict certain DML operations; snapshot-style SCD2 maintenance may require billing-enabled projects.
  - This repo includes **local proof (DuckDB)** for incremental/SCD2 patterns where warehouse DML is restricted.

- **CI as a cost guardrail**
  - GitHub Actions runs **`dbt parse` + `dbt deps`** (and optionally targeted `dbt test`) to catch issues early without running full warehouse refreshes on every change.


```mermaid
flowchart TB

  subgraph ORCH["Airflow Orchestration"]
    DAG["dag_dbt_people_domain"] --> DEPS["dbt deps"] --> RUN["dbt run"] --> TEST["dbt test"]
  end

  subgraph SRC["Sources"]
    HRIS["HRIS"]
    ATS["ATS"]
    PERF["Performance"]
    COMP["Compensation"]
  end

  subgraph STG["Staging"]
    STG_HRIS["stg_hris_employees"]
    STG_ATS["stg_ats_candidates"]
    STG_PERF["stg_perf_reviews"]
    STG_COMP["stg_comp_salaries"]
  end

  subgraph INT["Intermediate"]
    INT_EMP["int_employee_enriched"]
    INT_FUN["int_hiring_funnel_steps"]
  end

  subgraph MART["Marts"]
    DIM_EMP["dim_employee"]
    FCT_FUN["fct_hiring_funnel"]
  end

  HRIS --> STG_HRIS
  ATS --> STG_ATS
  PERF --> STG_PERF
  COMP --> STG_COMP

  STG_HRIS --> INT_EMP
  STG_PERF --> INT_EMP
  STG_COMP --> INT_EMP

  STG_ATS --> INT_FUN

  INT_EMP --> DIM_EMP
  INT_FUN --> FCT_FUN
  DIM_EMP --> FCT_FUN

