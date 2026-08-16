import pandas as pd
from sqlalchemy import create_engine, text
import os
from dotenv import load_dotenv 
load_dotenv()

def get_engine():
     
    DB_USER = os.getenv("POSTGRES_USER","postgres")
    DB_HOST = os.getenv("POSTGRES_HOST","localhost")
    DB_PASSWORD = os.getenv("POSTGRES_PASSWORD","postgres")
    DB_PORT = os.getenv("POSTGRES_PORT","5432")
    DB_NAME = os.getenv("POSTGRES_DB","retail_erp_dw")

    DB_URL = f'postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
    
    return create_engine(DB_URL)


engine = get_engine()
if __name__ == "__main__":
    try:
        with engine.connect() as conn:
            result = conn.execute(text("select 1"))
            print("data base connected successfully.")
            print("test query quality", result.fetchone())
    except Exception as e:
        print("connection failed: ", e)
    

    