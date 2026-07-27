from pathlib import Path
import os

import duckdb
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parents[2]
load_dotenv(ROOT / ".env")

source = os.environ["PROCUREMENT_RAW_CSV"]
output = ROOT / "excel" / "internal_audit_sample.csv"

query = """
COPY (
    SELECT *
    FROM read_csv_auto(?, sample_size = 100000, all_varchar = true)
    USING SAMPLE 10000 ROWS
) TO ? (HEADER, DELIMITER ',');
"""

with duckdb.connect() as con:
    con.execute(query, [str(output), source])
print(f"Created internal sample: {output}")