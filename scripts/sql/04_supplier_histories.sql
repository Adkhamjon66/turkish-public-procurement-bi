-- Stage 04: supplier and buyer-supplier history using DuckDB windows.

CREATE OR REPLACE VIEW contract_histories AS
SELECT
    a.*,
    CASE
        WHEN supplier_clean IS NULL OR analysis_date IS NULL THEN NULL
        ELSE ROW_NUMBER() OVER (
            PARTITION BY supplier_clean
            ORDER BY analysis_date,
                     COALESCE(contract_id, ''),
                     COALESCE(tender_id, ''),
                     COALESCE(detail_tender_id, '')
        ) - 1
    END AS previous_supplier_wins_nationally,
    CASE
        WHEN supplier_clean IS NULL
          OR authority_id IS NULL
          OR analysis_date IS NULL THEN NULL
        ELSE ROW_NUMBER() OVER (
            PARTITION BY supplier_clean, authority_id
            ORDER BY analysis_date,
                     COALESCE(contract_id, ''),
                     COALESCE(tender_id, ''),
                     COALESCE(detail_tender_id, '')
        ) - 1
    END AS previous_supplier_buyer_wins,
    CASE
        WHEN supplier_clean IS NULL
          OR okas2 IS NULL
          OR analysis_date IS NULL THEN NULL
        ELSE ROW_NUMBER() OVER (
            PARTITION BY supplier_clean, okas2
            ORDER BY analysis_date,
                     COALESCE(contract_id, ''),
                     COALESCE(tender_id, ''),
                     COALESCE(detail_tender_id, '')
        ) - 1
    END AS previous_supplier_okas2_wins,
    CASE
        WHEN supplier_clean IS NULL
          OR authority_id IS NULL
          OR okas2 IS NULL
          OR analysis_date IS NULL THEN NULL
        ELSE ROW_NUMBER() OVER (
            PARTITION BY supplier_clean, authority_id, okas2
            ORDER BY analysis_date,
                     COALESCE(contract_id, ''),
                     COALESCE(tender_id, ''),
                     COALESCE(detail_tender_id, '')
        ) - 1
    END AS previous_supplier_buyer_okas2_wins,
    CASE
        WHEN supplier_clean IS NULL THEN NULL
        ELSE MIN(analysis_year) OVER (PARTITION BY supplier_clean)
    END AS first_observed_supplier_year,
    CASE
        WHEN supplier_clean IS NULL OR analysis_date IS NULL THEN NULL
        ELSE MIN(analysis_date) OVER (
            PARTITION BY supplier_clean, authority_id
        )
    END AS first_observed_buyer_supplier_date
FROM analytical_contracts AS a;

CREATE OR REPLACE TEMP TABLE final_contracts AS
SELECT
    h.*,
    CASE
        WHEN previous_supplier_wins_nationally IS NULL THEN NULL
        WHEN previous_supplier_wins_nationally = 0 THEN 'New'
        ELSE 'Returning'
    END AS supplier_status,
    CASE
        WHEN analysis_date IS NULL
          OR first_observed_buyer_supplier_date IS NULL THEN NULL
        ELSE DATE_DIFF('day', first_observed_buyer_supplier_date, analysis_date)
    END AS buyer_supplier_relationship_days,
    CASE
        WHEN authority_id IS NOT NULL THEN 'AUTH_ID:' || authority_id
        WHEN authority IS NOT NULL THEN 'AUTH_NAME:' || MD5(UPPER(authority))
        ELSE 'AUTH:UNKNOWN'
    END AS authority_key,
    CASE
        WHEN supplier_clean IS NOT NULL THEN 'SUP:' || MD5(supplier_clean)
        ELSE 'SUP:UNKNOWN'
    END AS supplier_key,
    'GEO:' || MD5(
        COALESCE(UPPER(province), 'UNKNOWN') || '|'
        || COALESCE(UPPER(authority_district), 'UNKNOWN')
    ) AS geography_key,
    CASE
        WHEN okas_code_clean IS NOT NULL THEN 'PRODUCT:' || okas_code_clean
        ELSE 'PRODUCT:UNKNOWN'
    END AS product_key,
    CASE
        WHEN method_code IS NOT NULL THEN 'METHOD_CODE:' || method_code
        WHEN method IS NOT NULL THEN 'METHOD_NAME:' || MD5(UPPER(method))
        ELSE 'METHOD:UNKNOWN'
    END AS procedure_key,
    CASE
        WHEN procurement_type IS NOT NULL
            THEN 'TYPE:' || MD5(UPPER(procurement_type))
        ELSE 'TYPE:UNKNOWN'
    END AS procurement_type_key
FROM contract_histories AS h;
