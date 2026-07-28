import os
from pathlib import Path

import duckdb
from dotenv import load_dotenv


# Find the repository root from this script's location.
ROOT = Path(__file__).resolve().parents[2]

# Define and create the validation-output folder.
VALIDATION_DIR = ROOT / "docs" / "validation"
VALIDATION_DIR.mkdir(parents=True, exist_ok=True)

# Load local configuration and retrieve the raw CSV path.
load_dotenv(ROOT / ".env")
source = os.environ["PROCUREMENT_RAW_CSV"]

# Define the row-count query.
query = """
SELECT COUNT(*)
FROM read_csv_auto(?, all_varchar = true)
"""

# Execute the query and retrieve the count.
with duckdb.connect() as con:
    row_count = con.execute(query, [source]).fetchone()[0]

# Display the result.
print(f"Rows: {row_count:,}")










