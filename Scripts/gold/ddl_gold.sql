/*
===========================================================================================================
DDL Script: Create Gold Views
===========================================================================================================
Script Purpose:
     This script creates views for the Gold layer in the data warehouse.
     The gold layer represents the final dimension and fact tables (star schema)

     Each view performs transformations and combines data rom the silver layer to 
     produce a clean, enriched, and business-ready dataset.

  Usage:
       - these views can be queried directly for analytics and reporting.
===========================================================================================================
*/

-- ========================================================================================================
-- Creating Dimension: gold.dim_customers
-- ========================================================================================================
 -- Building the gold_customer_dim view
 -- exploring to see if there are duplicates

SELECT 
cst_id,
COUNT(*)
FROM (
SELECT 
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_gndr,
    ci.cst_create_date,
    ca.bdate,
    ca.gen,
    cb.cntry
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_1oc_a101 cb
ON ci.cst_key = cb.cid
) t
GROUP BY cst_id
HAVING COUNT(*) > 1
 
 -- Outcome from the above reveals there are two gender columns cst_gndr & gen
 -- carrying out data integration

 SELECT 
    DISTINCT
    ci.cst_gndr,
    ca.gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_1oc_a101 cb
ON ci.cst_key = cb.cid
ORDER BY 1, 2;

-- Looking at this descrpancy, here is where you determine whcih of the system does the master table comes from, for this, it's the CRM
-- Fixing the inconsistency in the gender columns

SELECT 
    DISTINCT
    ci.cst_gndr,
    ca.gen,
    CASE WHEN ci.cst_gndr != 'N/a' THEN ci.cst_gndr -- CRM is the master for gender information
    ELSE COALESCE(ca.gen, 'N/a') -- this condition basically states, set ci.cst_gndr as default, if blank or n/a, use data from ca.gen, if ca.gen is blank, return n/a
    END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_1oc_a101 cb
ON ci.cst_key = cb.cid
ORDER BY 1, 2;
 -- data integration is what we have done above

 -- Adding the integration in the original query

SELECT 
    ci.cst_id,
    ci.cst_key,
    ci.cst_firstname,
    ci.cst_lastname,
    ci.cst_marital_status,
    ci.cst_create_date,
    ca.bdate,
    cb.cntry,
    CASE WHEN ci.cst_gndr != 'N/a' THEN ci.cst_gndr -- CRM is the master for gender information
    ELSE COALESCE(ca.gen, 'N/a') -- this condition basically states, set ci.cst_gndr as default, if blank or n/a, use data from ca.gen, if ca.gen is blank, return n/a
    END AS cst_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_1oc_a101 cb
ON ci.cst_key = cb.cid


-- Renaming columns to business descriptive names
SELECT 
    ci.cst_id AS Customer_id,
    ci.cst_key AS Customer_number,
    ci.cst_firstname AS First_name,
    ci.cst_lastname AS Last_name,
    cb.cntry AS Country,
    ci.cst_marital_status Marital_status,
    ca.bdate AS Birth_date,
    ci.cst_create_date AS created_date,
    CASE WHEN ci.cst_gndr != 'N/a' THEN ci.cst_gndr -- CRM is the master for gender information
    ELSE COALESCE(ca.gen, 'N/a') -- this condition basically states, set ci.cst_gndr as default, if blank or n/a, use data from ca.gen, if ca.gen is blank, return n/a
    END AS Gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_1oc_a101 cb
ON ci.cst_key = cb.cid

-- because this is a dimension table, a primary key is needed
-- in a situation where there's no primary key
-- we add a surrogate key( surrogate key is a system-generated unique identifier assigned to each record in a table)

-- using the Window function to generate a surrogate key


SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS Customer_key,
    ci.cst_id AS Customer_id,
    ci.cst_key AS Customer_number,
    ci.cst_firstname AS First_name,
    ci.cst_lastname AS Last_name,
    cb.cntry AS Country,
    ci.cst_marital_status Marital_status,
    ca.bdate AS Birth_date,
    ci.cst_create_date AS created_date,
    CASE WHEN ci.cst_gndr != 'N/a' THEN ci.cst_gndr -- CRM is the master for gender information
    ELSE COALESCE(ca.gen, 'N/a') -- this condition basically states, set ci.cst_gndr as default, if blank or n/a, use data from ca.gen, if ca.gen is blank, return n/a
    END AS Gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_1oc_a101 cb
ON ci.cst_key = cb.cid


-- Creating view in the Gold Layer

CREATE VIEW gold.dim_customers AS 
SELECT 
    ROW_NUMBER() OVER (ORDER BY cst_id) AS Customer_key,
    ci.cst_id AS Customer_id,
    ci.cst_key AS Customer_number,
    ci.cst_firstname AS First_name,
    ci.cst_lastname AS Last_name,
    cb.cntry AS Country,
    ci.cst_marital_status Marital_status,
    ca.bdate AS Birth_date,
    ci.cst_create_date AS created_date,
    CASE WHEN ci.cst_gndr != 'N/a' THEN ci.cst_gndr -- CRM is the master for gender information
    ELSE COALESCE(ca.gen, 'N/a') -- this condition basically states, set ci.cst_gndr as default, if blank or n/a, use data from ca.gen, if ca.gen is blank, return n/a
    END AS Gender
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_1oc_a101 cb
ON ci.cst_key = cb.cid;

-- ========================================================================================================
-- Creating Dimension: gold_product_dim
-- ========================================================================================================

-- Filter out historical data

SELECT
    prd_id,
    cat_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
    FROM silver.crm_prd_info
    WHERE prd_end_dt IS NULL; -- filters out historical data, i.e products with no end date indicates current products

-- Join to ERP source

SELECT
pa.prd_id,
pa.cat_id,
pa.prd_key,
pa.prd_nm,
pa.prd_cost,
pa.prd_line,
pa.prd_start_dt,
pa.prd_end_dt,
pb.cat,
pb.subcat,
pb.maintenance
FROM silver.crm_prd_info pa
LEFT JOIN silver.erp_px_cat_g1v2 pb
ON pa.cat_id = pb.id
WHERE prd_end_dt IS NULL;

-- check data quality and uniqueness

SELECT prd_key, COUNT(*)
FROM (
SELECT
pa.prd_id,
pa.prd_key,
pa.prd_nm,
pa.cat_id,
pb.cat,
pb.subcat,
pa.prd_cost,
pa.prd_line,
pa.prd_start_dt,
pb.maintenance
FROM silver.crm_prd_info pa
LEFT JOIN silver.erp_px_cat_g1v2 pb
ON pa.cat_id = pb.id
WHERE prd_end_dt IS NULL) t
GROUP BY prd_key
HAVING COUNT(*) > 1; -- No duplicate found

-- Rename columns to business descriptive names

    SELECT
    pa.prd_id AS Product_id,
    pa.prd_key AS Product_number,
    pa.prd_nm AS product_name,
    pa.cat_id AS category_id,
    pb.cat AS category,
    pb.subcat AS Subcategory,
    pb.maintenance,
    pa.prd_cost AS Cost,
    pa.prd_line AS product_line,
    pa.prd_start_dt AS start_date
    FROM silver.crm_prd_info pa
    LEFT JOIN silver.erp_px_cat_g1v2 pb
    ON pa.cat_id = pb.id
    WHERE prd_end_dt IS NULL;

-- Creating surrogate key

SELECT
ROW_NUMBER () OVER (ORDER BY pa.prd_start_dt, pa.prd_key) AS Product_key,
pa.prd_id AS Product_id,
pa.prd_key AS Product_number,
pa.prd_nm AS product_name,
pa.cat_id AS category_id,
pb.cat AS category,
pb.subcat AS Subcategory,
pb.maintenance,
pa.prd_cost AS Cost,
pa.prd_line AS product_line,
pa.prd_start_dt AS start_date
FROM silver.crm_prd_info pa
LEFT JOIN silver.erp_px_cat_g1v2 pb
ON pa.cat_id = pb.id
WHERE prd_end_dt IS NULL;

-- Create view for gold_product_dim

CREATE VIEW gold.product_dim AS
SELECT
ROW_NUMBER () OVER (ORDER BY pa.prd_start_dt, pa.prd_key) AS Product_key,
pa.prd_id AS Product_id,
pa.prd_key AS Product_number,
pa.prd_nm AS product_name,
pa.cat_id AS category_id,
pb.cat AS category,
pb.subcat AS Subcategory,
pb.maintenance,
pa.prd_cost AS Cost,
pa.prd_line AS product_line,
pa.prd_start_dt AS start_date
FROM silver.crm_prd_info pa
LEFT JOIN silver.erp_px_cat_g1v2 pb
ON pa.cat_id = pb.id
WHERE prd_end_dt IS NULL;


-- ========================================================================================================
-- Creating Dimension: gold_fact_sales
-- ========================================================================================================

-- Joining with table to gold.product_dim & gold.dim_customers using surrogate key

SELECT
sd.sls_ord_num,
pr.product_key,
dc.customer_key,
sd.sls_order_dt,
sd.sls_ship_dt,
sd.sls_due_dt,
sd.sls_sales,
sd.sls_quantity,
sd.sls_price
FROM silver.crm_sales_details sd
LEFT JOIN gold.product_dim pr
ON pr.product_number = sd.sls_prd_key
LEFT JOIN gold.dim_customers dc
ON dc.customer_id = sd.sls_cust_id; -- outcome of this allows the fact table to contain both 
surrogate keys from gold_dim_customers and gold_product_dim

-- Renaming columns to business descriptive names
SELECT
sd.sls_ord_num AS Order_number,
pr.product_key,
dc.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS Ship_date,
sd.sls_due_dt AS Due_date,
sd.sls_sales AS Sales_amount,
sd.sls_quantity AS Quantity,
sd.sls_price AS Price
FROM silver.crm_sales_details sd
LEFT JOIN gold.product_dim pr
ON pr.product_number = sd.sls_prd_key
LEFT JOIN gold.dim_customers dc
ON dc.customer_id = sd.sls_cust_id;


-- Creating view for fact_sales

CREATE VIEW gold.fact_sales AS 
SELECT
sd.sls_ord_num AS Order_number,
pr.product_key,
dc.customer_key,
sd.sls_order_dt AS order_date,
sd.sls_ship_dt AS Ship_date,
sd.sls_due_dt AS Due_date,
sd.sls_sales AS Sales_amount,
sd.sls_quantity AS Quantity,
sd.sls_price AS Price
FROM silver.crm_sales_details sd
LEFT JOIN gold.product_dim pr
ON pr.product_number = sd.sls_prd_key
LEFT JOIN gold.dim_customers dc
ON dc.customer_id = sd.sls_cust_id;
