# Public disclosure and Power BI publication

## Current status

The working PBIX is an internal analytical artifact. It embeds the imported semantic model and contains supplier identities and contract-level detail. It must not be uploaded to GitHub or published through an anonymous `Publish to web` link.

## GitHub publication boundary

Public repository:

- Source code and SQL
- Output-free notebook
- Environment specification
- Data-source and disclosure documentation
- Public-safe dashboard screenshots
- Semantic-model and DAX documentation

Excluded:

- `.env`
- Raw and processed datasets
- Internal Excel audit files
- PBIX/PBIT binaries
- Row-level extracts

## Future public Power BI release

A future public report should be built from a separate sanitized aggregate model. It should contain only approved fields and grains, such as:

- Year
- Clean province
- Procurement procedure and type
- Broad product group such as OKAS2
- Aggregate contract counts and values
- Aggregate competition indicators
- Disclosure-controlled geographic metrics

It should exclude:

- Supplier names and identifiers
- Tender and contract identifiers
- Free-text tender descriptions
- Exact row-level records
- The internal contract explorer
- Any unapproved or high-risk disclosure field

Hidden pages and hidden columns are usability features, not disclosure controls. Sensitive fields must be absent from the public semantic model.

## Publication checklist

- [ ] Disclosure register reviewed and approved
- [ ] Separate aggregate-only dataset produced
- [ ] Separate public PBIX created
- [ ] Internal pages and identity fields removed from the model
- [ ] Export and tooltip behavior tested
- [ ] Anonymous link tested in a private/incognito browser
- [ ] Public report reviewed for small-cell and re-identification risks
- [ ] Public URL added to the repository README

