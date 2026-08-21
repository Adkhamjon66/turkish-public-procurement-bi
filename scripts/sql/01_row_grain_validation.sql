-- Stage 01: establish the source row grain.

-- Repeated contract IDs are expected when tenders contain multiple awarded
-- lots or suppliers, so contract_id alone is not assumed to be the row key.
SELECT
    contract_id,
    COUNT(*) AS rows_per_contract,
    COUNT(DISTINCT supplier) AS suppliers,
    COUNT(DISTINCT detail_tender_id) AS tender_details
FROM raw_contracts
GROUP BY contract_id
HAVING COUNT(*) > 1
ORDER BY rows_per_contract DESC
LIMIT 100;

-- Test for completely identical rows.
SELECT
    COUNT(*) AS total_rows,
    (SELECT COUNT(*) FROM (SELECT DISTINCT * FROM raw_contracts))
        AS distinct_full_rows,
    COUNT(*) - (
        SELECT COUNT(*) FROM (SELECT DISTINCT * FROM raw_contracts)
    ) AS exact_duplicate_excess_rows
FROM raw_contracts;

-- Candidate compound-key diagnostic. A zero-row result indicates uniqueness.
SELECT
    tender_id,
    detail_tender_id,
    contract_id,
    supplier,
    COUNT(*) AS duplicate_rows
FROM raw_contracts
GROUP BY
    tender_id,
    detail_tender_id,
    contract_id,
    supplier
HAVING COUNT(*) > 1
ORDER BY duplicate_rows DESC
LIMIT 100;

