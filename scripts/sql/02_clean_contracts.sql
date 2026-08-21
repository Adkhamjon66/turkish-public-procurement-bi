-- Stage 02: safely type and standardize the contract source.
-- The raw view is preserved unchanged for traceability.

CREATE OR REPLACE VIEW clean_contracts AS
SELECT
    NULLIF(TRIM(tender_id), '') AS tender_id,
    NULLIF(TRIM(detail_tender_id), '') AS detail_tender_id,
    NULLIF(TRIM(contract_id), '') AS contract_id,
    NULLIF(TRIM(announcement_id), '') AS announcement_id,
    NULLIF(TRIM(ikn), '') AS ikn,

    NULLIF(TRIM(tender_name), '') AS tender_name,
    NULLIF(TRIM(authority), '') AS authority,
    NULLIF(TRIM(authority_id), '') AS authority_id,
    NULLIF(TRIM(province), '') AS province,
    NULLIF(TRIM(authority_district), '') AS authority_district,
    NULLIF(TRIM(parent_authority), '') AS parent_authority,
    NULLIF(TRIM(top_authority_code), '') AS top_authority_code,
    NULLIF(TRIM(top_authority_name), '') AS top_authority_name,

    NULLIF(TRIM(okas_code), '') AS okas_code,
    NULLIF(TRIM(okas_desc), '') AS okas_desc,
    TRY_CAST(NULLIF(TRIM(okas_count), '') AS INTEGER) AS okas_count,

    NULLIF(TRIM(method), '') AS method,
    NULLIF(TRIM(method_code), '') AS method_code,
    NULLIF(TRIM(type), '') AS procurement_type,
    NULLIF(TRIM(scope), '') AS scope,
    NULLIF(TRIM(status), '') AS status,
    NULLIF(TRIM(status_code), '') AS status_code,

    CASE TRIM(is_electronic)
        WHEN '1' THEN TRUE WHEN '0' THEN FALSE ELSE NULL
    END AS is_electronic,
    CASE TRIM(is_partial)
        WHEN '1' THEN TRUE WHEN '0' THEN FALSE ELSE NULL
    END AS is_partial,
    CASE TRIM(is_invitation_only)
        WHEN '1' THEN TRUE WHEN '0' THEN FALSE ELSE NULL
    END AS is_invitation_only,
    CASE TRIM(lot_estimate_missing)
        WHEN '1' THEN TRUE WHEN '0' THEN FALSE ELSE NULL
    END AS lot_estimate_missing,
    CASE TRIM(is_multi_lot)
        WHEN '1' THEN TRUE WHEN '0' THEN FALSE ELSE NULL
    END AS is_multi_lot,

    -- Retain the original text alongside parsed dates where auditability matters.
    NULLIF(TRIM(tender_datetime), '') AS tender_datetime_raw,
    NULLIF(TRIM(contract_date), '') AS contract_date_raw,

    COALESCE(
        TRY_CAST(NULLIF(TRIM(tender_datetime), '') AS TIMESTAMP),
        TRY_STRPTIME(NULLIF(TRIM(tender_datetime), ''), '%d.%m.%Y %H:%M')
    ) AS tender_datetime,
    COALESCE(
        TRY_CAST(NULLIF(TRIM(tender_date), '') AS DATE),
        CAST(TRY_STRPTIME(NULLIF(TRIM(tender_date), ''), '%m/%d/%Y') AS DATE)
    ) AS tender_date,
    COALESCE(
        TRY_CAST(NULLIF(TRIM(tender_announcement_date), '') AS DATE),
        CAST(TRY_STRPTIME(
            NULLIF(TRIM(tender_announcement_date), ''), '%m/%d/%Y'
        ) AS DATE)
    ) AS tender_announcement_date,
    COALESCE(
        TRY_CAST(NULLIF(TRIM(result_announcement_date), '') AS DATE),
        CAST(TRY_STRPTIME(
            NULLIF(TRIM(result_announcement_date), ''), '%m/%d/%Y'
        ) AS DATE)
    ) AS result_announcement_date,
    COALESCE(
        TRY_CAST(NULLIF(TRIM(contract_date), '') AS DATE),
        CAST(TRY_STRPTIME(NULLIF(TRIM(contract_date), ''), '%m/%d/%Y') AS DATE)
    ) AS contract_date,

    TRY_CAST(NULLIF(TRIM(days_announce_to_contract), '') AS INTEGER)
        AS days_announce_to_contract,
    TRY_CAST(NULLIF(TRIM(total_estimated_cost), '') AS DECIMAL(20,2))
        AS total_estimated_cost,
    TRY_CAST(NULLIF(TRIM(lot_estimated_cost), '') AS DECIMAL(20,2))
        AS lot_estimated_cost,
    TRY_CAST(NULLIF(TRIM(contract_price), '') AS DECIMAL(20,2))
        AS contract_price,
    NULLIF(TRIM(supplier), '') AS supplier,
    TRY_CAST(NULLIF(TRIM(num_offers), '') AS INTEGER) AS num_offers,
    TRY_CAST(NULLIF(TRIM(num_valid_offers), '') AS INTEGER)
        AS num_valid_offers,
    TRY_CAST(NULLIF(TRIM(document_count), '') AS INTEGER) AS document_count,
    TRY_CAST(NULLIF(TRIM(total_lots_in_tender), '') AS INTEGER)
        AS total_lots_in_tender
FROM raw_contracts;

