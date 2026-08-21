# Power BI dashboard guide

## Public-safe analytical pages

### 01 Executive Overview

Purpose: summarize national procurement activity and provide the main cross-filtering entry point.

Core content:

- Contract count
- Total contract value
- Supplier and authority counts
- Average contract value
- Average valid offers
- Year, province, procedure, procurement type, and product-group slicers
- Time trends and categorical rankings

### 02 Geographic Analysis

Purpose: compare procurement scale and competition across validated provinces and districts.

Core content:

- Coordinate-based map restricted to `map_eligible = TRUE`
- Province rankings by contract value
- Geographic competition indicators
- Cleaned province and district labels
- Location-level tooltips

### 03 Competition Analysis

Purpose: examine valid-offer intensity, single bidding, rebates, and above-estimate awards.

Core content:

- Competition-eligible contract denominator
- Single-bid rate
- Average valid offers
- Average and median rebates
- Procedure, geography, type, and time comparisons
- Minimum-observation filters for rate rankings

## Internal-only pages

### 04 Suppliers & Authorities

Contains supplier identities and buyer-supplier comparisons. It is useful for internal analysis but must be reviewed before any public release.

### 06 Contract Explorer — Internal

Contains row-level identifiers and detailed records. It is deliberately excluded from public screenshots and any future anonymous report.

## Report behavior

- Dimension tables filter the detailed fact table through active one-to-many relationships.
- Filters travel in a single direction from dimensions to the fact table.
- Common slicers are synchronized across analytical pages.
- Technical keys are hidden from Report view.
- Records outside the intended 2010–2024 coverage are retained for audit but excluded from public analytical pages.
- The market-year HHI table uses a different grain and is not connected directly to the contract fact table.

