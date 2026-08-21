-- Stage 06: Power BI star schema.

CREATE OR REPLACE TEMP TABLE fact_contracts AS
SELECT
    ROW_NUMBER() OVER () AS contract_row_key,
    tender_id,
    detail_tender_id,
    contract_id,
    announcement_id,
    ikn,
    authority_key,
    supplier_key,
    geography_key,
    product_key,
    procedure_key,
    procurement_type_key,
    analysis_date,
    analysis_date_source,
    analysis_year,
    analysis_month,
    contract_price,
    analytical_estimated_cost,
    price_to_estimate_ratio,
    rebate,
    num_offers,
    num_valid_offers,
    single_bid,
    contract_above_estimate,
    analysis_date_outside_expected_coverage,
    previous_supplier_wins_nationally,
    previous_supplier_buyer_wins,
    previous_supplier_okas2_wins,
    previous_supplier_buyer_okas2_wins,
    supplier_status,
    buyer_supplier_relationship_days
FROM final_contracts;

-- Select one deterministic descriptive record for each dimension key.
CREATE OR REPLACE TEMP TABLE dim_authority AS
SELECT
    authority_key,
    authority_id,
    authority,
    parent_authority,
    top_authority_code,
    top_authority_name
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY authority_key
            ORDER BY analysis_date DESC NULLS LAST, contract_id DESC
        ) AS dimension_row_number
    FROM final_contracts
)
WHERE dimension_row_number = 1;

CREATE OR REPLACE TEMP TABLE dim_supplier AS
SELECT
    supplier_key,
    supplier_clean AS supplier_name,
    first_observed_supplier_year
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY supplier_key
            ORDER BY analysis_date DESC NULLS LAST, contract_id DESC
        ) AS dimension_row_number
    FROM final_contracts
)
WHERE dimension_row_number = 1;

CREATE OR REPLACE TEMP TABLE dim_product AS
SELECT
    product_key,
    okas_code_raw,
    okas_code_clean,
    okas2,
    okas_desc
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY product_key
            ORDER BY analysis_date DESC NULLS LAST, contract_id DESC
        ) AS dimension_row_number
    FROM final_contracts
)
WHERE dimension_row_number = 1;

CREATE OR REPLACE TEMP TABLE dim_procedure AS
SELECT procedure_key, method_code, method, scope
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY procedure_key
            ORDER BY analysis_date DESC NULLS LAST, contract_id DESC
        ) AS dimension_row_number
    FROM final_contracts
)
WHERE dimension_row_number = 1;

CREATE OR REPLACE TEMP TABLE dim_procurement_type AS
SELECT procurement_type_key, procurement_type
FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY procurement_type_key
            ORDER BY analysis_date DESC NULLS LAST, contract_id DESC
        ) AS dimension_row_number
    FROM final_contracts
)
WHERE dimension_row_number = 1;

CREATE OR REPLACE TEMP TABLE dim_date AS
WITH bounds AS (
    SELECT MIN(analysis_date) AS minimum_date,
           MAX(analysis_date) AS maximum_date
    FROM final_contracts
    WHERE analysis_date IS NOT NULL
),
calendar AS (
    SELECT generated_date::DATE AS date_day
    FROM bounds,
         GENERATE_SERIES(
             minimum_date, maximum_date, INTERVAL 1 DAY
         ) AS dates(generated_date)
)
SELECT
    date_day AS date,
    EXTRACT(YEAR FROM date_day)::INTEGER AS year,
    EXTRACT(QUARTER FROM date_day)::INTEGER AS quarter_number,
    'Q' || EXTRACT(QUARTER FROM date_day)::INTEGER AS quarter,
    EXTRACT(MONTH FROM date_day)::INTEGER AS month_number,
    STRFTIME(date_day, '%B') AS month_name,
    STRFTIME(date_day, '%Y-%m') AS year_month,
    EXTRACT(DAY FROM date_day)::INTEGER AS day_of_month,
    EXTRACT(ISODOW FROM date_day)::INTEGER AS iso_day_of_week,
    STRFTIME(date_day, '%A') AS day_name
FROM calendar;

