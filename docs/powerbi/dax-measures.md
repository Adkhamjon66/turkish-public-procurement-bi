# DAX measures

The report stores explicit measures in a dedicated `_Measures` table. The definitions below document the main business logic independently of the PBIX binary.

## Scale and participation

```DAX
Contract Rows =
COUNTROWS ( fact_contracts )

Contract Count =
DISTINCTCOUNT ( fact_contracts[contract_id] )

Total Contract Value =
SUM ( fact_contracts[contract_price] )

Total Estimated Cost =
SUM ( fact_contracts[analytical_estimated_cost] )

Supplier Count =
DISTINCTCOUNT ( fact_contracts[supplier_key] )

Authority Count =
DISTINCTCOUNT ( fact_contracts[authority_key] )

Average Contract Value =
DIVIDE ( [Total Contract Value], [Contract Count] )

Average Valid Offers =
AVERAGE ( fact_contracts[num_valid_offers] )
```

## Competition

```DAX
Competition-Eligible Contracts =
CALCULATE (
    [Contract Count],
    fact_contracts[positive_valid_offers] = TRUE ()
)

Single-Bid Contracts =
CALCULATE (
    [Contract Count],
    fact_contracts[single_bid] = TRUE ()
)

Single-Bid Rate =
DIVIDE ( [Single-Bid Contracts], [Competition-Eligible Contracts] )

Average Rebate =
AVERAGE ( fact_contracts[rebate] )

Median Rebate =
MEDIAN ( fact_contracts[rebate] )
```

The competition denominator intentionally excludes missing and zero valid-offer values.

## Price outcomes

```DAX
Contracts with Estimate =
CALCULATE (
    [Contract Count],
    NOT ISBLANK ( fact_contracts[analytical_estimated_cost] ),
    fact_contracts[analytical_estimated_cost] > 0
)

Above-Estimate Contracts =
CALCULATE (
    [Contract Count],
    fact_contracts[contract_above_estimate] = TRUE ()
)

Above-Estimate Rate =
DIVIDE ( [Above-Estimate Contracts], [Contracts with Estimate] )

Average Price-to-Estimate Ratio =
AVERAGE ( fact_contracts[price_to_estimate_ratio] )
```

## Procurement characteristics

```DAX
Electronic Contracts =
CALCULATE (
    [Contract Count],
    fact_contracts[is_electronic] = TRUE ()
)

Electronic Procurement Rate =
DIVIDE ( [Electronic Contracts], [Contract Count] )

Multi-Lot Contracts =
CALCULATE (
    [Contract Count],
    fact_contracts[is_multi_lot] = TRUE ()
)

Multi-Lot Rate =
DIVIDE ( [Multi-Lot Contracts], [Contract Count] )
```

## Supplier status

```DAX
New Supplier Contracts =
CALCULATE (
    [Contract Count],
    fact_contracts[supplier_status] = "New"
)

New Supplier Share =
DIVIDE ( [New Supplier Contracts], [Contract Count] )
```

Percentage measures are formatted as percentages in Power BI rather than multiplied by 100 in DAX.

