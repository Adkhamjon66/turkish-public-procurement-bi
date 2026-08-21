-- Stage 05: descriptive market concentration.
-- Market grain: analysis_year x province x OKAS2 product group.

CREATE OR REPLACE TEMP TABLE market_supplier_values AS
SELECT
    analysis_year,
    province,
    okas2,
    supplier_key,
    SUM(contract_price) AS supplier_contract_value,
    COUNT(*) AS supplier_contract_rows
FROM final_contracts
WHERE analysis_year IS NOT NULL
  AND province IS NOT NULL
  AND okas2 IS NOT NULL
  AND supplier_key IS NOT NULL
  AND contract_price >= 0
GROUP BY analysis_year, province, okas2, supplier_key;

CREATE OR REPLACE TEMP TABLE market_supplier_shares AS
SELECT
    *,
    supplier_contract_value
        / NULLIF(SUM(supplier_contract_value) OVER (
            PARTITION BY analysis_year, province, okas2
        ), 0) AS supplier_value_share
FROM market_supplier_values;

CREATE OR REPLACE TEMP TABLE agg_market_year AS
WITH concentration AS (
    SELECT
        analysis_year,
        province,
        okas2,
        COUNT(*) AS supplier_count,
        SUM(supplier_contract_value) AS known_supplier_contract_value,
        MAX(supplier_value_share) AS top_supplier_share,
        SUM(POWER(supplier_value_share, 2)) AS hhi_0_1
    FROM market_supplier_shares
    GROUP BY analysis_year, province, okas2
),
competition AS (
    SELECT
        analysis_year,
        province,
        okas2,
        COUNT(*) AS contract_rows,
        SUM(contract_price) FILTER (WHERE contract_price >= 0)
            AS total_contract_value,
        AVG(CAST(single_bid AS INTEGER)) FILTER (
            WHERE NOT valid_offers_missing
        ) AS single_bid_share,
        AVG(num_valid_offers) AS mean_valid_bids,
        AVG(rebate) AS mean_rebate,
        MEDIAN(rebate) AS median_rebate
    FROM final_contracts
    WHERE analysis_year IS NOT NULL
      AND province IS NOT NULL
      AND okas2 IS NOT NULL
    GROUP BY analysis_year, province, okas2
)
SELECT
    c.analysis_year,
    c.province,
    c.okas2,
    c.contract_rows,
    c.total_contract_value,
    concentration.supplier_count,
    concentration.known_supplier_contract_value,
    concentration.top_supplier_share,
    concentration.hhi_0_1,
    concentration.hhi_0_1 * 10000 AS hhi_0_10000,
    c.single_bid_share,
    c.mean_valid_bids,
    c.mean_rebate,
    c.median_rebate
FROM competition AS c
LEFT JOIN concentration
    USING (analysis_year, province, okas2);

