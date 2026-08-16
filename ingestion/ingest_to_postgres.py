import pandas as pd
from db_config import get_engine
import os 
from pathlib import Path
from sqlalchemy import create_engine, text

RAW_DATA_DIR = os.path.join(
                os.path.dirname(__file__),"..","data","raw")


# raw_data_dir = Path(__file__).resolve().parent.parent / "data" / "raw"
# csv_files1 = [f for f in os.listdir(RAW_DATA_DIR) if f.endswith(".csv")]

# csv_files = list(raw_data_dir.glob("*.csv"))
# for file in csv_files1:
#     print(file,1)

TABLES = [
    ("customers.csv", "raw_customers"),
    ("products.csv", "raw_products"),
    ("stores.csv", "raw_stores"),
    ("employees.csv", "raw_employees"),
    ("sales.csv", "raw_sales"),
]

def load_csv_to_table(engine, csv_path, table_name):
    df = pd.read_csv(csv_path, dtype=str, keep_default_na = False)
    with engine.begin() as conn:
        conn.execute(text(f'TRUNCATE TABLE "{table_name}" RESTART IDENTITY CASCADE'))
        
    df.to_sql(
        table_name,
        engine,
        if_exists="append",
        index=False,
        method="multi",
        chunksize=1000,
    )
    return len(df)

def main():
    print(f"Connecting...")
    engine = get_engine()
    print("Connected. Starting load...\n")
 
    try:
        for csv_file, table_name in TABLES:
            csv_path = os.path.join(RAW_DATA_DIR,csv_file)
            if not os.path.exists(csv_path):
                raise FileNotFoundError(
                    f"Expected file not found: {csv_path}\n"
                    f"Make sure {csv_filename} is in data/raw/"
                )
            row_count = load_csv_to_table(engine, csv_path, table_name)
            print(f"  ✔ {table_name:<20} loaded {row_count:>6} rows  (from {csv_file})")
 
        print("\n✅ All tables loaded successfully.")
    except Exception as e:
        print(f"load failed: {e}")
    finally:
        engine.dispose()

if __name__ == "__main__":
    main()