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

-- Exploring: data quality issues
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result

Select *
FROM bronze.crm_cust_info;

-- Investigating the cst_id

SELECT Cst_id,
COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;


-- checking for unwanted spaces in string values
-- No result

SELECT cst_firstname
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);


SELECT cst_lastname
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

SELECT cst_gndr
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr);

-- Outcome reveals there are with space in both columns cst_firstname & cst_lastname


-- Data Standardization & Consistency

SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;



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

-- Check for unwanted spaces
-- Expectation: No result

SELECT prd_nm
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

SELECT *
FROM bronze.crm_prd_info;

-- Check for Nulls or Negative Numbers in the column prd_cost

SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NULL OR prd_cost < 0;


-- Data Standardization & consistency fpor column prd_line
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info; -- 4 DISTINCT Value including Null


-- check for invalid Date Orders
SELECT *
FROM bronze.crm_prd_info
WHERE prd_start_dt > prd_end_dt;
-- Outcome reveals some start dates are greater than end_date, which is invalid


-- Exploring: data quanlity issues in the table: bronze.crm_sales_details

-- finding unwanted spaces in sls_ord_num

SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

-- Check for invalid dates

SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt < 0;

SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0;
-- Outcome shows Date column contains 0, converto Null

-- Outcome also reveals, data is stored as INT, lENGTH = 8

-- Check for date length
SELECT
sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0 OR LEN(sls_order_dt) !=8 OR sls_order_dt > 20500101 -- this simply means sls_order_dt > 2050/01/01;
-- There are 19 values that looks to to be invalid


-- Check for Invalid sls_order_dt

SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt;

-- checking for inconsistencies in sales, quantity and price
-- Business Rules (Sales = Quantity * Price)
-- Business Rules: value in this column must not be negative, zero, Null 

SELECT 
DISTINCT sls_sales, sls_quantity, sls_price
FROM bronze.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL or sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 or sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;




-- Exploring bronze.erp_cust_az12

SELECT *
FROM bronze.erp_cust_az12;

-- cid contains string 'NAS', eliminate this string from the rest

-- Investigating the bdate range
SELECT DISTINCT
bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > GETDATE();

-- Inestigating gen column

SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

-- Exploring bronze.erp_1oc_a101
SELECT *
FROM bronze.erp_1oc_a101;

-- Appears the character '-' needs to be eliminated from the cid column

SELECT DISTINCT cntry
FROM bronze.erp_1oc_a101;


-- Exploring bronze.erp_px_cat_g1v2;   cat, subcat, maintenance

SELECT *
FROM bronze.erp_px_cat_g1v2;
