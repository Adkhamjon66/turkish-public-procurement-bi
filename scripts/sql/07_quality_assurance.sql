-- Stage 07: semantic-model and output quality assurance.

SELECT
    COUNT(*) AS fact_rows,
    COUNT(DISTINCT contract_row_key) AS distinct_fact_row_keys,
    COUNT(DISTINCT contract_id) AS distinct_contract_ids,
    SUM(contract_price) AS total_contract_value,
    MIN(analysis_year) AS minimum_analysis_year,
    MAX(analysis_year) AS maximum_analysis_year
FROM fact_contracts;

SELECT 'dim_authority' AS table_name,
       COUNT(*) AS rows,
       COUNT(DISTINCT authority_key) AS distinct_keys
FROM dim_authority
UNION ALL
SELECT 'dim_supplier', COUNT(*), COUNT(DISTINCT supplier_key)
FROM dim_supplier
UNION ALL
SELECT 'dim_geography', COUNT(*), COUNT(DISTINCT geography_key)
FROM dim_geography
UNION ALL
SELECT 'dim_product', COUNT(*), COUNT(DISTINCT product_key)
FROM dim_product
UNION ALL
SELECT 'dim_procedure', COUNT(*), COUNT(DISTINCT procedure_key)
FROM dim_procedure
UNION ALL
SELECT 'dim_procurement_type', COUNT(*), COUNT(DISTINCT procurement_type_key)
FROM dim_procurement_type
UNION ALL
SELECT 'dim_date', COUNT(*), COUNT(DISTINCT date)
FROM dim_date;

-- All results should be zero.
SELECT
    COUNT(*) FILTER (WHERE a.authority_key IS NULL)
        AS unmatched_authority_keys,
    COUNT(*) FILTER (WHERE s.supplier_key IS NULL)
        AS unmatched_supplier_keys,
    COUNT(*) FILTER (WHERE g.geography_key IS NULL)
        AS unmatched_geography_keys,
    COUNT(*) FILTER (WHERE p.product_key IS NULL)
        AS unmatched_product_keys,
    COUNT(*) FILTER (WHERE pr.procedure_key IS NULL)
        AS unmatched_procedure_keys,
    COUNT(*) FILTER (WHERE pt.procurement_type_key IS NULL)
        AS unmatched_procurement_type_keys,
    COUNT(*) FILTER (
        WHERE f.analysis_date IS NOT NULL AND d.date IS NULL
    ) AS unmatched_date_keys
FROM fact_contracts AS f
LEFT JOIN dim_authority AS a
    ON f.authority_key = a.authority_key
LEFT JOIN dim_supplier AS s
    ON f.supplier_key = s.supplier_key
LEFT JOIN dim_geography AS g
    ON f.geography_key = g.geography_key
LEFT JOIN dim_product AS p
    ON f.product_key = p.product_key
LEFT JOIN dim_procedure AS pr
    ON f.procedure_key = pr.procedure_key
LEFT JOIN dim_procurement_type AS pt
    ON f.procurement_type_key = pt.procurement_type_key
LEFT JOIN dim_date AS d
    ON f.analysis_date = d.date;

-- HHI must remain within its mathematical bounds.
SELECT
    COUNT(*) FILTER (WHERE hhi_0_1 < 0 OR hhi_0_1 > 1)
        AS invalid_hhi_0_1,
    COUNT(*) FILTER (WHERE hhi_0_10000 < 0 OR hhi_0_10000 > 10000)
        AS invalid_hhi_0_10000,
    COUNT(*) FILTER (WHERE top_supplier_share < 0 OR top_supplier_share > 1)
        AS invalid_top_supplier_share
FROM agg_market_year;

