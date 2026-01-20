from datetime import datetime, timedelta
import os
import subprocess

from airflow import DAG
from airflow.operators.bash import BashOperator

PROJECT_DIR = os.path.expanduser("~/Desktop/people_analytics_dbt")
DBT_BIN = os.path.expanduser("~/.local/bin/dbt")  # pipx dbt
# If you installed dbt inside the venv instead, use:
# DBT_BIN = "dbt"

default_args = {
    "owner": "fatima",
    "depends_on_past": False,
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="dbt_people_analytics_daily",
    default_args=default_args,
    description="Run dbt models + tests for People Analytics (BigQuery)",
    schedule_interval=None,  # manual trigger for proof
    start_date=datetime(2025, 1, 1),
    catchup=False,
    tags=["dbt", "people-analytics", "bigquery"],
) as dag:

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f"cd {PROJECT_DIR} && {DBT_BIN} deps",
    )

    dbt_run = BashOperator(
        task_id="dbt_run_full_refresh",
        bash_command=f"cd {PROJECT_DIR} && {DBT_BIN} run --full-refresh",
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=f"cd {PROJECT_DIR} && {DBT_BIN} test",
    )

    dbt_deps >> dbt_run >> dbt_test

