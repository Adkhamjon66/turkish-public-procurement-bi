# Source Register

This document records the source datasets used in the Turkish Public Procurement Intelligence Dashboard.

## Source 1 — Raw EKAP contract archive

| Field | Recorded information |
|---|---|
| Source ID | `SRC_EKAP_CONTRACTS_01` |
| File name | `merged_contract_level_2010_2024.csv` |
| Origin | EKAP — Electronic Public Procurement Platform of the Turkish Public Procurement Authority |
| Collection period | 2024–2026 |
| Coverage period | 2010–2024 |
| Grain | One raw procurement record per row; the exact contract/lot grain will be verified during the data audit |
| Expected rows | 2,370,736 |
| Columns | 47 |
| File size | 1.752GB |
| SHA-256 hash | 87334963B054FB24838FE8A11D6817181DE3833695AA03EAF29B8823EF3E6229 |
| Owner | Adkhamjon Sotiboldiev |
| Local location | `data/raw/` |
| Redistribution status | Unknown — internal use only until redistribution conditions are verified |
| Notes | This is the only starting dataset. All cleaning, validation, derived variables, supplier histories, SQL tables, and Power BI tables will be constructed from this raw file. The file must never be edited in place. |
