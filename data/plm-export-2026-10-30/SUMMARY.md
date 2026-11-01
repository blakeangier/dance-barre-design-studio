# PLM Tracker export – Design Studio PLM Tracker (Sheet 1sKyxtErU0J9fD_HUrz5cIhKdD70EDjS4QuxMbxtELA0)
Exported 2026-10-30 (America/Toronto) as a read-only Drive export (`DesignStudio_PLM_live.xlsx`). Nothing in Drive was changed. CSVs hold **cached values** (formula results), not the formula text; the xlsx keeps the formulas.
Most tabs have a title row, a notes row, then headers on row 3. "Data rows" below means non-blank rows under the header.

| Tab | CSV | Data rows | Holds | Formula / derived columns |
|---|---|---|---|---|
| Tasks | Tasks.csv | 17 | Live open-task list (low stock, blocked orders/styles, fittings) | Everything except Done Date/Initials/Note (FILTER/LET/MAP formulas; the xlsx stores them as `__xludf.DUMMYFUNCTION` with cached values) |
| Tasks Done | Tasks_Done.csv | 300 rows, 0 filled | Completion log (Task Key, Done checkbox, Done Date, Initials, Note) | Still flagged? |
| README | README.csv | ~44 lines | Purpose, sources, sheet guide, config (default low-stock threshold = 2 m) | none (config/lookup) |
| Dashboard | Dashboard.csv | ~46 (26 blank spacer) | KPIs: inventory, styles by stage, orders | All figures are formulas |
| Materials | Materials.csv | 91 | Fabric/trim inventory (Material ID = Fabric#-Colour#) + raw registry fields | Net Price/m, On Hand, Reserved, Available, Projected, Stock Flag, Inventory Value, Low-list rank, Open Review Items |
| Transactions | Transactions.csv | 129 | Stock ledger (44 Receive opening balances, 85 Reserve) | ID Check |
| Suppliers | Suppliers.csv | 5 | Vendor directory | # Materials, # PO Lines, PO Value |
| Purchases | Purchases.csv | 44 | PO lines from the registry | Line Total, Discrepancy, ID Check |
| Orders | Orders.csv | 40 | Costume orders #001–#040 | Total Units, # Styles, # Approved, # Ready to Cut, Budget Total, Fabric Cost (BOM), Accessory Cost Total, Remaining, Fabric Cost/Costume |
| Styles | Styles.csv | 108 | Style records + 11 development stages | Production/Song, Fabric in Materials?, all ✓ columns, Stages Done, Next Stage, Size Qty |
| Sizes | Sizes.csv | 20 (61 blank) | Size breakdown per style (Order 005) | Most size cells + TOTAL |
| BOM | BOM.csv | 16 | Bill of materials / fabric costing (Order 005) | Style ID, Units, Total Required, Price/m Used, Cost/Unit, Total Cost |
| Fittings | Fittings.csv | 33 (76 blank) | Sample/prototype fit & approval | Sample # |
| Fabric Tags | Fabric_Tags.csv | ~413 lines | Printable bin labels (2-up grid layout, not a table) | Formula lookups from Materials |
| Needs Review | Needs_Review.csv | 87 | Conflicts/questions for Elaine (23 High, 47 Medium, 17 Low; all Open) | none |
| Form - New Order / Intake / Usage / Fittings / Low Stock / New Material / Style Stage | Form_*.csv | 0 each | Google Form response tabs (headers only) | none |

## Headers
- Tasks: Task Key, Type, Record, Detail, Order #, Priority, Source tab, | Recently done – Task Key, Done Date, Initials, Note, | helper ALL: Task Key…ALL: Source tab
- Tasks Done: Task Key, Done, Done Date, Initials, Note, Still flagged?
- Materials (43 cols): Material ID, Fabric #, Colour #, Colour Name, Fabric Name, Supplier Fabric Code, Supplier ID, Supplier (as written), Content, Fabric Type, Price/m (list), Discount %, Net Price/m, Width (cm), Cuttable Width (cm), GSM, Eco Cert., Care, Roll Status, Room / Shelf (Bin), Swatch Link, Stock Count Recorded?, On Hand (m), Reserved (m), Available (m), On Order (m), Projected (m), Reorder Point (m) override, Stock Flag, Inventory Value ($), Low-list rank, Needs Data, Open Review Items, Registry: Total In stock / ordered (m) / Supplier Order # / Order Date / Date Rec'd / Rec'd (m) / Allocated to order # / Order History / Notes, Source
- Transactions: Txn ID, Date, Type, Material ID, Qty (m), Order #, PO / Supplier Order #, Description, Entered By, Source, ID Check
- Suppliers: Supplier ID, Supplier, Contact, Email, Phone, Address, Website, Account #, Lead Time (days), Minimum Order, Volume Discount, Notes, Needs Data, # Materials, # PO Lines, PO Value ($), Source
- Purchases: PO Line, PO Ref / Supplier Order #, Supplier ID, Supplier, PO Date, Ship / ETA, Studio Order #(s), Material ID, Fabric/Col # (as written), Supplier Colour #, Fabric Name (as written), Qty Ordered (m), Price/m, Discount %, Line Total ($), Supplier Fabric Code, Assigned to Order # (as written), Line Note, Status, Received (m), Received Date, Discrepancy (m), ID Check, Source
- Orders: Order #, Production / Song, Status (as written), Order Date, Fitting Completion Target, Contacts, Contact Emails, Budget / Costume ($), Accessory, Accessory Cost / each ($), Accessory Qty Purchased, Female Total, Male Total, Total Units, # Styles, # Styles Approved, # Styles Ready to Cut, Budget Total ($), Fabric Cost – BOM ($), Accessory Cost Total ($), Remaining for Cut & Sew ($), Fabric Cost / Costume ($), Notes, Source
- Styles: Style Key, Style ID, Order #, Production / Song, Garment Description, Category, Group, Version, Child/Adult, Character / Note, Fabric ID, Fabric in Materials?, 11 stage columns (Pattern Complete…Ready to Cut), 11 ✓ columns, Stages Done (of 11), Next Stage Needed, Size Qty (Sizes), Flags, Source
- Sizes: Style Key, Order #, Garment, Group, Version, Style ID, SC, IC, IC-L, MC, MC-L, LC, XLC, XSA, SA, SA-L, MA, LA, XLA, XXLA, TOTAL, Notes, Source
- BOM: BOM Line, Style Key, Order #, Style ID, Garment, Version, Component, Placement, Material ID, Fabric ID as written, Fabric Name, Colour, Consumption / Unit (m), Consumption Basis, Units (from Sizes), Total Required (m), Price/m (source), Price/m Used, Cost / Unit ($), Total Cost ($), Flag, Source
- Fittings: Fitting ID, Order #, Style Key, Sample #, Garment, Version, Size, Pattern Status, Sample Complete, Fit Test Date, Corrections Required, Corrections Complete, Approval Status, Approved By, Approval Date, Comments / Photos link, Source
- Needs Review: Review ID, Sheet, Record, Source, Field, Original Text, Issue, Question for Elaine, Severity, Status, Resolution / Answer
- Form tabs: Timestamp + the matching entry fields of the target tab (see CSVs).

## Data quality issues
1. **F002-125 vs F002-25 (lime, Thalassa Swim Knit)**: the Order Form/Registry/Purchases say F002-125 "125 lime green", the Order 005 sheet says F002-25 "25 Lime Green" (no colour 25 in the registry). F002-125 exists in Materials, but the Order 005 contrast BOM lines have **blank Material ID**, so their cost uses the source price and stock isn't reserved. Logged in Needs Review, still open.
2. **Duplicate material**: F002-121 peach appears twice in the registry; loaded as `F002-121#2` (R001).
3. **No stock count for 47 of 91 materials** (Stock Flag NO COUNT); 9 LOW, 2 OVER-ALLOCATED. Some registry stock is free text ("27.5m + 40m", "15m+ 105m"), so no opening balance was loaded. Every Materials row has a Needs Data entry.
4. **Needs Review: 87 open items, 23 High**, none resolved.
5. Styles: 11 Fabric IDs NOT FOUND in Materials; 23 descriptions carried down from the row above; 2 Style #s used by more than one style; 2 non-standard; 2 have no Style #. Stage columns mix dates, Yes/No, "already completed", "?", "waiting…" text (✓ columns turn these into 1/0).
6. Purchases: 4 lines with NO ID, 2 with Material ID NOT IN MATERIALS; Ship/ETA is "ASAP" or blank (no dates); Status/Received not filled.
7. Orders: header detail only exists for Order 005; statuses are written inconsistently ("cancelled", "Cancelled-purchasing"); one email in Notes ends with a trailing period ("designstudio.dancebarre@gmail.com.").
8. Fittings: dates are blank (fit dates are on Styles instead — conflict logged); 76 blank template rows. Sizes has 61 blank/spacer rows, plus repeated sub-header/TOTAL rows in the block.
9. Mixed formats: dates are stored as datetimes in some tabs and as text in the Styles stage columns; Discount % is mostly blank (only 2 rows show 0.1) while Suppliers says "10% off at 100m+" and the Order Form says "-10% for 110m+".
10. Tasks: the formulas use new Sheets functions (FILTER/LET/MAP) that open in Excel as `__xludf.DUMMYFUNCTION`, so the xlsx can't recalculate this tab. Tasks Done has no entries yet. All Form response tabs are empty.

## Sensitive data
- Phone: Telio showroom 416 532 9444 (Suppliers). Emails: toronto@telio.com, plus client/studio emails in Orders (dancebarredirectors@dancebarre.ca, elitedancebarre@gmail.com, designstudio.dancebarre@gmail.com). Contact names (e.g. Sarah Haunts at Telio, Melissa at Ann's).
- Budgets/costs per order and supplier pricing. No staff pay, wage or salary data found.
