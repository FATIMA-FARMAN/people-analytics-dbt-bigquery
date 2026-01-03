from datetime import datetime
from airflow import DAG
from airflow.operators.bash import BashOperator

DBT_PROJECT_DIR = "/Users/fatima/Desktop/people_analytics_dbt"
DBT_BIN = "/Users/fatima/dbt_venv/bin/dbt"  # important: dbt venv binary

with DAG(
    dag_id="dbt_payments_domain_run_tests",
    start_date=datetime(2026, 1, 1),
    schedule="@daily",
    catchup=False,
    tags=["dbt", "payments", "domain"],
) as dag:

    check_dbt = BashOperator(
        task_id="check_dbt_installed",
        bash_command=f'"{DBT_BIN}" --version',
    )

    dbt_deps = BashOperator(
        task_id="dbt_deps",
        bash_command=f'cd "{DBT_PROJECT_DIR}" && "{DBT_BIN}" deps',
    )

    dbt_run = BashOperator(
        task_id="dbt_run_payments",
        bash_command=f'cd "{DBT_PROJECT_DIR}" && "{DBT_BIN}" run --select tag:payments',
    )

    dbt_test = BashOperator(
        task_id="dbt_test_payments",
        bash_command=f'cd "{DBT_PROJECT_DIR}" && "{DBT_BIN}" test --select tag:payments',
    )

    check_dbt >> dbt_deps >> dbt_run >> dbt_test

