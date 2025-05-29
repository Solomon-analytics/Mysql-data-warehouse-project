/*
=====================================================================================================
Quality Checks
=====================================================================================================
Script Purpose:
        This script performs various qualiaty checks for data consistency, accuracy, and standarization
        across the 'silver' schema. It includes checks for:
        - Null or duplicate primary keys.
        - unwanted spaces in string fields.
        - Data standardization and consistency
        - Invalid date ranges and orders
        - Data consistency between related fields
Usage Notes:
- Run these checks after data loading silver layer.
- Investigate and resolve any discrepancies found during the checks.
======================================================================================================
*/

-- Data Trasnaformation & Data Cleansing


SELECT *
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

-- ranking by cst_create_date

SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id = 29466;

-- using the same logic to explore data

SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info;

-- outcome shows there are cst_id which are duplicates because it returns (1,2,3) for flag_last

SELECT *
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info) t
WHERE flag_last != 1;
-- outcome reveals dataset contails 8 rows of duplicates relating to 6 distinct cst_id

-- Transforming: duplicate issues
SELECT *
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL) t
WHERE flag_last = 1;


-- Transforming Extra space issues in cst_firstname & cst_lastname:
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL) t
WHERE flag_last = 1;

-- Transforming: changing the gndr mapping from abbreviation to full naming for cst_gndr and cst_marital_status

SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
     WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
     ELSE 'N/a' END cst_marital_status,
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
     ELSE 'N/a' END cst_gndr,
cst_create_date
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL) t
WHERE flag_last = 1;

-- Insert into the silver table

INSERT INTO silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date)
SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
     WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
     ELSE 'N/a' END cst_marital_status, -- Normalise marital status values to readable format
CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
     ELSE 'N/a' END cst_gndr, -- Normalize gender values to readable format
cst_create_date
FROM (
SELECT *,
ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL) t
WHERE flag_last = 1; -- Select the most recent record per customer


-- Exploring: data quanlity issues in the table: bronze.crm_prd_info

SELECT *
FROM bronze.crm_prd_info;

-- Check for duplicates

SELECT 
prd_id,
COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Deriving new column from prd_key

SELECT
prd_id,
prd_key,
SUBSTRING(prd_key, 1, 5) AS cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info;

-- exploring the cat_id from bronze.erp_px_cat_g1v2

SELECT DISTINCT id
FROM bronze.erp_px_cat_g1v2;

-- outcome reveals cat_id in "bronze.crm_prd_info" is stored with '-' while id in "bronze.erp_px_cat_g1v2" is stored with '_'
-- using replace function 

SELECT
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info;

-- creating a new column off the remaining string in prd_key
SELECT
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info;

-- Replacing Null values in column prd_cost with N/a

SELECT
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info;


-- Transforming: changing the prd_line mapping from abbreviation to full naming for prd_line

SELECT
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
     WHEN 'M' THEN 'Mountain'
     WHEN 'R' THEN 'Road'
     WHEN 'S' THEN 'Other Sales'
     WHEN 'T' THEN 'Touring'
     ELSE 'N/a' 
     END AS prd_line,
prd_start_dt,
prd_end_dt
FROM bronze.crm_prd_info;


-- Fixing the invalid date columns
-- setting rules: set end date as (Next start date cell, in the next row) - 1day and also start date can not be Null

SELECT
prd_id,
prd_key,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
     WHEN 'M' THEN 'Mountain'
     WHEN 'R' THEN 'Road'
     WHEN 'S' THEN 'Other Sales'
     WHEN 'T' THEN 'Touring'
     ELSE 'N/a' 
     END AS prd_line,
CAST(prd_start_dt AS DATE) AS prd_start_dt, 
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
FROM bronze.crm_prd_info;


-- Insert Into Silver Table

INSERT INTO silver.crm_prd_info (
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
SELECT
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id, -- Extract Cat_id
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Extract prd_key
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost,
CASE UPPER(TRIM(prd_line))
     WHEN 'M' THEN 'Mountain'
     WHEN 'R' THEN 'Road'
     WHEN 'S' THEN 'Other Sales'
     WHEN 'T' THEN 'Touring'
     ELSE 'N/a' 
     END AS prd_line, -- Map prd_line codes to descriptive values
CAST(prd_start_dt AS DATE) AS prd_start_dt, 
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt -- Calculate end date as one day before the next date
FROM bronze.crm_prd_info;

SELECT *
FROM silver.crm_prd_info;



-- Transforming Data Quality issue in bronze.crm_sales_details
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
     END AS sls_order_dt,
sls_due_dt,
sls_ship_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details;

-- Transforming other date columns sls_due_dt, sls_ship_dt

SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
     END AS sls_order_dt,
CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
     END AS sls_due_dt,
CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
     END AS sls_ship_dt,
sls_sales,
sls_quantity,
sls_price
FROM bronze.crm_sales_details;

-- Transforming the column sales, quantity and price using the business rule: sales = quantity * price, also, sales, quantity
-- and price is NOT NULL, Negative

SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
     END AS sls_order_dt,
CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
     END AS sls_due_dt,
CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
     END AS sls_ship_dt,
CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
     END AS sls_sales,
CASE WHEN sls_price <= 0 OR sls_price IS NULL OR sls_price != sls_sales / NULLIF(sls_quantity, 0)
     THEN sls_sales / NULLIF(sls_quantity, 0)
     ELSE sls_price
     END AS sls_price,
CASE WHEN sls_quantity IS NULL OR sls_quantity <= 0 OR sls_quantity != sls_sales / NULLIF(sls_price, 0)
     THEN sls_sales / NULLIF(sls_price, 0)
     ELSE sls_quantity
     END AS sls_quantity
FROM bronze.crm_sales_details;

-- INSERT INTO SILVER TABLE

INSERT INTO silver.crm_sales_details (
sls_ord_num,
sls_prd_key,
sls_cust_id,
sls_order_dt,
sls_ship_dt,
sls_due_dt,
sls_sales,
sls_quantity,
sls_price
)
SELECT
sls_ord_num,
sls_prd_key,
sls_cust_id,
CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
     END AS sls_order_dt,
     CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
     END AS sls_ship_dt,
CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
     ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
     END AS sls_due_dt,
CASE WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
     THEN sls_quantity * ABS(sls_price)
     ELSE sls_sales
     END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
CASE WHEN sls_quantity IS NULL OR sls_quantity <= 0 OR sls_quantity != sls_sales / NULLIF(sls_price, 0)
     THEN sls_sales / NULLIF(sls_price, 0)
     ELSE sls_quantity
     END AS sls_quantity,-- Recalculate quantity if original value is missing or incorrect
CASE WHEN sls_price <= 0 OR sls_price IS NULL OR sls_price != sls_sales / NULLIF(sls_quantity, 0)
     THEN sls_sales / NULLIF(sls_quantity, 0)
     ELSE sls_price
     END AS sls_price -- Recalculate price if original value is missing or incorrect
FROM bronze.crm_sales_details;



-- Transforming data quanlity issue in bronze.erp_cust_az12
-- eliminate string 'NAS' from column cid

SELECT
bdate,
gen,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
     END AS cid
FROM bronze.erp_cust_az12;

-- Fixing invalid bdate
SELECT
gen,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
     END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
     END AS bdate
FROM bronze.erp_cust_az12;


-- fixing inconsistency in the values in gen
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

SELECT
CASE(UPPER(TRIM(gen)))
     WHEN 'F' THEN 'Female'
     WHEN 'M' THEN 'Male'
     ELSE gen
     END AS gen,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
     END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
     END AS bdate
FROM bronze.erp_cust_az12;

-- Insert Into Silver table

INSERT INTO Silver.erp_cust_az12 (
gen,
cid,
bdate
)
SELECT
CASE WHEN UPPER(TRIM(gen)) IN ('F', 'Female') THEN 'Female'
     WHEN UPPER(TRIM(gen)) IN ('M', 'Male') THEN 'Male'
     ELSE 'n/a'
     END AS gen,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
     END AS cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
     END AS bdate
FROM bronze.erp_cust_az12;


-- Transforming data quanlity issue in bronze.erp_1oc_a101
-- Removing the character '-' from the cid column

SELECT
REPLACE(cid, '-', '') AS cid,
cntry
FROM Bronze.erp_1oc_a101;

-- Fixing the inconsistency in cntry description
SELECT DISTINCT cntry
FROM bronze.erp_1oc_a101;

SELECT
REPLACE(cid, '-', '') AS cid,
CASE WHEN TRIM(cntry) IN ('DE', 'Germany') THEN 'Germany'
     WHEN TRIM(cntry) IN ('USA', 'US', 'United States') THEN 'USA'
     WHEN (cntry) IS NULL OR cntry = '' THEN 'n/a'
     ELSE TRIM(cntry)
     END AS cntry
FROM Bronze.erp_1oc_a101;

-- Insert into Silver table

INSERT INTO Silver.erp_1oc_a101 (
cid,
cntry)
SELECT
REPLACE(cid, '-', '') AS cid,
CASE WHEN TRIM(cntry) IN ('DE', 'Germany') THEN 'Germany'
     WHEN TRIM(cntry) IN ('USA', 'US', 'United States') THEN 'USA'
     WHEN (cntry) IS NULL OR cntry = '' THEN 'n/a'
     ELSE TRIM(cntry)
     END AS cntry
FROM Bronze.erp_1oc_a101;



-- Transforming data quanlity issue in bronze.erp_px_cat_g1v2;

-- Insert into the Silver table

INSERT INTO Silver.erp_px_cat_g1v2 (
id, cat, subcat, maintenance)
SELECT 
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2;

 
