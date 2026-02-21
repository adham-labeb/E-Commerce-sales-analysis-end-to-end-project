# Silver Layer Data Cleaning Steps

## Overview
The Silver Layer sits between the raw data (Bronze layer) and our final business tables (Gold layer). The process is handled inside a master stored procedure called `Silver.Load_Silver`. This procedure reads every table injected into the Bronze schema, cleans and standardizes the data, handles null values and missing properties, and enforces data integrity rules before dumping it precisely into the `Silver` tables.

## Execution Workflow
When `EXEC Silver.Load_Silver` runs, it creates timestamps mapping the load durations and systematically truncates (empties) old data from the Silver tables to overwrite them fresh, guaranteeing consistency.

---

### Step 1: Cleaning `crm_cust_info`
1. **Handling Duplicates**: Evaluates identical rows tracking `cst_id` by grabbing the most recent entry explicitly (based on `cst_create_date DESC`).
2. **Text Normalization**: Explicitly utilizes `TRIM` to remove trailing and leading spaces from first and last names.
3. **Categorical Standardizations**:
   - `cst_marital_status`: Validates variables reading `M` into `'Married'`, `s` into `'Single'`, and flags any unexpected anomalies automatically as `'Unknown'`.
   - `cst_gndr`: Molds basic `F` values into `'Female'` and `M` into `'Male'`. Invalid inputs shift directly to `'Unknown'`.

---

### Step 2: Cleaning `crm_prd_info`
1. **Key Extraction**: Parses exact characters utilizing `SUBSTRING`. Slices `prd_key` isolating out category sub-identifiers (`cat_id`). Replaces tricky dashes `-` with underscores `_`.
2. **Handling Null Costs**: Flags isolated `NULL` price tags over `prd_cost` directly shifting them to `0` with the `ISNULL` function.
3. **Standardizing Categories**: Tracks single alphabetical mappings on `prd_line`:
   - `M` ➔ `'Mountain'`
   - `R` ➔ `'Road'`
   - `S` ➔ `'Other Sales'`
   - `T` ➔ `'Touring'`
4. **Dates Initialization**: Generates strict `DATE` casts evaluating product active durations (`prd_start_dt` to `prd_end_dt`).

---

### Step 3: Cleaning `crm_sales_details`
1. **Date Validations**: Looks for generic null representations (e.g., generic `0` mappings) spanning `sls_order_dt`, `sls_ship_dt`, and `sls_due_dt`. If characters stray wildly (e.g., aren't exactly 8 numbers mapping YYYYMMDD formats), it marks them `NULL`. Otherwise, they format accurately to absolute `DATE` bindings.
2. **Profit Margins Calculation**: Aggressively standardizes sales. If `sls_sales` arrives empty, negative, or mathematically flawed, it forces re-calculation strictly via `sls_quantity * ABS(sls_price)`.
3. **Price Back-Calculation**: Reevaluates isolated prices missing entries (`0` or `NULL`) by reversing the math on validated sales variables (`sls_sales / sls_quantity`).

---

### Step 4: Cleaning `erp_CUST_AZ12`
1. **Key Reformatting**: Scans IDs (`CID`) tracking legacy system mappings starting with `"NAS"`. Trims the prefix explicitly to match generalized CRM IDs.
2. **Age Filtering**: Verifies reasonable birth schedules (`BDATE`). Flags anyone seemingly born securely in the future (where timestamp is greater than `GETDATE()`) mapping them logically to `NULL`.
3. **Gender Consolidation**: Fixes trailing arrays matching explicitly to `M` or `Male` tracking back to generalized formatting (`'Male'`). Validates female boundaries accurately. Converts blanks to `'n/a'`.

---

### Step 5: Cleaning `erp_LOC_A101`
1. **Prefix Trims**: Scrubs `CID` dashes specifically linking standard formats.
2. **Country Acronyms**: Fixes locational abbreviations bridging logic cleanly:
   - `'US'` or `'USA'` ➔ `'United States'`
   - `'DE'` ➔ `'Germany'`
   - Empty metrics are mapped explicitly to `'n/a'`.

---

### Step 6: Appending `PX_CAT_G1V2`
This table bridges raw maintenance criteria. It passes through the pipeline cleanly mapping structural internal classifications matching exactly from Bronze mapping directly to `ID`, `CAT`, `SUBCAT`, and `MAINTENANCE` variables.

