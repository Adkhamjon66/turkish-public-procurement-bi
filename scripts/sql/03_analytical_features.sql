-- Stage 03: derive analysis-ready measures without modifying the clean view.

CREATE OR REPLACE VIEW analytical_contracts AS
WITH standardized AS (
    SELECT
        c.*,
        CASE
            WHEN is_multi_lot AND lot_estimated_cost > 0 THEN lot_estimated_cost
            WHEN total_estimated_cost > 0 THEN total_estimated_cost
            ELSE NULL
        END AS analytical_estimated_cost,
        UPPER(REGEXP_REPLACE(NULLIF(TRIM(supplier), ''), '\s+', ' ', 'g'))
            AS supplier_clean,
        okas_code AS okas_code_raw,
        NULLIF(
            REGEXP_REPLACE(COALESCE(okas_code, ''), '[^0-9]', '', 'g'),
            ''
        ) AS okas_code_clean,
        COALESCE(contract_date, result_announcement_date, tender_date)
            AS analysis_date,
        CASE
            WHEN contract_date IS NOT NULL THEN 'contract_date'
            WHEN result_announcement_date IS NOT NULL THEN 'result_announcement_date'
            WHEN tender_date IS NOT NULL THEN 'tender_date'
            ELSE NULL
        END AS analysis_date_source
    FROM clean_contracts AS c
)
SELECT
    standardized.*,
    LEFT(okas_code_clean, 2) AS okas2,
    contract_price / NULLIF(analytical_estimated_cost, 0)
        AS price_to_estimate_ratio,
    1 - contract_price / NULLIF(analytical_estimated_cost, 0) AS rebate,
    num_valid_offers IS NULL AS valid_offers_missing,
    num_valid_offers = 0 AS zero_valid_offers,
    num_valid_offers = 1 AS single_bid,
    num_valid_offers > 0 AS positive_valid_offers,
    contract_price > analytical_estimated_cost AS contract_above_estimate,
    contract_price / NULLIF(analytical_estimated_cost, 0) > 10
        AS extreme_price_to_estimate_ratio,
    analysis_date < DATE '2010-01-01'
        OR analysis_date > DATE '2024-12-31'
        AS analysis_date_outside_expected_coverage,
    EXTRACT(YEAR FROM analysis_date)::INTEGER AS analysis_year,
    EXTRACT(MONTH FROM analysis_date)::INTEGER AS analysis_month,
    EXTRACT(YEAR FROM contract_date)::INTEGER AS contract_year,
    EXTRACT(MONTH FROM contract_date)::INTEGER AS contract_month
FROM standardized;

