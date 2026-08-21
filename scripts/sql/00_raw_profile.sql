-- Stage 00: raw-data profiling
-- raw_contracts is created by the notebook from PROCUREMENT_RAW_CSV with
-- read_csv_auto(..., all_varchar = TRUE).

DESCRIBE raw_contracts;

SELECT
    COUNT(*) AS raw_rows,
    COUNT(*) - COUNT(DISTINCT contract_id) AS repeated_contract_id_rows,
    COUNT(DISTINCT tender_id) AS tenders,
    COUNT(DISTINCT contract_id) AS contracts,
    COUNT(DISTINCT authority_id) AS authorities,
    COUNT(DISTINCT supplier) AS supplier_names,
    COUNT(DISTINCT province) AS provinces,
    COUNT(DISTINCT okas_code) AS okas_codes,
    COUNT(DISTINCT method_code) AS method_codes,
    COUNT(DISTINCT type) AS procurement_types
FROM raw_contracts;

SELECT
    SUM(CASE WHEN TRIM(COALESCE(contract_id, '')) = '' THEN 1 ELSE 0 END)
        AS blank_contract_id,
    SUM(CASE WHEN TRIM(COALESCE(supplier, '')) = '' THEN 1 ELSE 0 END)
        AS blank_supplier,
    SUM(CASE WHEN TRIM(COALESCE(contract_price, '')) = '' THEN 1 ELSE 0 END)
        AS blank_contract_price,
    SUM(CASE WHEN TRIM(COALESCE(authority_id, '')) = '' THEN 1 ELSE 0 END)
        AS blank_authority_id,
    SUM(CASE WHEN TRIM(COALESCE(province, '')) = '' THEN 1 ELSE 0 END)
        AS blank_province
FROM raw_contracts;

-- Audit proposed numeric conversions before enforcing types.
WITH conversion_audit AS (
    SELECT
        'contract_price' AS field_name,
        'DECIMAL(20,2)' AS proposed_type,
        COUNT(*) FILTER (
            WHERE NULLIF(TRIM(contract_price), '') IS NULL
        ) AS missing_or_blank,
        COUNT(*) FILTER (
            WHERE NULLIF(TRIM(contract_price), '') IS NOT NULL
              AND TRY_CAST(TRIM(contract_price) AS DECIMAL(20,2)) IS NULL
        ) AS invalid_values
    FROM raw_contracts

    UNION ALL

    SELECT
        'num_valid_offers',
        'INTEGER',
        COUNT(*) FILTER (
            WHERE NULLIF(TRIM(num_valid_offers), '') IS NULL
        ),
        COUNT(*) FILTER (
            WHERE NULLIF(TRIM(num_valid_offers), '') IS NOT NULL
              AND TRY_CAST(TRIM(num_valid_offers) AS INTEGER) IS NULL
        )
    FROM raw_contracts

    UNION ALL

    SELECT
        'total_estimated_cost',
        'DECIMAL(20,2)',
        COUNT(*) FILTER (
            WHERE NULLIF(TRIM(total_estimated_cost), '') IS NULL
        ),
        COUNT(*) FILTER (
            WHERE NULLIF(TRIM(total_estimated_cost), '') IS NOT NULL
              AND TRY_CAST(TRIM(total_estimated_cost) AS DECIMAL(20,2)) IS NULL
        )
    FROM raw_contracts
)
SELECT *
FROM conversion_audit
ORDER BY field_name;

