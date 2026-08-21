# DuckDB SQL portfolio

These files present the main SQL stages used in the Jupyter pipeline in a recruiter-friendly format.

The executable source of truth is [`../../notebooks/procurement_project.ipynb`](../../notebooks/procurement_project.ipynb), where Python:

1. reads `PROCUREMENT_RAW_CSV` from the local `.env` file;
2. safely injects the escaped local path when creating `raw_contracts`;
3. runs the DuckDB SQL stages in order;
4. performs geography matching with authoritative reference tables; and
5. exports validated Parquet tables for Power BI.

## Execution order

| File | Purpose |
|---|---|
| `00_raw_profile.sql` | Profile schema, blanks, distinct values, and proposed types |
| `01_row_grain_validation.sql` | Test duplicates and establish the analytical row grain |
| `02_clean_contracts.sql` | Standardize text and safely type dates, counts, flags, and amounts |
| `03_analytical_features.sql` | Create analysis dates, competition flags, rebates, and cleaned classifications |
| `04_supplier_histories.sql` | Use window functions to construct prior-win and relationship histories |
| `05_market_hhi.sql` | Calculate market supplier shares and HHI |
| `06_star_schema.sql` | Build the fact table and dimensions for Power BI |
| `07_quality_assurance.sql` | Reconcile keys, rows, ranges, and referential integrity |

## Important design decisions

- Raw fields are initially read as text so DuckDB does not silently impose incorrect types.
- `TRY_CAST` converts malformed values to `NULL` instead of terminating the pipeline.
- Raw identifiers remain strings even when they contain only digits.
- Cleaning creates new views and never overwrites the raw source.
- Supplier histories use only earlier observations ordered by analysis date.
- HHI is calculated at the explicit `analysis_year × province × okas2` market grain.
- Fact tables are never joined directly to each other in the Power BI semantic model.

The SQL files use the logical relation names created by earlier stages. They are intended to be read together with the notebook, which supplies path handling, dynamic date-audit expressions, geography reference data, and export locations.

