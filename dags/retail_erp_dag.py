from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    "owner": "santosh",
    "retries": 1,
    "retry_delay": timedelta(minutes=2),
}

with DAG(
    dag_id="retail_erp_pipeline",
    default_args=default_args,
    description="Ingest CSVs into Postgres, then run and test dbt models",
    schedule_interval="@daily",
    start_date=datetime(2026, 8, 1),
    catchup=False,
    tags=["retail_erp"],
) as dag:

    ingest_data = BashOperator(
        task_id="ingest_csv_to_postgres",
        bash_command=(
            "cd /opt/airflow/retail_erp_project/ingestion && "
            "python ingest_to_postgres.py"
        ),
        env={
            "POSTGRES_HOST": "postgres_retail_erp",
            "POSTGRES_PORT": "5432",
            "POSTGRES_DB": "retail_erp_dw",
            "POSTGRES_USER": "postgres",
            "POSTGRES_PASSWORD": "postgres",
        },
    )

    dbt_run = BashOperator(
        task_id="dbt_run",
        bash_command=(
            "cd /opt/airflow/retail_erp_project/dbt/retail_erp && "
            "dbt run --profiles-dir /opt/airflow/.dbt"
        ),
    )

    dbt_test = BashOperator(
        task_id="dbt_test",
        bash_command=(
            "cd /opt/airflow/retail_erp_project/dbt/retail_erp && "
            "dbt test --profiles-dir /opt/airflow/.dbt"
        ),
    )

    ingest_data >> dbt_run >> dbt_test
